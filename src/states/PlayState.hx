package states;

import config.Constant;
import flixel.FlxState;
import flixel.FlxG;
import sprites.Player;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionSet;
import flixel.input.actions.FlxActionManager;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;

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

        // load map
        map = new TiledMap(AssetPaths.test__tmx);
        mWalls = new FlxTilemap();
        mWalls.loadMapFromArray(cast(map.getLayer("tiles"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.Sprute__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 3);
        mWalls.follow();
        mWalls.setTileProperties(19, FlxObject.ANY);
        mWalls.setTileProperties(36, FlxObject.ANY);
        add(mWalls);

        // creat player, put it at the correct position on the map
        player = new Player(0, 0, 16, 16);
        player.physics.snapEntityToBody();
        player.physics.enabled = true;
        add(player);
        var tmpMap:TiledObjectLayer = cast map.getLayer("entities");
        for (e in tmpMap.objects) {
            placeEntities(e.name, e.xmlData.x);
        }
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

    private function initPhysics():Void {
        // Initialize physics
        Phys.init();
        PlatformerPhysics.setupPlatformerPhysics();

        // Setup gravity
        Phys.space.gravity.setxy(0, Constant.gravity);
    }
}
