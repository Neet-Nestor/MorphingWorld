package states;

import config.Config;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
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
import Sound;
import sprites.Board;
import sprites.CameraFocus;
import sprites.DamagerSprite;
import sprites.Player;
import sprites.Portal;
import sprites.PuffEmitter;
import sprites.Switch;
import sprites.WorldPiece;

class Hint {
    public var triggered:Bool;
    public var tween:FlxTween;
    public var text:FlxText;
    public var triggerCondition:Void -> Bool;
    public var callback:Void -> Void;

    public function new() { }
}

class PlayState extends LycanState {
    public var player:Player;
    public var universe:Universe;
	public var cameraFocus:CameraFocus;
    public var reloadPlayerPosition:Bool;
	public var curStage:Int;

    // For transition effects
    public var timeFactor(default, set):Float = 1;

    // For emitter effects
	public var puffEmitter:PuffEmitter;

    // World Editing related
    public var editState:EditState;
    public var isWorldEditing:Bool;
    public var editingTransitionAmount(default, set):Float = 0;

    // Disabled actions
    public var worldEditingDisabled:Bool;

    // Hints
    public var zoomHintShown:Bool;
    public var dragHintShown:Bool;

    // For scripts
	public var parser:Parser;
	public var interp:Interp;

    // Managers
	public var timers:FlxTimerManager;
    public var tweens:FlxTweenManager;

    // Sound
    public var _sndDie:FlxSound;

    // Hint related
    public var hintList:List<Hint>;

	public static var instance(default, null):PlayState;

    public function new() {
        super();
        instance = this;
        isWorldEditing = false;
        zoomHintShown = #if FLX_NO_DEBUG false #else true #end;
        dragHintShown = #if FLX_NO_DEBUG false #else true #end;
        worldEditingDisabled = #if FLX_NO_DEBUG true #else false #end;
        hintList = new List<Hint>();
        curStage = 0;
        _sndDie = FlxG.sound.load(AssetPaths.die__wav);
    }

    override public function create():Void {
		persistentDraw = true;
        persistentUpdate = true;
        reloadPlayerPosition = false;
        // In case it was set before by fault
        Phys.FORCE_TIMESTEP = null;

        super.create();
        initPhysics();
        initManagers();
        initScripts();
        WorldCollection.init();
        initUniverse();
        initCamera();
        add(player);
        // Move hint
        showHint("[A/D or LEFT/RIGHT to move]",
            () -> FlxG.keys.anyJustPressed([FlxKey.A, FlxKey.D, FlxKey.UP, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT]),
            () -> {
                showHint("[W/UP/SPACE to jump]", () -> FlxG.keys.anyJustPressed([FlxKey.UP, FlxKey.W, FlxKey.SPACE]));
            });
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
        
        // -- Switch listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR,
            PlatformerPhysics.CHARACTER_TYPE, Switch.SWITCH_TYPE, function(cb:InteractionCallback) {
                var s:Switch = cast cb.int2.userData.entity;
                s.switcher.on = true;
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

    private function initUniverse():Void {
        universe = new Universe();
        reloadPlayerPosition = true;

        curStage = 0;
        WorldCollection.defineWorlds(curStage);
        var initWorld = WorldCollection.get(Config.STAGES[curStage][0]);
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

        // Check any hint has been triggered
        for (hint in hintList) {
            if (!hint.triggered && hint.triggerCondition()) {
                hint.triggered = true;
                hint.callback();
            }
        }
        
        // actions
        if (FlxG.keys.anyJustPressed([FlxKey.UP, FlxKey.W, FlxKey.SPACE])) {
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

        if (!worldEditingDisabled) {
            if (FlxG.mouse.wheel > 0) beginWorldEditing();
            else if (FlxG.mouse.wheel < 0) endWorldEditing();
            else if (FlxG.keys.anyJustReleased([FlxKey.E])) toggleWorldEditing();
        }

        #if cpp
        if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE])) FlxG.switchState(new MenuState());
        if (FlxG.keys.anyJustPressed([FlxKey.F])) FlxG.fullscreen = !FlxG.fullscreen;
        #end

        // TODO: better way to detech death
        if (player.physics.body.velocity.y > 800) {
            die();
        }

        FlxG.watch.addQuick("player xy", FlxPoint.weak(player.x, player.y));
        FlxG.watch.addQuick("player position", player.physics.body.position);
        FlxG.watch.addQuick("player velocity", player.physics.body.velocity);
        FlxG.watch.addQuick("Space Gravity", Phys.space.gravity);
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
    }

    // Handlers
    public function die():Void {
        endWorldEditing();
        player.characterController.hasControl = false;
        player.dead = true;
        player.characterController.stop();
        // Main.sound.playSound(Effect.Die, Main.user.getSettings().sound);
        if (Main.user.getSettings().sound) _sndDie.play();
        player.animation.finishCallback = (_) -> {
            persistentUpdate = false;
            player.physics.body.velocity.y = 0;
            Phys.FORCE_TIMESTEP = 0;    //TODO: LD quick hack to pause physics sim
            var dieState = new DieState();
            dieState.closeCallback = () -> {
                remove(player);
                player.destroy();
                player = null;
                universe.reset();
                add(player);
                FlxG.camera.follow(null);
                cameraFocus.destroy();
                cameraFocus = new CameraFocus();
                cameraFocus.add(new ObjectTargetInfluencer(player));
                FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
                FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
                FlxG.camera.snapToTarget();
                Phys.FORCE_TIMESTEP = null;
                persistentUpdate = true;
            }
            openSubState(dieState);
        };
    }

    public function passLevel():Void {
        if (isWorldEditing) endWorldEditing();
        // logging
        Main.logger.logPass(curStage);
        Main.user.setLastStage(curStage);

        var passState = new PassState();
        persistentUpdate = false;
        player.characterController.hasControl = false;
        player.characterController.leftPressed = false;
        player.characterController.rightPressed = false;
        player.characterController.stop();
        player.physics.body.velocity.y = 0;
        Phys.FORCE_TIMESTEP = 0;
        passState.closeCallback = () -> {
            Phys.FORCE_TIMESTEP = null;
            player.characterController.hasControl = true;
            persistentUpdate = true;
        };
        openSubState(passState);
    }

    public function toNextStage():Void {
        // Clean
        curStage++;
        WorldCollection.reset();
        WorldCollection.defineWorlds(curStage);
        remove(player);
        player.destroy();
        player = null;

        var nextWorld = WorldCollection.get(Config.STAGES[curStage][0]);
        if (nextWorld.name == "win") Main.logger.logWin();
        nextWorld.owned = true;
        universe.reset();
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
        player.characterController.leftPressed = false;
        player.characterController.rightPressed = false;
        Phys.FORCE_TIMESTEP = 0;    //TODO: LD quick hack to pause physics sim
        if (isWorldEditing) {
            var editState:EditState = cast subState;
            editState.persistentUpdate = false;
            foundState.closeCallback = () -> {
                Phys.FORCE_TIMESTEP = null;
                editState.persistentUpdate = true;
                editState.addNewWorldPiece(worldDef);
            };
            editState.openSubState(foundState);
        } else {
            // Reset running status
            persistentUpdate = false;
            foundState.closeCallback = () -> {
                Phys.FORCE_TIMESTEP = null;
                persistentUpdate = true;
                if (!zoomHintShown) {
                    zoomHintShown = true;
                    worldEditingDisabled = false;
                    player.characterController.hasControl = false;
                    showHint("[Scroll Up or E to change the world]",
                        () -> FlxG.keys.anyJustPressed([FlxKey.E]) || FlxG.mouse.wheel > 0);
                }
            };
            openSubState(foundState);
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
			var destinationSlot = PlayState.instance.universe.getSlot(1, 0).outline;
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
    // Transfer to hint state
    public function showHint(text:String, triggerCondition:Void -> Bool, ?cb:Void -> Void):Void {
            // cancel previous hint
            var hint = new Hint();
            hint.triggered = false;
            hint.text = new FlxText(0, FlxG.height - 50, 0, text, 20);
            hint.text.screenCenter(FlxAxes.X);
            hint.text.alpha = 0;
            hint.triggerCondition = triggerCondition;
            hint.callback = () -> {
                if (!hint.tween.finished) hint.tween.cancel();
                if (cb != null) cb();
                hintList.remove(hint);
                FlxTween.tween(hint.text, {alpha: 0}, 0.6, { onComplete: (_) -> {
                    uiGroup.remove(hint.text);
                }});
            };
            hint.tween = FlxTween.tween(hint.text, {alpha: 1}, 0.6);
            hintList.add(hint);
            uiGroup.add(hint.text);
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
