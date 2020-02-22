package sprites;

import nape.phys.BodyType;
import flixel.util.FlxColor;
import config.Config;

class Door extends PhysSprite {
    public var name:String;

    public function new(name:String) {
        super();
        this.name = name;
        makeGraphic(Config.TILE_SIZE, Config.TILE_SIZE * 2, FlxColor.WHITE);
        physics.init(BodyType.KINEMATIC);
        physics.body.userData.entity = this;
    }
}