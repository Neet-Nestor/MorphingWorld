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
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
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
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import openfl.display.Tilemap;
import sprites.CameraFocus;
import sprites.PhysSprite;
import sprites.Player;
import sprites.WorldPiece;

class PlayState extends LycanState {
    public var player:Player;
    public var universe:Universe;
	public var cameraFocus:CameraFocus;
    public var reloadPlayerPosition:Bool;

    // For transition effects
    public var timeFactor(default, set):Float = 1;

    // World Editing related
    public var editState:EditState;
    public var isWorldEditing:Bool;
    public var editingTransitionAmount(default, set):Float = 0;

    // Hints
	public var zoomHintShown:Bool;
	public var dragHintShown:Bool;

    // For scripts
	public var parser:Parser;
	public var interp:Interp;

    // Managers
    public var actions:FlxActionManager;
	public var timers:FlxTimerManager;
	public var tweens:FlxTweenManager;

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
        initActions();
        initScripts();
        WorldCollection.init();
        initUniverse();
        initCamera();
        add(player);
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
    }

    private function initManagers():Void {
		timers = new FlxTimerManager();
		tweens = new FlxTweenManager();
		actions = new FlxActionManager();
		add(timers);
        add(tweens);
    }

    private function initActions():Void {
        // Player actions
        var actionJump = new FlxActionDigital("Jump", (_) -> {
            player.characterController.jump();
        });
        actionJump.addKey(FlxKey.UP, FlxInputState.JUST_PRESSED);
        actionJump.addKey(FlxKey.X, FlxInputState.JUST_PRESSED);
        actionJump.addKey(FlxKey.Z, FlxInputState.JUST_PRESSED);
        actionJump.addKey(FlxKey.W, FlxInputState.JUST_PRESSED);
        actionJump.addGamepad(FlxGamepadInputID.DPAD_UP, FlxInputState.JUST_PRESSED);
        actionJump.addGamepad(FlxGamepadInputID.A, FlxInputState.JUST_PRESSED);
        actionJump.addGamepad(FlxGamepadInputID.B, FlxInputState.JUST_PRESSED);

        var actionLeft = new FlxActionDigital("Left", (_) -> {
            player.characterController.leftPressed = true;
        });
        actionLeft.addKey(FlxKey.LEFT, FlxInputState.JUST_PRESSED);
        actionLeft.addKey(FlxKey.A, FlxInputState.JUST_PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.JUST_PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.JUST_PRESSED);

        var actionReleaseLeft = new FlxActionDigital("ReleaseLeft", (_) -> {
            player.characterController.leftPressed = false;
        });
        actionReleaseLeft.addKey(FlxKey.LEFT, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addKey(FlxKey.A, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.JUST_RELEASED);

        var actionRight = new FlxActionDigital("Right", (_) -> {
            player.characterController.rightPressed = true;
        });
        actionRight.addKey(FlxKey.RIGHT, FlxInputState.JUST_PRESSED);
        actionRight.addKey(FlxKey.D, FlxInputState.JUST_PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.JUST_PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.JUST_PRESSED);

       var actionReleaseRight = new FlxActionDigital("ReleaseRight", (_) -> {
            player.characterController.rightPressed = false;
        });
        actionReleaseRight.addKey(FlxKey.RIGHT, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addKey(FlxKey.D, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.JUST_RELEASED);

        var actionBeginWorldEditing = new FlxActionDigital("BeginWorldEditing", (_) -> this.beginWorldEditing());
        actionBeginWorldEditing.addMouseWheel(false, FlxInputState.JUST_PRESSED);

        var actionEndWorldEditing = new FlxActionDigital("EndWorldEditing", (_) -> this.endWorldEditing());
        actionEndWorldEditing.addMouseWheel(true, FlxInputState.JUST_PRESSED);

        var actionToggleWorldEditing = new FlxActionDigital("ToggleWorldEditing", (_) -> this.toggleWorldEditing());
        actionToggleWorldEditing.addKey(FlxKey.SPACE, FlxInputState.JUST_PRESSED);

        actions.addActions([actionLeft, actionRight, actionReleaseLeft, actionReleaseRight, actionJump]);
        actions.addActions([actionBeginWorldEditing, actionEndWorldEditing, actionToggleWorldEditing]);

        #if cpp
        var actionExitGame = new FlxActionDigital("ExitGame", (_) -> { Sys.exit(0); });
        actionExitGame.addKey(FlxKey.ESCAPE, FlxInputState.JUST_PRESSED);
        var actionToggleFullScreen = new FlxActionDigital("ToggleFullScreen", (_) -> { FlxG.fullscreen = !FlxG.fullscreen; });
        actionToggleFullScreen.addKey(FlxKey.F, FlxInputState.JUST_PRESSED);

        actions.addActions([actionExitGame, actionToggleFullScreen]);
        #end

        var actionResetGame = new FlxActionDigital("ResetGame", (_) -> { reset(); });
        actionResetGame.addKey(FlxKey.R, FlxInputState.JUST_PRESSED);
        actions.addAction(actionResetGame);
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
        
        var initWorld = WorldCollection.get(initWorldName);
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

    // helper function for putting the player at the correct position.
    private function placeEntities(entityName:String, entityData:Xml):Void {
        var x:Int = Std.parseInt(entityData.get("x"));
        var y:Int = Std.parseInt(entityData.get("y"));
        if (entityName == "player") {
            player.x = x;
            player.y = y;
        }
    }

    // FlxSprite Overrides

    override public function update(elapsed:Float):Void {
        @:privateAccess actions.update();

        super.update(elapsed);

        FlxG.watch.addQuick("player position", player.physics.body.position);
        FlxG.watch.addQuick("player velocity", player.physics.body.velocity);
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
    }

    // Handlers
    public function reset():Void {
        WorldCollection.reset();
        universe.reset();
		FlxG.camera.snapToTarget();
    }

    public function collectWorld(worldDef:WorldDef):Void {
        var foundState = new PieceFoundState(worldDef);

		function collectWorld() {
			persistentUpdate = false;
			Phys.FORCE_TIMESTEP = 0;    //TODO: LD quick hack to pause physics sim
			foundState.closeCallback = () -> {
				Phys.FORCE_TIMESTEP = null;
				persistentUpdate = true;
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
            new FlxTimer().start(0.5, (_) -> this.showText("[Drag & Drop]", 2, uiGroup));
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
	public function showText(str:String, showTime:Float = 1.65, ?group:FlxSpriteGroup):Void {
		var t = new FlxText(0, 0, 0, str, 20);
		t.font = "fairfax";
		t.y = FlxG.height - 50;
		t.screenCenter(FlxAxes.X);
		t.alpha = 0;

		if (group == null) group = uiGroup;

		FlxTween.tween(t, {alpha: 1}, 0.6, {onComplete: (_) -> {
			FlxTween.tween(t, {alpha: 0}, 0.6, {startDelay: showTime, onComplete: (_) -> {
				group.remove(t);
				t.destroy();
			}});
		}});

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
