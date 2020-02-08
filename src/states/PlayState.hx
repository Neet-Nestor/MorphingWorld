package states;

import sprites.Player;
import sprites.PhysSprite;
import sprites.CameraFocus;
import nape.phys.BodyType;
import nape.geom.Vec2;
import nape.callbacks.InteractionType;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionCallback;
import nape.callbacks.CbEvent;
import lycan.states.LycanState;
import lycan.phys.PlatformerPhysics;
import lycan.phys.Phys;
import game.WorldCollection;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.actions.FlxActionSet;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction;
import flixel.input.FlxInput.FlxInputState;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import config.Config;


class PlayState extends LycanState {
    private var player:Player;

	public var fakeGround:PhysSprite;
	public var cameraFocus:CameraFocus;
	public var reloadPlayerPosition:Bool;

	public var actionStart:FlxActionDigital;
	public var actionJump:FlxActionDigital;
	public var actionFlap:FlxActionDigital;
    public var actionLeft:FlxActionDigital;
    public var actionReleaseLeft:FlxActionDigital;
    public var actionRight:FlxActionDigital;
    public var actionReleaseRight:FlxActionDigital;
    public var actions:FlxActionManager;

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
        initActions();
        WorldCollection.init();
        initCamera();
        intro();
    }

    private function initActions():Void {
		// Actions
		actions = new FlxActionManager();

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

    private function initPhysics():Void {
        // Initialize physics
        Phys.init();
        PlatformerPhysics.setupPlatformerPhysics();

        // Setup gravity
        Phys.space.gravity.setxy(0, Config.GRAVITY);
    }

    public function intro():Void {
        fakeGround = new PhysSprite();
        fakeGround.makeGraphic(FlxG.width * 100, 10, FlxColor.WHITE);
		fakeGround.physics.init(BodyType.STATIC, false);
		fakeGround.physics.createRectangularBody(FlxG.width * 100, 10, BodyType.KINEMATIC);
		fakeGround.physics.enabled = true;
		fakeGround.physics.body.align();
		fakeGround.physics.body.position.x = 0;
		fakeGround.physics.body.position.y = 0;
		fakeGround.physics.snapEntityToBody();

        player = new Player(0, 0, Config.PLAYER_WIDTH, Config.PLAYER_HEIGHT);
		player.physics.snapBodyToEntity();
		player.physics.body.position.y = fakeGround.physics.body.position.y - (player.physics.body.shapes.at(0).bounds.height + fakeGround.physics.body.shapes.at(0).bounds.height) / 2;
        player.physics.snapEntityToBody();
        add(fakeGround);
        add(player);
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
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
	}
}
