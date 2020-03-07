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
import flixel.system.FlxSound;
import flixel.FlxG;
import Sound;

class Portal extends LSprite implements PhysicsEntity {
	public static var PORTAL_TYPE:CbType = new CbType();

    public var port:(p:Player) -> Void;
	public var destinationWorldDef:WorldDef;

	public var _sndPass:FlxSound;
	
	public function new(destinationWorldDef:WorldDef) {
		super();
		
		loadGraphic(AssetPaths.portal2__png, true, 32, 32);
        animation.add("main", [0, 1, 2, 3, 4], 10, true);
		animation.play("main");
		
		physics.init(BodyType.STATIC, true, false);
		physics.createRectangularBody(14, 5, BodyType.STATIC);
        physics.enabled = true;
		physics.body.userData.entity = this;
		physics.body.cbTypes.add(PORTAL_TYPE);
		physics.body.shapes.at(0).sensorEnabled = true;
		physics.body.shapes.at(0).filter = PlatformerPhysics.NON_COLLIDE_FILTER;
		
		_sndPass = FlxG.sound.load(AssetPaths.pass__wav);
		
        this.destinationWorldDef = destinationWorldDef;
        port = (p) -> { 
			// Main.sound.playSound(Effect.Pass, Main.user.getSettings().sound);
			if (Main.user.getSettings().sound) _sndPass.play();
			PlayState.instance.onReload(true); 
		}
	}
    
    override public function destroy():Void {
		super.destroy();
		physics.destroy();
	}
}