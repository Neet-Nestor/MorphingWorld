package states;

import config.Constant;
import flixel.FlxState;
import flixel.FlxG;
import sprites.Player;
import sprites.PhysSprite;
import sprites.CameraFocus;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.phys.BodyType;
import flixel.FlxG;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionSet;
import flixel.input.actions.FlxActionManager;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.FlxCamera.FlxCameraFollowStyle;

// for map loading
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledObjectLayer;


class PlayState extends FlxState {
    private var player:Player;
    private var map:TiledMap;
    private var mWalls:FlxTilemap;

	public var fakeGround:PhysSprite;
	public var cameraFocus:CameraFocus;

	public var actionStart:FlxActionDigital;
	public var actionJump:FlxActionDigital;
	public var actionFlap:FlxActionDigital;
    public var actionLeft:FlxActionDigital;
    public var actionReleaseLeft:FlxActionDigital;
    public var actionRight:FlxActionDigital;
    public var actionReleaseRight:FlxActionDigital;
    public var actions:FlxActionManager;

    override public function create():Void {
		persistentDraw = true;
        persistentUpdate = true;

        super.create();
        initPhysics();

		// Actions
		actions = new FlxActionManager();

        // Player actions
        actionJump = new FlxActionDigital("Jump", (_) -> {
            trace("jump pressed");
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
            trace("left pressed");
            player.characterController.leftPressed = true;
        });
        actionLeft.addKey(FlxKey.LEFT, FlxInputState.JUST_PRESSED);
        actionLeft.addKey(FlxKey.A, FlxInputState.JUST_PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.JUST_PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.JUST_PRESSED);

        actionReleaseLeft = new FlxActionDigital("ReleaseLeft", (_) -> {
            trace("left released");
            player.characterController.leftPressed = false;
        });
        actionReleaseLeft.addKey(FlxKey.LEFT, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addKey(FlxKey.A, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.JUST_RELEASED);
        actionReleaseLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.JUST_RELEASED);

        actionRight = new FlxActionDigital("Right", (_) -> {
            trace("right pressed");
            player.characterController.rightPressed = true;
        });
        actionRight.addKey(FlxKey.RIGHT, FlxInputState.PRESSED);
        actionRight.addKey(FlxKey.D, FlxInputState.PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.PRESSED);

        actionReleaseRight = new FlxActionDigital("ReleaseRight", (_) -> {
            trace("right released");
            player.characterController.rightPressed = false;
        });
        actionReleaseRight.addKey(FlxKey.RIGHT, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addKey(FlxKey.D, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.JUST_RELEASED);
        actionReleaseRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.JUST_RELEASED);
        actions.addActions([actionLeft, actionRight, actionReleaseLeft, actionReleaseRight, actionJump]);

        intro();
        loadMap();

		// Camera following
		cameraFocus = new CameraFocus();
		cameraFocus.add(new ObjectTargetInfluencer(player));
		FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
		FlxG.camera.targetOffset.y = Constant.cameraOffsetY;
		FlxG.camera.snapToTarget();
    }

    public function loadMap():Void {
        map = new TiledMap(AssetPaths.test__tmx);
        mWalls = new FlxTilemap();
        mWalls.loadMapFromArray(cast(map.getLayer("tiles"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.Sprute__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 3);
        mWalls.follow();
        mWalls.setTileProperties(19, FlxObject.ANY);
        mWalls.setTileProperties(36, FlxObject.ANY);
        add(mWalls);

        var tmpMap:TiledObjectLayer = cast map.getLayer("entities");
        for (e in tmpMap.objects) {
            placeEntities(e.name, e.xmlData.x);
        }
        add(player);
    }

    private function initPhysics():Void {
        // Initialize physics
        Phys.init();
        PlatformerPhysics.setupPlatformerPhysics();

        // Setup gravity
        Phys.space.gravity.setxy(0, Constant.gravity);
    }

    public function intro():Void {
        fakeGround = new PhysSprite();
        fakeGround.makeGraphic(10, 10, 0x0, true);
		fakeGround.physics.init(BodyType.KINEMATIC, false);
		fakeGround.physics.createRectangularBody(FlxG.width * 4, 10, BodyType.KINEMATIC);
		fakeGround.physics.enabled = true;
		fakeGround.physics.body.align();
		fakeGround.physics.body.position.x = 0;
		fakeGround.physics.body.position.y = 0;
		fakeGround.physics.snapEntityToBody();

        player = new Player(0, 0, Constant.playerWidth, Constant.playerHeight);
		player.physics.snapBodyToEntity();
		player.physics.body.position.y = fakeGround.physics.body.position.y - (player.physics.body.shapes.at(0).bounds.height + fakeGround.physics.body.shapes.at(0).bounds.height) / 2;
        player.physics.snapEntityToBody();
        add(fakeGround);
        add(player);
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
        FlxG.collide(player, mWalls);
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
	}
}
