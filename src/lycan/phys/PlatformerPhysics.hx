package lycan.phys;

import nape.geom.Geom;
import nape.dynamics.Contact;
import nape.shape.Polygon;
import nape.dynamics.InteractionFilter;
import nape.shape.Shape;
import flixel.FlxG;
import nape.callbacks.PreCallback;
import nape.callbacks.PreListener;
import nape.callbacks.InteractionCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import lycan.world.components.Groundable;
import nape.phys.Body;
import nape.dynamics.CollisionArbiter;
import flixel.math.FlxAngle;
import lycan.world.components.CharacterController;
import nape.space.Space;
import nape.dynamics.InteractionGroup;
import nape.geom.Vec2;
import nape.geom.Vec3;
import sprites.DamagerSprite;

// TODO could be PhysicsPresets?
class PlatformerPhysics {
	// Callback types
	public static var COLLISION_TYPE:CbType = new CbType();
	public static var GROUNDABLE_TYPE:CbType = new CbType();
	public static var CHARACTER_TYPE:CbType = new CbType();
	public static var ONEWAY_TYPE:CbType = new CbType();
	public static var PUSHABLE_TYPE:CbType = new CbType();
	public static var MOVING_PLATFORM_TYPE:CbType = new CbType();
	
	// Interaction groups
	public static var OVERLAPPING_OBJECT_GROUP:InteractionGroup = new InteractionGroup(true);

	// Interaction Filters
	public static var WORLD_FILTER:InteractionFilter = new InteractionFilter();
	public static var OVERLAPPING_OBJECT_FILTER:InteractionFilter = new InteractionFilter();
	
	private static var isSetup:Bool = false;
	
	public static function setupPlatformerPhysics(?space:Space):Void {
		if (space == Phys.space) {
			if (isSetup) {
				return;
			} else {
				isSetup = true;
			}
		}
		
		space = space == null ? Phys.space : space;
		WORLD_FILTER.collisionGroup = 1;
		WORLD_FILTER.collisionMask  = ~1;
		OVERLAPPING_OBJECT_FILTER.collisionGroup = 2;
		OVERLAPPING_OBJECT_FILTER.collisionMask  = 1 | 2;

		// Character controller drop-through one way
		space.listeners.add(
			new PreListener(InteractionType.COLLISION, CHARACTER_TYPE, ONEWAY_TYPE,
				function(ic:PreCallback):PreFlag {
					var body:Body = ic.int1.castBody;
					var p:CharacterController = cast body.userData.entity;
					if (p.characterController.dropThrough) {
						return PreFlag.IGNORE;
					} else {
						return null;
					}
				}, 1
			)
		);

		space.listeners.add(
			new PreListener(InteractionType.COLLISION, CHARACTER_TYPE, Phys.TILEMAP_SHAPE_TYPE, (cb:PreCallback) -> {
				if (cb.int1.userData.entity != null && Std.is(cb.int1.userData.entity, CharacterController)) {
					var player:CharacterController = cast cb.int1.userData.entity;

					if (!cb.arbiter.isCollisionArbiter()) return null;
					var ca:CollisionArbiter = cast cb.arbiter;
					var angle:Float = Math.abs(FlxAngle.TO_DEG * ca.normal.angle);
					// TODO: use more appropriate handle way
					if (angle > 90 + 2 || angle < 90 - 2) {
						player.characterController.stop();
					}
				}
				// We don't need to change the acceptance
				return PreFlag.ACCEPT_ONCE;
			})
		);
		
		// Avoid vertical friction on grounds
		// TODO could we merge this with groun checks?
		space.listeners.add(
			new PreListener(InteractionType.COLLISION, CHARACTER_TYPE, CbType.ANY_BODY,
				function(ic:PreCallback):PreFlag {
					var body:Body = ic.int1.castBody;
					var groundable:Groundable = cast body.userData.entity;
					var arbiter = ic.arbiter;
					
					if (!arbiter.isCollisionArbiter()) return null;
					var ca:CollisionArbiter = cast arbiter;
					var angle:Float = FlxAngle.TO_DEG * ca.normal.angle - (arbiter.body1 == body ? 90 : -90);
					
					if (!(angle >= -groundable.groundable.groundedAngleLimit && angle <= groundable.groundable.groundedAngleLimit)) {
						ca.dynamicFriction = 0;
						ca.staticFriction = 0;
					}
					
					// We don't need to change the acceptance
					return PreFlag.IGNORE;  //TODO： fights oneways?
				}
			)
		);
		
		// One way platforms
		// TODO should use accept/ignore_once?
		// TODO don't hardcode the angles
		space.listeners.push(
			new PreListener(InteractionType.COLLISION, CbType.ANY_BODY, ONEWAY_TYPE,
				function(ic:PreCallback):PreFlag {
					var groundable:Groundable = ic.int1.userData.sprite;
					var arbiter:CollisionArbiter = cast ic.arbiter;
					var angle:Float = FlxAngle.TO_DEG * arbiter.normal.angle;
					if (angle >= 45 && angle <= 135 ) {
						return null;
					}
					return PreFlag.IGNORE;
				}, 2
			)
		);
		
	}
}