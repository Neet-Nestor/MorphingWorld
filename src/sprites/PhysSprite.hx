package sprites;

import lycan.entities.LSprite;
import lycan.world.components.PhysicsEntity;

class PhysSprite extends LSprite implements PhysicsEntity {
    override public function destroy():Void {
        super.destroy();
        physics.destroy();
    }
}