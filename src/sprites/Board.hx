package sprites;

import config.Config;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import lycan.components.Attachable;
import lycan.components.CenterPositionable;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.phys.PlatformerPhysics;
import lycan.world.components.CharacterController;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import nape.phys.BodyType;
import states.PlayState;

class Board extends LSprite implements PhysicsEntity {
    public function new(?bodyType:BodyType) {
        if (bodyType == null) bodyType = BodyType.STATIC;
        super();
        loadGraphic("assets/images/board.png", 32, 32);
        origin.set(16, 23);
        physics.init(bodyType, false, false);
        physics.createRectangularBody(32, 6, bodyType);
        physics.enabled = true;
        physics.body.userData.entity = this;
    }

    override public function destroy():Void {
        physics.destroy();
        super.destroy();
    }
}