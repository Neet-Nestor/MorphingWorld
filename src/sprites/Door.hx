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
        loadGraphic(AssetPaths.door__png, true, Config.TILE_SIZE, Config.TILE_SIZE * 2);
        animation.add("opened", [0], 0);
        animation.add("closed", [1], 0);
        physics.init(BodyType.KINEMATIC);
        physics.body.userData.entity = this;
        animation.play("closed");
    }

    public function open():Void {
        animation.play("opened");
        physics.enabled = false;
    }

    public function close():Void {
        animation.play("closed");
        physics.enabled = false;
    }

    override public function kill():Void {
        super.kill();
        physics.enabled = false;
    }

    override public function revive():Void {
        super.revive();
        physics.enabled = true;
        animation.play("closed");
    }

    override public function destroy():Void {
        super.destroy();
        physics.destroy();
    }
}