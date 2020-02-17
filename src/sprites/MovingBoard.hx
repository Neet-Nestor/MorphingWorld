package sprites;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import lycan.world.components.PhysicsEntity;
import nape.constraint.WeldJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.shape.Shape;

class MovingBoard extends Board {
	public function new() {
		super(BodyType.KINEMATIC);
		physics.body.allowRotation = false;
		physics.enableUpdate = false;
	}
	
	override public function update(dt:Float):Void {
        super.update(dt);
        physics.snapBodyToEntity();
	}
}
