package states;

import config.Config;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.MiniWorld;
import game.WorldCollection;
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

class PlayState extends LycanState {
    public var player:Player;
    public var world:MiniWorld;
	public var cameraFocus:CameraFocus;
    public var reloadPlayerPosition:Bool;

    // For transition effects
    public var timeFactor(default, set):Float = 1;

    // World Editing related
    public var isWorldEditing:Bool = false;
    public var editingTransitionAmount(default, set):Float = 0;

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
        player = new Player(0, 0, Config.PLAYER_WIDTH, Config.PLAYER_HEIGHT);
        initWorld();
        add(player);
        initCamera();
    }

    private function initPhysics():Void {
        // Initialize physics
        Phys.init();
        PlatformerPhysics.setupPlatformerPhysics();

        // Setup gravity
        Phys.space.gravity.setxy(0, Config.GRAVITY);
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

        var actionBeginWorldEditing = new FlxActionDigital("BeginWorldEditing", this.beginWorldEditing);
        actionBeginWorldEditing.addMouseWheel(false, FlxInputState.JUST_PRESSED);

        var actionEndWorldEditing = new FlxActionDigital("EndWorldEditing", this.endWorldEditing);
        actionEndWorldEditing.addMouseWheel(true, FlxInputState.JUST_PRESSED);

        var actionToggleWorldEditing = new FlxActionDigital("ToggleWorldEditing", this.toggleWorldEditing);
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
		interp.variables.set("wait", function(delay:Float, cb:Void->Void) new FlxTimer(timers).start(delay, (_)->cb()));
    }

    private function initWorld():Void {
        var worldDef = WorldCollection.get("world1");
        for (layer in worldDef.tiledMap.layers) {
            if (Std.is(layer, TiledObjectLayer)) {
                var ol:TiledObjectLayer = cast layer;
                for (o in ol.objects) {
                    if (o.type == "player") {
                        player.physics.body.position.setxy(o.x+ Config.PLAYER_WIDTH / 2, o.y + Config.PLAYER_HEIGHT / 2);
                        player.physics.snapEntityToBody();
                        break;
                    }
                }
            }
        }
        world = new MiniWorld();
        world.worldDef = worldDef;
        WorldLoader.load(world, new TiledMap(worldDef.path), this, worldCamera.scroll.x, worldCamera.scroll.y);
        add(world);
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

    override public function update(elapsed:Float):Void {
        @:privateAccess actions.update();

        super.update(elapsed);
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
    }

    public function beginWorldEditing(action:FlxActionDigital):Void {
    }

    public function endWorldEditing(action:FlxActionDigital):Void {

    }

    public function toggleWorldEditing(action:FlxActionDigital):Void {
        if (isWorldEditing) {
            endWorldEditing(action);
        } else {
            beginWorldEditing(action);
        }
    }
    
    // Setters
	private function set_timeFactor(val:Float):Float {
		this.timeFactor = val;
		// TODO: better solution for this
		Phys.forceTimestep = (val == 0) ? null : FlxG.elapsed * timeFactor;
		return val;
    }
    
    private function set_editingTransitionAmount(val:Float):Float {
		this.editingTransitionAmount = val;

		worldCamera.zoom = FlxMath.lerp(Config.DEFAULT_ZOOM, Config.WORLD_EDITING_ZOOM, val);
		worldCamera.targetOffset.y = Config.CAMERA_OFFSET_Y - val * 60;

		// music.volume = Math.max(0.01, 1 - val);
		// musicLowPass.volume = Math.max(0.01, val);

		// TODO: better solution for this
		Phys.forceTimestep = (val == 0) ? null : FlxG.elapsed * timeFactor;

		return val;
	}
}
