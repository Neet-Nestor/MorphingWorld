package states;

import config.Config;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import sprites.Board;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.MiniWorld;
import game.Universe;
import game.WorldCollection;
import game.WorldDef;
import game.WorldLoader;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.states.LycanState;
import lycan.world.layer.PhysicsTileLayer;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import openfl.display.Tilemap;
import sprites.CameraFocus;
import sprites.Player;
import sprites.Portal;
import sprites.PuffEmitter;
import sprites.WorldPiece;
import sprites.DamagerSprite;
import Sound;

class PlayState extends LycanState {
    public var player:Player;
    public var universe:Universe;
	public var cameraFocus:CameraFocus;
    public var reloadPlayerPosition:Bool;
    public var initWorld:WorldDef;
    public var initPosition:FlxPoint;

    // For transition effects
    public var timeFactor(default, set):Float = 1;

    // For emitter effects
	public var puffEmitter:PuffEmitter;

    // World Editing related
    public var editState:EditState;
    public var isWorldEditing:Bool;
    public var editingTransitionAmount(default, set):Float = 0;

    public var dieState:DieState;

    // Hints
	public var zoomHintShown:Bool;
	public var dragHintShown:Bool;

    // For scripts
	public var parser:Parser;
	public var interp:Interp;

    // Managers
	public var timers:FlxTimerManager;
    public var tweens:FlxTweenManager;

    // Tween
    public var textHint:FlxText;

	public static var instance(default, null):PlayState;

    public function new() {
        super();
        instance = this;
        isWorldEditing = false;
        zoomHintShown = false;
        dragHintShown = false;
    }

    override public function create():Void {
		persistentDraw = true;
        persistentUpdate = true;
        reloadPlayerPosition = false;

        super.create();
        initPhysics();
        initManagers();
        initScripts();
        WorldCollection.init();
        initUniverse();
        initCamera();
        add(player);
        showText("[WASD to move]");
    }

    // Initializers

    private function initPhysics():Void {
        // Initialize physics
        Phys.init();
        PlatformerPhysics.setupPlatformerPhysics();

        // Setup gravity
        Phys.space.gravity.setxy(0, Config.GRAVITY);

        // Game listeners setup
        // -- Piece Found listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR,
            WorldPiece.WORLD_PIECE_TYPE, PlatformerPhysics.CHARACTER_TYPE, (cb:InteractionCallback) -> {
			var piece:WorldPiece = cast cb.int1.userData.entity;
			piece.collectable.collect((cb.int2.userData.entity:Player));
			// Sounds.playSound(SoundAssets.collect, piece.physics.body.position.x, piece.physics.body.position.y);
        }));
        
        // -- Portal listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR,
            Portal.PORTAL_TYPE, PlatformerPhysics.CHARACTER_TYPE, (cb:InteractionCallback) -> {
			var portal:Portal = cast cb.int1.userData.entity;
			portal.port((cb.int2.userData.entity:Player));
			// Sounds.playSound(SoundAssets.collect, piece.physics.body.position.x, piece.physics.body.position.y);
        }));
        
        // -- Damage listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION,
            PlatformerPhysics.CHARACTER_TYPE, DamagerSprite.DAMAGER_TYPE, function(cb:InteractionCallback) {
                die();
		}));
    }

    private function initManagers():Void {
		timers = new FlxTimerManager();
		tweens = new FlxTweenManager();
        puffEmitter = new PuffEmitter();
		add(timers);
        add(tweens);
        add(puffEmitter);
    }

    private function initScripts():Void {
        // Scripting Setup
		parser = new Parser();
		interp = new Interp();
		var scriptGlobals:Dynamic = {};
		interp.variables.set("Global", scriptGlobals);
		interp.variables.set("game", this);
		interp.variables.set("Math", Math);
		interp.variables.set("FlxTween", tweens);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("BodyType", BodyType);
		interp.variables.set("ObjectTargetInfluencer", ObjectTargetInfluencer);
		interp.variables.set("wait", function(delay:Float, cb:Void -> Void) new FlxTimer(timers).start(delay, (_) -> cb()));
    }

    private function initUniverse(initWorldName:String = Config.START_WORLD):Void {
        universe = new Universe();
        reloadPlayerPosition = true;

        initWorld = WorldCollection.get(initWorldName);
        universe.makeSlot(0, 0).loadWorld(initWorld);
        initWorld.owned = true;
        universe.forEachOfType(WorldPiece, (piece) -> {
            if (piece.worldDef == initWorld) piece.collectable.collect(player);
        }, true);

        add(universe);
    }

    private function initCamera():Void {
        baseZoom = Config.DEFAULT_ZOOM;
        worldZoom = 1;
        
		cameraFocus = new CameraFocus();
		cameraFocus.add(new ObjectTargetInfluencer(player));
		FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
		FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
		FlxG.camera.snapToTarget();
    }

    // FlxSprite Overrides

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        // actions
        if (FlxG.keys.anyJustPressed([FlxKey.UP, FlxKey.W])) {
            player.characterController.jump();
        }
        if (FlxG.keys.anyJustPressed([FlxKey.LEFT, FlxKey.A])) {
            player.characterController.leftPressed = true;
        }
        if (FlxG.keys.anyJustPressed([FlxKey.RIGHT, FlxKey.D])) {
            player.characterController.rightPressed = true;
        }
        if (FlxG.keys.anyJustReleased([FlxKey.LEFT, FlxKey.A])) {
            player.characterController.leftPressed = false;
        }
        if (FlxG.keys.anyJustReleased([FlxKey.RIGHT, FlxKey.D])) {
            player.characterController.rightPressed = false;
        }

        if (FlxG.mouse.wheel < 0) beginWorldEditing();
        else if (FlxG.mouse.wheel > 0) endWorldEditing();
        else if (FlxG.keys.anyJustReleased([FlxKey.SPACE])) toggleWorldEditing();

        if (FlxG.keys.anyJustPressed([FlxKey.R])) die();

        #if cpp
        if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE])) Sys.exit(0);
        if (FlxG.keys.anyJustPressed([FlxKey.F])) FlxG.fullscreen = !FlxG.fullscreen;
        #end

        // TODO: better way to detech death
        if (player.physics.body.velocity.y > 800) {
            if (initPosition != null) {
                die();
            }
        }

        FlxG.watch.addQuick("player position", player.physics.body.position);
        FlxG.watch.addQuick("player velocity", player.physics.body.velocity);
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
    }

    // Handlers
    public function reset():Void {
        if (isWorldEditing) endWorldEditing();
        WorldCollection.reset();
        remove(player);
        player.destroy();
        player = null;
        initPosition.put();
        initPosition = null;
        universe.reset();
        if (initWorld != null) {
            initWorld.owned = true;
            universe.forEachOfType(WorldPiece, (piece) -> {
                if (piece.worldDef == initWorld) piece.collectable.collect(player);
            }, true);
        }
        add(player);
		FlxG.camera.follow(null);
        cameraFocus.destroy();
		cameraFocus = new CameraFocus();
		cameraFocus.add(new ObjectTargetInfluencer(player));
		FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
		FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
		FlxG.camera.snapToTarget();
    }

    public function die():Void {
        endWorldEditing();
        player.characterController.hasControl = false;
        player.dead = true;
        player.characterController.stop();
        Main.sound.playSound(Effect.Die, Main.user.getSettings().sound);
        player.animation.finishCallback = (_) -> {
            persistentUpdate = false;
            player.physics.body.velocity.y = 0;
            Phys.FORCE_TIMESTEP = 0;    //TODO: LD quick hack to pause physics sim
            //player.characterController.leftPressed = false;
            //player.characterController.rightPressed = false;
            //player.physics.body.velocity.y = 0;
            dieState = new DieState();
            dieState.closeCallback = () -> {
                reset();
                Phys.FORCE_TIMESTEP = null;
                persistentUpdate = true;
            }
            openSubState(dieState);
        };
    }

    public function switchWorld(nextWorld:WorldDef):Void {
        if (isWorldEditing) endWorldEditing();
        // Clean
        WorldCollection.reset();
        remove(player);
        player.destroy();
        player = null;
        initPosition.put();
        initPosition = null;

        nextWorld.owned = true;
        universe.reset(nextWorld.name);
        universe.forEachOfType(WorldPiece, (piece) -> {
            if (piece.worldDef == initWorld) piece.collectable.collect(player);
        }, true);
        initWorld = nextWorld;
        add(player);
		FlxG.camera.follow(null);
        cameraFocus.destroy();
		cameraFocus = new CameraFocus();
		cameraFocus.add(new ObjectTargetInfluencer(player));
		FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
		FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
		FlxG.camera.snapToTarget();
    }

    public function collectWorld(worldDef:WorldDef):Void {
        var foundState = new PieceFoundState(worldDef);
        // Reset running status
        player.characterController.leftPressed = false;
        player.characterController.rightPressed = false;
		function collectWorld() {
			persistentUpdate = false;
			Phys.FORCE_TIMESTEP = 0;    //TODO: LD quick hack to pause physics sim
			foundState.closeCallback = () -> {
				Phys.FORCE_TIMESTEP = null;
				persistentUpdate = true;
                showText("[SPACE to edit]");
			}
			openSubState(foundState);
		}

		if (isWorldEditing) {
			endWorldEditing(() -> {
				collectWorld();
			}, true);
		} else {
			collectWorld();
		}
    }

    public function beginWorldEditing():Void {
        if (isWorldEditing || editState != null || WorldCollection.instance.collectedCount <= 0) {
            return;
        }
        isWorldEditing = true;
        exclusiveTween("editTransition", this, { editingTransitionAmount: 1 }, 0.7, { ease: FlxEase.quadOut });
        editState = new EditState();
        openSubState(editState);
        // Hint show once
        if (!dragHintShown) {
            dragHintShown = true;
            new FlxTimer().start(0.5, (_) -> this.showText("[Drag & Drop]", 2, uiGroup, () -> showText("[Click to reset world]")));
        }
    }

    public function endWorldEditing(?callback:Void -> Void, fast:Bool = false):Void {
        if (!isWorldEditing || editState == null) {
            return;
        }
        isWorldEditing = false;
        exclusiveTween("editTransition", this, { editingTransitionAmount: 0 }, fast ? 0.4 : 0.6, { ease: FlxEase.quadOut });
        editState.transitionOut(() -> {
            editState = null;
            if (callback != null) callback();
        }, fast);
    }

    public function toggleWorldEditing():Void {
        if (isWorldEditing) {
            endWorldEditing();
        } else {
            beginWorldEditing();
        }
    }

    // Helper functions

    // Create a text on screen
	public function showText(str:String, showTime:Float = 1.65, ?group:FlxSpriteGroup, ?callback:() -> Void):Void {
		var t = new FlxText(0, 0, 0, str, 20);
		// t.font = "fairfax";
		t.y = FlxG.height - 50;
		t.screenCenter(FlxAxes.X);
        t.alpha = 0;
        
        if (group == null) group = uiGroup;

        if (textHint != null) group.remove(textHint);
        
        FlxTween.tween(t, {alpha: 1}, 0.6, {onComplete: (_) -> {
            FlxTween.tween(t, {alpha: 0}, 0.6, {startDelay: showTime, onComplete: (_) -> {
                if (PlayState.instance.textHint != null) {
                    group.remove(PlayState.instance.textHint);
                    PlayState.instance.textHint.destroy();
                    PlayState.instance.textHint = null;
                }
                if (callback != null) callback();
            }});
        }});

        textHint = t;
		group.add(t);
	}
    
    // Setters

	private function set_timeFactor(val:Float):Float {
		this.timeFactor = val;
		// TODO: better solution for this
		Phys.FORCE_TIMESTEP = (val == 0) ? null : FlxG.elapsed * timeFactor;
		return val;
    }
    
    private function set_editingTransitionAmount(val:Float):Float {
		this.editingTransitionAmount = val;

		worldCamera.zoom = FlxMath.lerp(Config.DEFAULT_ZOOM, Config.WORLD_EDITING_ZOOM, val);
		worldCamera.targetOffset.y = Config.CAMERA_OFFSET_Y - val * 60;

		// music.volume = Math.max(0.01, 1 - val);
		// musicLowPass.volume = Math.max(0.01, val);

		// TODO: better solution for this
		Phys.FORCE_TIMESTEP = (val == 0) ? null : FlxG.elapsed * timeFactor;

		return val;
	}
}
