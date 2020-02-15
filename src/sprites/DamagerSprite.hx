package sprites;

import nape.phys.BodyType;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.phys.PlatformerPhysics;
import lycan.world.components.PhysicsEntity;
import nape.callbacks.CbType;

class DamagerSprite extends LSprite implements PhysicsEntity {
	public static var DAMAGER_TYPE:CbType = new CbType();
	
	public function new(?bodyType) {
        if (bodyType == null) bodyType = BodyType.STATIC;

		super();
		
        physics.init(bodyType, false);
        physics.enabled = true;
		physics.body.userData.entity = this;
        physics.body.cbTypes.add(DAMAGER_TYPE);
	}
	
}