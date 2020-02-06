package states;

import flixel.FlxState;
import sprites.Player;

class PlayState extends FlxState {
    private var player:Player;

    override public function create():Void {
        super.create();
        player = new Player(16, 16, 16, 16);
        add(player);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }
}
