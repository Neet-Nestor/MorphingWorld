package sprites;

import lycan.world.components.PhysicsEntity;
import lycan.entities.LSprite;
import nape.phys.BodyType;
import flixel.util.FlxColor;
import config.Config;

class Door extends LSprite implements PhysicsEntity {
    public var name:String;

    public function new(name:String) {
        super();
        this.name = name;
        makeGraphic(Config.TILE_SIZE, Config.TILE_SIZE * 2, FlxColor.WHITE);
        physics.init(BodyType.KINEMATIC);
        physics.body.userData.entity = this;
    }

    override public function kill():Void {
        super.kill();
        physics.enabled = false;
    }

    override public function revive():Void {
        super.revive();
        physics.enabled = true;
    }

    override public function destroy():Void {
        super.destroy();
        physics.destroy();
    }
}