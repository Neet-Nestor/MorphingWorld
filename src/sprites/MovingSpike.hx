package sprites;

import config.Config;
import flixel.util.FlxPath;

enum Direction {
    DOWN;
    UP;
}

class MovingSpike extends Spike {
    private static inline final INTERVAL:Float = 20;   // ms

    public var moving:Bool;
    public var previous:Direction;
    public var timeStaying:Float;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        moving = false;
        timeStaying = INTERVAL;
        previous = Direction.UP;
        path = new FlxPath().add(x, y).add(x, y + Config.WORLD_TILE_HEIGHT - Config.SPIKE_OFFSET_Y);
    }

    override public function update(dt:Float):Void {
        super.update(dt);
        if (!moving) {
            if (timeStaying <= 0) {
                moving = true;
                if (previous == Direction.DOWN) {
                    previous = Direction.UP;
                    var startPoint = path.nodes[1];
                    this.setCenter(startPoint.x, startPoint.y);
                    path.start(FlxPath.BACKWARD);
                } else {
                    previous = Direction.DOWN;
                    var startPoint = path.nodes[0];
                    this.setCenter(startPoint.x, startPoint.y);
                    path.start(FlxPath.FORWARD);
                }
            } else {
                timeStaying -= dt;
            }
        }
        physics.snapBodyToEntity();
    }
}