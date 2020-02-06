package sprites;

import config.Constant;
import lycan.util.GraphicUtil;
import lycan.components.CenterPositionable;
import lycan.components.Attachable;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import lycan.world.components.CharacterController;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class Player extends FlxSprite implements Attachable implements CharacterController implements Groundable implements CenterPositionable implements PhysicsEntity implements  PhysicsEntity {
    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);

        loadGraphic(AssetPaths.player__png, true, Constant.playerWidth, Constant.playerHeight);
		GraphicUtil.makePlaceholderGraphic(this, "player", width, height, [
			{name: "idle", frameCount: 0},
			{name: "run", frameCount: Constant.playerFramePerRow},
			{name: "jump", frameCount: 5 * Constant.playerFramePerRow},
			{name: "fall", frameCount: 6 * Constant.playerFramePerRow}
        ], FlxColor.WHITE, 10);

		animation.add("idle", [for (i in 0...Constant.playerFramePerRow) i], 10, true);
		animation.add("run", [for (i in Constant.playerFramePerRow...Constant.playerFramePerRow + 8) i], 12, true);
		animation.add("jump", [for (i in 5 * Constant.playerFramePerRow...5 * Constant.playerFramePerRow + 6) i], 12);
		animation.add("fall", [for (i in 6 * Constant.playerFramePerRow...6 * Constant.playerFramePerRow + 4) i], 12);
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

	override public function revive():Void {
		super.revive();
	}

	override public function destroy():Void {
		super.destroy();
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		// Cheap crushing, probably full of problems
		// var ti = physics.body.totalContactsImpulse();
		// if (ti.length > 2500) kill();
		// ti.dispose();
	}

	override private function updateAnimation(dt:Float):Void {
		var body = physics.body;
		var velocity = body.velocity;

		var cc = characterController;

		if (cc.targetMoveVel > 0) {
			facing = FlxObject.RIGHT;
		} else if (cc.targetMoveVel < 0) {
			facing = FlxObject.LEFT;
		}

		if (groundable.isGrounded) {
			if (cc.targetMoveVel > 0) {
				animation.play("run");
			} else if (cc.targetMoveVel < 0) {
				animation.play("run");
			} else {
				animation.play("idle");
			}
		} else {
			if (velocity.y > 100) {
				animation.play("fall");
			} else if (velocity.y < -100) {
				animation.play("jump");
			} else {
				animation.play("idle");
			}
		}

		super.updateAnimation(dt);
	}
}