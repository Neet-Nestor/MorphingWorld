package sprites;

import nape.phys.BodyType;
import flixel.util.FlxColor;
import config.Config;

class Door extends PhysSprite {
    public function new() {
        super();
        makeGraphic(Config.TILE_SIZE, Config.TILE_SIZE * 2, FlxColor.WHITE);
        physics.init(BodyType.KINEMATIC);
        physics.body.userData.entity = this;
    }
}