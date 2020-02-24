package lycan.world.components;

import flixel.util.FlxTimer;
import sprites.MovingBoard;
import flixel.system.FlxSound;
import nape.dynamics.InteractionFilter;
import flixel.FlxBasic.FlxType;
import nape.geom.ConvexResult;
import nape.phys.Body;
import flixel.math.FlxMath;
import lycan.phys.PlatformerPhysics;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.shape.Circle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import lycan.world.layer.PhysicsTileLayer;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.util.GraphicUtil;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import nape.shape.Shape;
import nape.phys.BodyType;
import lycan.phys.Phys;
import lycan.components.Entity;
import lycan.components.Component;
import flixel.FlxObject;
import nape.constraint.LineJoint;
import flixel.FlxSprite;
import Sound;

interface CharacterController extends Entity {
	public var characterController:CharacterControllerComponent;
	public var physics:PhysicsComponent;
	public var groundable:GroundableComponent;
}

@:tink
class CharacterControllerComponent extends Component<CharacterController> {
	@:forward var _object:FlxSprite;
	@:calc var physics:PhysicsComponent = entity.physics;

	public var targetMoveVel:Float = 0;
	public var currentMoveVel:Float = 0;
	public var moveAcceleration:Float = 0.4;
	public var stopAcceleration:Float = 0.2;
	public var minMoveVel:Float = 20;
	@:calc public var isMoving:Bool = targetMoveVel != 0;

	public var jumpSpeed:Float = -900;
	public var runSpeed:Float = 600;
	public var maxJumps:Int = 2;
	public var airDrag:Float = 5000;
	public var groundSuckDistance:Float = 2;

	public var dropThrough:Bool = false;
	public var dropThroughCancelTimer:FlxTimer;

	/** Indicates how in control the character is. Applies high drag while in air. */
	public var hasControl:Bool;
	public var currentJumps:Int;
	public var canJump:Bool;

	// About on moving platform
	public var onMovingPlatform:Bool;
	public var movingPlatform:MovingBoard;

	// Whether left or right key is pressed
	public var leftPressed:Bool = false;
	public var rightPressed:Bool = false;

	// State
	public var isSliding:Bool = false;

	//var movingPlatforms:Array<MovingPlatform>;
	//var currentMovingPlatform:MovingPlatform;

	public var _sndStep:FlxSound;
	public var _sndJump1:FlxSound;
    public var _sndJump2:FlxSound;

	public var anchor:Body;
	public var anchorJoint:LineJoint;

	public function new(entity:CharacterController) {
		super(entity);
		_object = cast entity;
	}

	public function init(?width:Float, ?height:Float):Void {
		if (width == null) width = _object.width;
		if (height == null) height = _object.height;

		physics.init(BodyType.DYNAMIC, false);
		physics.createRectangularBody(width, height);
		physics.body.position.setxy(x, y);
		physics.body.userData.entity = entity;
		physics.body.allowRotation = false;
		physics.body.group = PlatformerPhysics.OVERLAPPING_GROUP;
		physics.body.setShapeFilters(PlatformerPhysics.CHARACTER_FILTER);

		physics.body.isBullet = true;

		anchor = new Body(BodyType.STATIC);
		anchor.space = physics.body.space;

		anchorJoint = new LineJoint(anchor, physics.body, anchor.worldPointToLocal(Vec2.get(0.0, 0.0)),
			physics.body.worldPointToLocal(Vec2.get(0.0, 0.0)), Vec2.weak(0.0, 1.0), Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		anchorJoint.stiff = false;
		anchorJoint.maxError = 0.0;
		anchorJoint.space = physics.body.space;

		hasControl = true;
		currentJumps = 0;

		physics.body.cbTypes.add(PlatformerPhysics.CHARACTER_TYPE);
		physics.body.cbTypes.add(PlatformerPhysics.GROUNDABLE_TYPE);

		_sndStep = _sndStep = FlxG.sound.load(AssetPaths.step__wav);
		_sndJump1 = FlxG.sound.load(AssetPaths.jump1__wav);
		_sndJump2 = FlxG.sound.load(AssetPaths.jump2__wav);
	}

	@:append("destroy")
	public function destroy():Void {
		anchor.space = null;
		anchorJoint.space = null;
		_object = null;
	}

	@:prepend("update")
	public function update(dt:Float):Void {
		var body:Body = physics.body;
		var groundable:GroundableComponent = entity.groundable;

		//TODO test this attempt to only anchor if we are trying to move
		//TODO stop is duplicating airdrag functionality! oops
		anchorJoint.active = hasControl && Math.abs(currentMoveVel) > 0;

		// Compute groundedness only when not jumpping
		// Clear previous grounds
		if (body.velocity.y >= 0) {
			var oldVel:Vec2 = physics.body.velocity.copy(true);
			physics.body.velocity.setxy(0, 1);

			var result:ConvexResult = null;
			physics.body.position.y--;
			result = Phys.space.convexCast(physics.body.shapes.at(0), 2, false, physics.body.shapes.at(0).filter);
			if (result != null && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90) <= groundable.groundedAngleLimit) {
				var groundEntity = result.shape.body.userData.entity;
				groundable.add(groundEntity);
				if (Std.is(result.shape.body.userData.entity, MovingBoard)) {
					var mb:MovingBoard = cast result.shape.body.userData.entity;
					onMovingPlatform = true;
					movingPlatform = mb;
				} else {
					onMovingPlatform = false;
					movingPlatform = null;
				}
			}
			physics.body.position.y++;

			if (result == null) {
				// For moving down platforms
				physics.body.position.y++;
				result = Phys.space.convexCast(physics.body.shapes.at(0), 1, false, physics.body.shapes.at(0).filter);
				if (result != null && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90) <= groundable.groundedAngleLimit) {
					var groundEntity = result.shape.body.userData.entity;
					groundable.add(groundEntity);
					if (Std.is(result.shape.body.userData.entity, MovingBoard)) {
						var mb:MovingBoard = cast result.shape.body.userData.entity;
						onMovingPlatform = true;
						movingPlatform = mb;
					} else {
						onMovingPlatform = false;
						movingPlatform = null;
					}
				}
				physics.body.position.y--;
			}

			if (result == null) {
				// For moving up platforms
				physics.body.position.y -= 2;
				result = Phys.space.convexCast(physics.body.shapes.at(0), 1, false, physics.body.shapes.at(0).filter);
				if (result != null && Math.abs(result.normal.angle * FlxAngle.TO_DEG + 90) <= groundable.groundedAngleLimit) {
					var groundEntity = result.shape.body.userData.entity;
					groundable.add(groundEntity);
					if (Std.is(result.shape.body.userData.entity, MovingBoard)) {
						var mb:MovingBoard = cast result.shape.body.userData.entity;
						onMovingPlatform = true;
						movingPlatform = mb;
					} else {
						onMovingPlatform = false;
						movingPlatform = null;
					}
				}
				physics.body.position.y += 2;
			}

			if (result == null) {
				// we failed :(
				onMovingPlatform = false;
				movingPlatform = null;
			}
			physics.body.velocity.set(oldVel);
		}

		// Moving Left/Right
		if (hasControl) {
			if (leftPressed != rightPressed) {
				// if (groundable.isGrounded) Main.sound.playSound(Effect.Step, Main.user.getSettings().sound);
				if (groundable.isGrounded && Main.user.getSettings().sound) {
					_sndStep.play();
				}
				targetMoveVel = leftPressed ? -runSpeed : runSpeed;
				move();
			} else {
				if (Math.abs(currentMoveVel) > 0) stop();
			}
		}
		
		// Ground friction
		var groundable:GroundableComponent = entity.groundable;
		FlxG.watch.addQuick("grounded", groundable.isGrounded);
		if (groundable.isGrounded && !isMoving) {
			body.shapes.at(0).material.dynamicFriction = 100;
			body.shapes.at(0).material.staticFriction = 100;
		} else {
			body.shapes.at(0).material.dynamicFriction = 0;
			body.shapes.at(0).material.staticFriction = 0;
		}

		if (groundable.isGrounded) {
			currentJumps = 0;
			canJump = true;
		}

		if (currentJumps >= maxJumps) {
			canJump = false;
		}
		if (hasControl && FlxG.keys.anyPressed([FlxKey.S, FlxKey.DOWN])) {
			if (dropThroughCancelTimer != null) {
				// Cancel it
				dropThroughCancelTimer.cancel();
				dropThroughCancelTimer.destroy();
				dropThroughCancelTimer = null;
			}
			dropThrough = true;
		} else {
			if (dropThrough && dropThroughCancelTimer == null) {
				// Give it a little bit delay to avoid bouncing back
				dropThroughCancelTimer = new FlxTimer().start(0.2, (_) -> {
					dropThrough = false;
					dropThroughCancelTimer = null;
				});
			} 
		}
		FlxG.watch.addQuick("onMovingPlatform", onMovingPlatform);
		FlxG.watch.addQuick("targetMoveVel", targetMoveVel);
		FlxG.watch.addQuick("currentMoveVel", currentMoveVel);
		FlxG.watch.addQuick("friction", body.shapes.at(0).material.dynamicFriction);
		FlxG.watch.addQuick("hasControl", hasControl);
		FlxG.watch.addQuick("Jumps left", maxJumps - currentJumps);
	}

	public function move():Void {
		isSliding = false;
		currentMoveVel += moveAcceleration * (targetMoveVel - currentMoveVel);

		if (Math.abs(currentMoveVel) < minMoveVel) {
			currentMoveVel = 0;
		}

		facing = currentMoveVel < 0 ? FlxObject.LEFT : FlxObject.RIGHT;
		anchor.kinematicVel.x = currentMoveVel;
	}

	public function stop():Void {
		targetMoveVel = 0;
		// TODO probably issues with this method when running into a wall as walls don't zero it
		currentMoveVel = 0;

		if (Math.abs(currentMoveVel) < minMoveVel) {
			currentMoveVel = 0;
			isSliding = false;
		}

		anchor.kinematicVel.x = currentMoveVel;
	}

	public function run():Void {}

	public function jump():Void {
		if (hasControl && canJump) {
			if (Main.user.getSettings().sound) {
				if (currentJumps % 2 == 0) {
					// Main.sound.playSound(Effect.Jump1, Main.user.getSettings().sound);
					// trace(Main.user.getSettings().sound);
					_sndJump1.play();
				} else {
					// Main.sound.playSound(Effect.Jump2, Main.user.getSettings().sound);
					_sndJump2.play();
				}
			}
			currentJumps++;
			physics.body.velocity.y = jumpSpeed;
		}
	}
}