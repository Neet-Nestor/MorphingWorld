package sprites;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Player extends FlxSprite {
    public function new(?x:Float = 0, ?y:Float = 0) {
        super(x, y);
        makeGraphic(16, 16, FlxColor.WHITE);
    }
}