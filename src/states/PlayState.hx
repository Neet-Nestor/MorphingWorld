package states;

import openfl.display.Tilemap;
import game.WorldLoader;
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
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.MiniWorld;
import game.WorldCollection;
import hscript.Expr;
import hscript.Interp;
import lycan.world.layer.PhysicsTileLayer;
import hscript.Parser;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.states.LycanState;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import sprites.CameraFocus;
import sprites.PhysSprite;
import sprites.Player;

class PlayState extends LycanState {
    public var player:Player;
    public var world:MiniWorld;
	public var cameraFocus:CameraFocus;
    public var reloadPlayerPosition:Bool;

    // For scripts
	public var parser:Parser;
	public var interp:Interp;

    // Actions
	public var actionStart:FlxActionDigital;
	public var actionJump:FlxActionDigital;
	public var actionFlap:FlxActionDigital;
    public var actionLeft:FlxActionDigital;
    public var actionReleaseLeft:FlxActionDigital;
    public var actionRight:FlxActionDigital;
    public var actionReleaseRight:FlxActionDigital;

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
        actionJump = new FlxActionDigital("Jump", (_) -> {
            player.characterController.jump();
        });
        actionJump.addKey(FlxKey.UP, FlxInputState.JUST_PRESSED);
        actionJump.addKey(FlxKey.X, FlxInputState.JUST_PRESSED);
        actionJump.addKey(FlxKey.Z, FlxInputState.JUST_PRESSED);
        actionJump.addKey(FlxKey.W, FlxInputState.JUST_PRESSED);
        actionJump.addGamepad(FlxGamepadInputID.DPAD_UP, FlxInputState.JUST_PRESSED);
        actionJump.addGamepad(FlxGamepadInputID.A, FlxInputState.JUST_PRESSED);
        actionJump.addGamepad(FlxGamepadInputID.B, FlxInputState.JUST_PRESSED);

        actionLeft = new FlxActionDigital("Left", (_) -> {
            player.characterController.leftPressed = true;
        });
        actionLeft.addKey(FlxKey.LEFT, FlxInputState.JUST_PRESSED);
        actionLeft.addKey(FlxKey.A, FlxInputState.JUST_PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.JUST_PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.JUST_PRESSED);

        actionReleaseLeft = new FlxActionDigital("ReleaseLeft", (_) -> {
            player.characterController.leftPressed = false;
        });
        actionReleaseLeft.addKey(FlxKey.LEFT, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addKey(FlxKey.A, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.JUST_RELEASED);

        actionRight = new FlxActionDigital("Right", (_) -> {
            player.characterController.rightPressed = true;
        });
        actionRight.addKey(FlxKey.RIGHT, FlxInputState.JUST_PRESSED);
        actionRight.addKey(FlxKey.D, FlxInputState.JUST_PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.JUST_PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.JUST_PRESSED);

        actionReleaseRight = new FlxActionDigital("ReleaseRight", (_) -> {
            player.characterController.rightPressed = false;
        });
        actionReleaseRight.addKey(FlxKey.RIGHT, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addKey(FlxKey.D, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.JUST_RELEASED);
        actions.addActions([actionLeft, actionRight, actionReleaseLeft, actionReleaseRight, actionJump]);
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
        // check for collide

        // debug
        // trace("Player: " + player.physics.body.position);
        // trace("        " + player.origin + ", " + player.x + ", " + player.y);
        // trace("        " + player.width + ", " + player.height);
        // for (tiledLayer in world.tileLayers) {
        //     var pLayer:PhysicsTileLayer = cast tiledLayer;
        //     trace("World: " + pLayer.body.position);
        //     trace("       " + pLayer.origin + ", " + pLayer.x + ", " + pLayer.y);
        //     trace("       " + pLayer.width + ", " + pLayer.height);
        // }
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
	}
}
