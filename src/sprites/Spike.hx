package sprites;

import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.phys.PlatformerPhysics;
import lycan.world.components.PhysicsEntity;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.space.Space;
import nape.dynamics.InteractionFilter;

class Spike extends DamagerSprite {
	public static var SPIKE_FILTER:InteractionFilter = new InteractionFilter();

	public var showing(default, set):Bool;
	public var tweens:FlxTweenManager;
    
	public function new(x:Float = 0, y:Float = 0) {
		super(BodyType.KINEMATIC);
		
		this.loadGraphic(AssetPaths.spike__png);
		this.setCenter(x, y); // This must be after loading Graphic
		physics.createBodyFromBitmap(pixels, 0x08, BodyType.KINEMATIC);
		for (shape in physics.body.shapes) {
			shape.filter = SPIKE_FILTER;
		}
		SPIKE_FILTER.collisionGroup = (1 << 8);
		SPIKE_FILTER.collisionMask = -1;

		tweens = new FlxTweenManager();
		
		showing = true;
    }

	override public function update(dt:Float):Void {
		super.update(dt);
		tweens.update(dt);
    }
    
	override public function destroy():Void {
		super.destroy();
		tweens.destroy();
		physics.destroy();
	}
	
	override public function kill():Void {
		alive = false;
		tweens.tween(this, {alpha: 0}, 1, {onComplete: (_) -> {
			exists = false;
			// TODO physics is disabled by component, which we will change, but this looks okay for now
			physics.enabled = false;
		}});
	}
	
	private function set_showing(s:Bool):Bool {
		if (this.showing == s) return s;
		this.showing = s;
		
		if (s) {
			alive = true;
			physics.enabled = true;
		} else {
			alive = false;
			physics.enabled = false;
		}
		
		return s;
	}
}