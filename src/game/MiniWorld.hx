package game;

import nape.phys.Body;
import lycan.world.TiledWorld;
import config.Config;

/**
 * The preview of an actual World
 */
class MiniWorld extends TiledWorld {
	public var x:Float = 0;
	public var y:Float = 0;
    public var worldDef:WorldDef;

	// TODO bring offsetting into here

	public function new() {
		super(Config.SPRITE_ZOOM);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	public function bodyOverlaps(body:Body):Bool {
		return
			body.bounds.x < x + width &&
			body.bounds.max.x > x &&
			body.bounds.y < y + height &&
			body.bounds.max.y > y;
	}

}