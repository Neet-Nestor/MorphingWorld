package lycan.world.components;

import lycan.components.Entity;
import flixel.FlxObject;
import lycan.components.Component;

// TODO generalise to multiple states
interface Switchable extends Entity {
	public var switcher:SwitchComponent;
}

class SwitchComponent extends Component<Switchable> {
	public var on(default, set):Bool;
	
	public var onCallback:SwitchComponent -> Void;
	public var offCallback:SwitchComponent -> Void;
	
	public function new(entity:Switchable) {
		super(entity);
	}
	
	public function toggle():Void {
		on = !on;
	}
	
	private function set_on(on:Bool):Bool {
		if (this.on == on) return on;
		
		this.on = on;
		if (on) {
			onCallback(this);
		} else {
			offCallback(this);
		}
		
		return on;
	}
}