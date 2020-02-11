package sprites;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import game.WorldDef;
import lycan.components.Attachable;
import lycan.components.CenterPositionable;
import lycan.entities.LSprite;
import lycan.util.GraphicUtil;
import lycan.world.components.PhysicsEntity;
import nape.callbacks.CbType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.shape.Shape;
import lycan.phys.PlatformerPhysics;
import states.PlayState;

class Portal extends LSprite implements PhysicsEntity {
	public static var PORTAL_TYPE:CbType = new CbType();

    public var port:(p:Player) -> Void;
    public var destinationWorldDef:WorldDef;
	
	public function new(destinationWorldDef:WorldDef) {
		super();
		
		loadGraphic("assets/images/portal.png", true, 32, 32);
        animation.add("main", [for (i in 0...17) 16 - i], 10, true);
        animation.play("main");
		
		physics.init(BodyType.STATIC, true, false);
		physics.createRectangularBody(14, 5, BodyType.STATIC);
        physics.enabled = true;
		physics.body.userData.entity = this;
		physics.body.shapes.at(0).sensorEnabled = true;
		physics.body.shapes.at(0).filter = PlatformerPhysics.OVERLAPPING_OBJECT_FILTER;
		physics.body.cbTypes.add(PORTAL_TYPE);
        
        this.destinationWorldDef = destinationWorldDef;
        port = (p) -> { PlayState.instance.switchWorld(destinationWorldDef); }
	}
}