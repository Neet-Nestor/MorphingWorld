package sprites;

import nape.callbacks.CbType;
import config.Config;
import flixel.util.FlxColor;
import lycan.world.components.Switchable;
import lycan.world.components.PhysicsEntity;
import lycan.entities.LSprite;
import nape.phys.BodyType;
import states.PlayState;

@:enum abstract SwitchType(String) from String to String {
	public var CONTINUOUS = "continuous";
	public var TOGGLE = "toggle";
	public var ONCE = "once";
}

class Button extends LSprite implements PhysicsEntity implements Switchable {
    public static var SWITCH_TYPE:CbType = new CbType();

    public var type:SwitchType;
    public var targetName:String;
	
	public function new(targetName:String, type:SwitchType = ONCE) {
		super();
		
        this.type = type;
        this.targetName = targetName;
		
        loadGraphic(AssetPaths.button__png, true, Config.TILE_SIZE, Config.TILE_SIZE);
		animation.add("off", [0], 0, false);
        animation.add("on", [1], 0, false);
        animation.play("off");
		
		physics.init(BodyType.STATIC);
        physics.body.userData.entity = this;
        physics.body.cbTypes.add(SWITCH_TYPE);
        physics.body.shapes.at(0).sensorEnabled = true;

        switcher.onCallback = (b) -> {
            animation.play("on");
            for (slot in PlayState.instance.universe.slots) {
                if (slot.world == null) continue;
                for (obj in slot.world.objects) {
                    if (Std.is(obj, Door)) {
                        // Open corresponding door
                        var d:Door = cast obj;
                        if (d.name == targetName) {
                            d.open();
                        }
                    }
                    if (Std.is(obj, Button)) {
                        // On other switches
                        var bt:Button = cast obj;
                        if (bt.targetName == targetName) {
                            bt.switcher.on = switcher.on;
                        }
                    }
                }
            }
        };
    }

    override public function destroy():Void {
        super.destroy();
        physics.destroy();
    }
}