package sprites;

import flixel.math.FlxMath;
import flixel.util.helpers.FlxRange;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class CameraFocus extends FlxObject {

	public var influencers:Array<CameraInfluencer>;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		setSize(0, 0);
		influencers = [];

		solid = false;
	}

	public function updatePosition():Void {
		var totalWeight:Float = 0;

		// Calculate total influencer weight
		for (i in influencers) {
			totalWeight += i.getWeight();
		}

		// Set position to 0 before applying influencers
		setPosition(0, 0);

		// Set position of focus based on influencer weights
		for (i in influencers) {
			var relativeWeight:Float = i.getWeight() / totalWeight;
			x += i.getX() * relativeWeight;
			y += i.getY() * relativeWeight;
		}
	}

	override function update(dt:Float) {
		super.update(dt);

		updatePosition();
	}

	public function add(influencer:CameraInfluencer):CameraFocus {
		if (influencers.indexOf(influencer) >= 0) return this;
		influencers.push(influencer);
		updatePosition();
		return this;
	}

	public function remove(influencer:CameraInfluencer):CameraFocus {
		if (influencers.indexOf(influencer) < 0) return this;
		influencers.remove(influencer);
		updatePosition();
		return this;
	}
}

class CameraInfluencer {
	private var weight:Float;

	public function new() {
		weight = 1;
	}

	public function getWeight():Float {
		return weight;
	}

	public function getX():Float {
		return 0;
	}

	public function getY():Float {
		return 0;
	}

}

// TODO make the distance range stuff modular instead of putting it all in here
// TODO distance should be possible to split into components to be truly flecible... or not even distance, simply a function
class ObjectTargetInfluencer extends CameraInfluencer {

	/**
	 * The object viewing other objects, used to determine the distance
	 */
	public var viewer:FlxObject;
	public var target:FlxObject;
	public var offset:FlxPoint;
	public var ease:Float->Float;

	public var distanceRange:FlxRange<Float>;
	public var weightRange:FlxRange<Float>;

	public function new(target:FlxObject) {
		super();
		this.target = target;
		offset = FlxPoint.get();

		distanceRange = new FlxRange<Float>(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		weightRange = new FlxRange<Float>(1, 1);
	}

	override public function getWeight():Float {
		if (viewer != null) {
			var posViewer:FlxPoint = viewer.getMidpoint();
			var posTarget:FlxPoint = target.getMidpoint();
			var distance:Float = posViewer.distanceTo(posTarget);
			posViewer.put();
			posTarget.put();

			if (distance < distanceRange.start) return weightRange.start;
			if (distance > distanceRange.end) return weightRange.end;
			var t = 1 - (distance - distanceRange.start) / (distanceRange.end - distanceRange.start);
			if (ease != null) t = ease(t);
			return weightRange.end + (weightRange.start - weightRange.end) * t;
		}
		return super.getWeight();
	}

	override function getX():Float {
		return target.getMidpoint().x + offset.x;
	}

	override function getY():Float {
		return target.getMidpoint().y + offset.y;
	}
}