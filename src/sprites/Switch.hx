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

class Switch extends LSprite implements PhysicsEntity implements Switchable {
    public static var SWITCH_TYPE:CbType = new CbType();

    public var type:SwitchType;
    public var targetName:String;
	
	public function new(targetName:String, type:SwitchType = ONCE) {
		super();
		
        this.type = type;
        this.targetName = targetName;
		
        // loadGraphic("AssetPaths.switch__png", true, Config.TILE_SIZE, Config.TILE_SIZE);
		// animation.add("off", [0], 0, false);
        // animation.add("on", [1], 0, false);
        makeGraphic(Config.TILE_SIZE, Config.TILE_SIZE, FlxColor.RED);
		
		physics.init(BodyType.STATIC);
        physics.body.userData.entity = this;
        physics.body.cbTypes.add(SWITCH_TYPE);
        physics.body.shapes.at(0).sensorEnabled = true;

        switcher.onCallback = (s) -> {
            makeGraphic(Config.TILE_SIZE, Config.TILE_SIZE, FlxColor.BLUE);
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
                    if (Std.is(obj, Switch)) {
                        // On other switches
                        var sw:Switch = cast obj;
                        if (sw.targetName == targetName) {
                            sw.switcher.on = switcher.on;
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