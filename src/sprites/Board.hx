package sprites;

import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import nape.phys.BodyType;
import flixel.math.FlxPoint;
import config.Config;
import lycan.components.CenterPositionable;
import lycan.components.Attachable;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import lycan.world.components.CharacterController;
import lycan.phys.PlatformerPhysics;
import flixel.FlxObject;
import states.PlayState;

class Board extends PhysSprite {
    public function new(?bodyType:BodyType) {
        if (bodyType == null) bodyType = BodyType.STATIC;
        super();
        loadGraphic("assets/images/board.png", 32, 32);
        origin.set(16, 23);
        physics.init(bodyType, false, false);
        physics.createRectangularBody(32, 32, bodyType);
        physics.enabled = true;
        physics.body.userData.entity = this;
        physics.body.shapes.at(0).sensorEnabled = false;
        physics.body.shapes.at(0).fluidEnabled = false;
        physics.body.cbTypes.add(PlatformerPhysics.MOVING_PLATFORM_TYPE);
    }
}