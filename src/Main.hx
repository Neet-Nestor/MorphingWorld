package;

import states.RootState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
    public static var user:User;
    public static var sound:Sound;
    public function new() {
        super();
        addChild(new FlxGame(0, 0, RootState, 1, 60, 60, true));
        user = new User();
        sound = new Sound();
    }
}
