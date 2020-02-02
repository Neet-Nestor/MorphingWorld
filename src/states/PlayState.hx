package states;

import flixel.FlxState;
import sprites.Player;

class PlayState extends FlxState {
	var _player:Player;

	override public function create():Void {
		super.create();
		_player = new Player(16, 16);
		add(_player);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
