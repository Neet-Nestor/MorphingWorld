package sprites;

import flixel.math.FlxPoint;
import config.Config;
import lycan.components.CenterPositionable;
import lycan.components.Attachable;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import lycan.world.components.CharacterController;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite implements CharacterController implements Groundable implements PhysicsEntity implements Attachable implements CenterPositionable {
    public function new(x:Float, y:Float, width:Int, height:Int) {
        super(x, y);

        loadGraphic(AssetPaths.player__png, true, Config.PLAYER_WIDTH, Config.PLAYER_HEIGHT);

		animation.add("idle", [for (i in 0...Config.PLAYER_FRAME_PER_ROW) i], 10, true);
		animation.add("run", [for (i in Config.PLAYER_FRAME_PER_ROW...Config.PLAYER_FRAME_PER_ROW + 8) i], 12, true);
		animation.add("jump", [for (i in 5 * Config.PLAYER_FRAME_PER_ROW...5 * Config.PLAYER_FRAME_PER_ROW + 6) i], 12);
		animation.add("fall", [for (i in 6 * Config.PLAYER_FRAME_PER_ROW...6 * Config.PLAYER_FRAME_PER_ROW + 4) i], 12);

		characterController.init(width, height);
		characterController.moveAcceleration = 0.2;
		characterController.runSpeed = 100;
		characterController.jumpSpeed = -200;
		characterController.maxJumpVelY = 50;
		characterController.minMoveVel = 8;
		characterController.maxJumps = 2;
		// origin = FlxPoint.weak(x, y);

		groundable.groundedAngleLimit = 65;
		
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);
	}

	public function resetCc():Void {
		characterController.destroy();
		characterController = new CharacterControllerComponent(this);
		characterController.init(width, height);
		characterController.moveAcceleration = 0.2;
		characterController.runSpeed = 100;
		characterController.jumpSpeed = -200;
		characterController.maxJumpVelY = 50;
		characterController.minMoveVel = 8;
		characterController.maxJumps = 2;
	}

	override public function revive():Void {
		super.revive();
	}

	override public function destroy():Void {
		super.destroy();
	}

	override public function update(dt:Float):Void {
		super.update(dt);

		// Update location
		physics.body.position.x += dt * characterController.currentMoveVel;
		physics.body.position.y += dt * physics.body.velocity.y;
		physics.snapEntityToBody();
	}

	override private function updateAnimation(dt:Float):Void {
		var body = physics.body;
		var velocity = body.velocity;

		var cc = characterController;
		if (groundable.isGrounded) {
			if (cc.currentMoveVel > 0) {
				animation.play("run");
			} else if (cc.currentMoveVel < 0) {
				animation.play("run");
			} else {
				animation.play("idle");
			}
		} else {
			if (velocity.y > 0) {
				animation.play("fall");
			} else {
				animation.play("jump");
			}
		}
		super.updateAnimation(dt);
	}
}