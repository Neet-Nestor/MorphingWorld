package sprites;

import flixel.system.debug.watch.Tracker.TrackerProfile;
import nape.phys.Material;
import flixel.FlxG;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.phys.Body;
import lycan.phys.PlatformerPhysics;
import nape.callbacks.CbType;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import nape.phys.BodyType;
import lycan.util.GraphicUtil;
import lycan.world.components.PhysicsEntity;
import lycan.game3D.components.Physics3D;
import lycan.entities.LSprite;
import lycan.world.components.Groundable;

class Crate extends LSprite implements PhysicsEntity implements Groundable {
	public static var PUSHABLE_TYPE:CbType = new CbType();
	public static var CRATE_TYPE:CbType = new CbType();
	public static var CRATE_MATERIAL:Material = new Material(0, 0.3, 0.05, 0.3);
	
	public function new() {
		super();

		loadGraphic(AssetPaths.crate__png);

		physics.init(BodyType.DYNAMIC);
		physics.body.allowRotation = false;
		physics.body.setShapeMaterials(CRATE_MATERIAL);
		physics.body.cbTypes.add(PUSHABLE_TYPE);
		physics.body.cbTypes.add(CRATE_TYPE);
		physics.body.cbTypes.add(PlatformerPhysics.GROUNDABLE_TYPE);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (!groundable.isGrounded) {
			physics.body.velocity.x = 0;
		}
	}
}