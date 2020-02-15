package components;

import nape.callbacks.CbType;
import lycan.components.Component;
import lycan.world.components.PhysicsEntity;
import lycan.components.Entity;

interface Damager extends Entity {
	public var damager:DamagerComponent;
	public var physics:PhysicsComponent;
}

class DamagerComponent extends Component<Damager> {
	public static var DAMAGER_TYPE:CbType = new CbType();
	
	public var active:Bool;
	
	public function new(entity:Damager) {
		super(entity);
		active = true;
	}
	
	public function init(active:Bool = true):Void {
        this.entity.physics.body.cbTypes.add(DAMAGER_TYPE);
        trace("Damager_type = " + DAMAGER_TYPE);
        trace(this.entity.physics.body.cbTypes);
	}
}