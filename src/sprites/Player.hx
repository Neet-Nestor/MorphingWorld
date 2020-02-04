package sprites;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite {
    public var speed:Float = 200;

    public function new(?x:Float = 0, ?y:Float = 0) {
        super(x, y);

        loadGraphic(AssetPaths.player_move__png, true, 20, 33);
        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.LEFT, true, false);

        animation.add("stand", [2], 6, false);
        animation.add("run", [1, 2, 3, 4], 6, false);

        drag.x = drag.y = 1600;
    }

    public function updateVelocity():Void {
        var up:Bool = false;
        var down:Bool = false;
        var left:Bool = false;
        var right:Bool = false;

        up = FlxG.keys.anyPressed([UP, W]);
        down = FlxG.keys.anyPressed([DOWN, S]);
        left = FlxG.keys.anyPressed([LEFT, A]);
        right = FlxG.keys.anyPressed([RIGHT, D]);

        if (up && down)
            up = down = false;
        if (left && right)
            left = right = false;

        if (up || down || left || right) {
            var mA:Float = 0;
            if (up) {
                mA = -90;
                if (left)
                    mA -= 45;
                else if (right)
                    mA += 45;
                facing = FlxObject.UP;
            } else if (down) {
                mA = 90;
                if (left)
                    mA += 45;
                else if (right)
                    mA -= 45;
                facing = FlxObject.DOWN; // the sprite is facing DOWN
            } else if (left) {
                mA = 180;
                facing = FlxObject.LEFT; // the sprite should be facing LEFT
            } else if (right) {
                mA = 0;
                facing = FlxObject.RIGHT; // set the sprite's facing to RIGHT
            }

            velocity.set(speed, 0);
            velocity.rotate(FlxPoint.weak(0, 0), mA);
        }

        if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) {
            animation.play("run");
        } else {
            animation.play("stand");
        }
    }

    override public function update(elapsed:Float):Void {
        updateVelocity();
        super.update(elapsed);
    }
}