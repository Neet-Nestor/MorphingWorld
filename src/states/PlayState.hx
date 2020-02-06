package states;

import flixel.FlxState;
import sprites.Player;
import lycan.phys.Phys;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionSet;
import flixel.input.actions.FlxActionManager;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;

class PlayState extends FlxState {
    private var player:Player;

	public var actionStart:FlxActionDigital;
	public var actionJump:FlxActionDigital;
	public var actionFlap:FlxActionDigital;
	public var actionLeft:FlxActionDigital;
	public var actionRight:FlxActionDigital;
	var actions:FlxActionManager;

    override public function create():Void {

		persistentDraw = true;
        persistentUpdate = true;

        super.create();
        initPhysics();

		// Actions
		actions = new FlxActionManager();

        // Player actions
        actionJump = new FlxActionDigital("Jump", (_) -> player.characterController.jump());
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
        actionLeft.addKey(FlxKey.LEFT, FlxInputState.PRESSED);
        actionLeft.addKey(FlxKey.A, FlxInputState.PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.DPAD_LEFT, FlxInputState.PRESSED);
        actionLeft.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT, FlxInputState.PRESSED);

        actionRight = new FlxActionDigital("Right", (_) -> {
            player.characterController.rightPressed = true;
        });
        actionRight.addKey(FlxKey.RIGHT, FlxInputState.PRESSED);
        actionRight.addKey(FlxKey.D, FlxInputState.PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.DPAD_RIGHT, FlxInputState.PRESSED);
        actionRight.addGamepad(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT, FlxInputState.PRESSED);
        actions.addActions([actionLeft, actionRight, actionJump]);

        player = new Player(16, 16, 16, 16);
        add(player);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function initPhysics():Void {
        Phys.init();
    }
}
