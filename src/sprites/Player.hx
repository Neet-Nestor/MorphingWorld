package sprites;

import flixel.math.FlxPoint;
import config.Config;
import lycan.components.CenterPositionable;
import lycan.components.Attachable;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import lycan.world.components.CharacterController;
import lycan.entities.LSprite;
import lycan.phys.PlatformerPhysics;
import flixel.FlxObject;

class Player extends LSprite implements CharacterController implements Groundable implements PhysicsEntity {
	public var dead:Bool;

    public function new(x:Float, y:Float, width:Int, height:Int) {
        super();

        loadGraphic(AssetPaths.player__png, true, Config.PLAYER_WIDTH, Config.PLAYER_HEIGHT);
		scale.set(Config.PLAYER_SCALE, Config.PLAYER_SCALE);

		var idleFrames = [for (_ in 0...6) 0];
		idleFrames.concat([for (i in 0...Config.PLAYER_FRAME_PER_ROW) i]);
		idleFrames.concat([for (_ in 0...6) 0]);
		animation.add("idle", idleFrames, 10, true);
		animation.add("run", [for (i in Config.PLAYER_FRAME_PER_ROW...Config.PLAYER_FRAME_PER_ROW + 8) i], 12, true);
		animation.add("jump", [for (i in 5 * Config.PLAYER_FRAME_PER_ROW...5 * Config.PLAYER_FRAME_PER_ROW + 6) i], 12);
		animation.add("fall", [for (i in 6 * Config.PLAYER_FRAME_PER_ROW...6 * Config.PLAYER_FRAME_PER_ROW + 4) i], 12);
		animation.add("die", [for (i in 7 * Config.PLAYER_FRAME_PER_ROW...7 * Config.PLAYER_FRAME_PER_ROW + 7) i], 10, false);

		characterController.init(width, height);
		characterController.moveAcceleration = 0.2;
		characterController.runSpeed = 60;
		characterController.jumpSpeed = -200;
		characterController.minMoveVel = 8;
		characterController.maxJumps = 2;

		groundable.groundedAngleLimit = 65;

		dead = false;
		
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);
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
		if (dead) {
			animation.play("die");
		} else if (groundable.isGrounded) {
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
    
    override public function destroy():Void {
		super.destroy();
		physics.destroy();
	}
}