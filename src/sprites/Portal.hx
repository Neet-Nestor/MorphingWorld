package sprites;

import Sounds.SoundAssets;
import nape.geom.Vec2;
import nape.shape.Shape;
import nape.shape.Polygon;
import flixel.FlxSprite;
import lycan.components.CenterPositionable;
import lycan.components.Attachable;
import lycan.world.components.Switchable;
import nape.callbacks.CbType;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import nape.phys.BodyType;
import lycan.util.GraphicUtil;
import lycan.world.components.PhysicsEntity;
import lycan.entities.LSprite;
import game.WorldDef;
import flixel.util.FlxColor;

class Portal extends LSprite implements PhysicsEntity {
	public static var PORTAL_TYPE:CbType = new CbType();

    public var port:() -> Void;
    public var destinationWorldDef:WorldDef;
	
	public function new(destinationWorldDef:WorldDef) {
		super();
		
		loadGraphic("assets/images/portal.png", true, 32, 32);
        animation.add("main", 0...17, 30, true);
        animation.play("main");
		
		physics.init(BodyType.STATIC, true, false);
		physics.createRectangularBody(14, 5, BodyType.STATIC);
        physics.enabled = true;
        
        this.destinationWorldDef = destinationWorldDef;
        port = () -> {
            
        }
	}
}