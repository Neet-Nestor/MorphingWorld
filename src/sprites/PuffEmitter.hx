package sprites;

import flixel.util.FlxColor;
import flixel.math.FlxVelocity;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;

class PuffEmitter extends FlxTypedEmitter<PuffParticle> {
	var minSpeed:Float;
	var maxSpeed:Float;
	var constantDrag:Float;
	
	public function new(speed:Float = 200, drag:Float = 380, acceleration:Float = -400) {
		super();
		
		this.constantDrag = drag;
		this.minSpeed = 0;
		this.maxSpeed = speed;
		
		//launchMode = FlxEmitterMode.SQUARE;
		keepScaleRatio = true;
		scale.set(0.5, 0.5, 1.5, 1.5, 0, 0, 0, 0);
		lifespan.set(0.8, 1.2);
		particleClass = PuffParticle;
		
		for (i in 0...90) add(new PuffParticle());
	}
	
	override public function emitParticle():PuffParticle {
		var p = super.emitParticle();
		var a = FlxG.random.float(0, 360);
		var v = FlxVelocity.velocityFromAngle(a, FlxG.random.float(minSpeed, maxSpeed));
		p.velocity.copyFrom(v);
		v.put();
		p.drag.set(this.constantDrag, this.constantDrag);
		p.acceleration.set(0, -380);
		p.maxVelocity.y = FlxG.random.float(110, 140);
		return p;
	}
	
	public function puff(x:Float, y:Float, ?width:Float, ?height:Float):Void {
		var oldWidth = width;
		var oldHeight = height;
		
		if (width == null) width = oldWidth;
		if (height == null) height = oldHeight;
		
		setPosition(x, y);
		setSize(width, height);
		
		start(true, 0.1, 90);
		
		setSize(oldWidth, oldHeight);
		
	}
	
}

class PuffParticle extends FlxParticle {
	public function new() {
		super();
		
		makeGraphic(7, 7, FlxColor.WHITE, true, "sprites.PuffEmitter.hx_particle");
		FlxSpriteUtil.drawCircle(this, -1, -1, -1, FlxColor.WHITE, {thickness: 0, color: 0});
	}
	
	override public function onEmit():Void {
		super.onEmit();
	}
	
}