package sprites;

import lycan.components.CenterPositionable;
import lycan.components.Attachable;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import lycan.world.components.CharacterController;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite implements Attachable implements CharacterController implements Groundable implements CenterPositionable implements PhysicsEntity implements  PhysicsEntity {
    private static final FRAME_PER_ROW:Int = 13;

    public var speed:Float = 200;

    public function new(x:Float, y:Float, width:Int, height:Int) {
		super(x, y);

		// GraphicUtil.makePlaceholderGraphic(this, "player", width, height, [
		// 	{name: "idle", frameCount: 4},
		// 	{name: "run", frameCount: 8},
		// 	{name: "jump", frameCount: 1},
    	// 	{name: "zeroG", frameCount: 1},
		// 	{name: "fall", frameCount: 1}
		// ], FlxColor.WHITE, 10);
		
		animation.add("idle", [for (i in 0...4) i], 10, true);
		animation.add("run", [for (i in 8...16) i], 12, true);
		animation.add("jump", [16], 12);
		animation.add("zeroG", [17], 12);
		animation.add("fall", [18], 12);
		offset.set(0, (64 - height) / 2 - 2);
		
		characterController.init(width, height);
		characterController.moveAcceleration = 0.2;
		characterController.runSpeed = 200;
		characterController.jumpSpeed = -300;
		characterController.maxJumpVelY = 50;
		characterController.minMoveVel = 8;
		characterController.maxJumps = 1;
		
		groundable.groundedAngleLimit = 65;
		
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);
	}

    public function updateVelocity():Void {
        var up:Bool = false;
        var down:Bool = false;
        var left:Bool = false;
        var right:Bool = false;

        up = FlxG.keys.anyPressed([UP, W]);
        down = FlxG.keys.anyPressed([DOWN, S]);
        left = FlxG.keys.anyPressed([LEFT, A]);
        right = FlxG.keys.anyPressed([RIGHT, D]);

        if (up && down)
            up = down = false;
        if (left && right)
            left = right = false;

        if (up || down || left || right) {
            var mA:Float = 0;
            if (up) {
                mA = -90;
                if (left)
                    mA -= 45;
                else if (right)
                    mA += 45;
                facing = FlxObject.UP;
            } else if (down) {
                mA = 90;
                if (left)
                    mA += 45;
                else if (right)
                    mA -= 45;
                facing = FlxObject.DOWN; // the sprite is facing DOWN
            } else if (left) {
                mA = 180;
                facing = FlxObject.LEFT; // the sprite should be facing LEFT
            } else if (right) {
                mA = 0;
                facing = FlxObject.RIGHT; // set the sprite's facing to RIGHT
            }

            velocity.set(speed, 0);
            velocity.rotate(FlxPoint.weak(0, 0), mA);
        }

        if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) {
            animation.play("run");
        } else {
            animation.play("stand");
        }
    }

    override public function update(elapsed:Float):Void {
        updateVelocity();
        super.update(elapsed);
    }
}