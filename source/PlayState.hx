package;

import flixel.text.FlxText;
import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create():Void
	{
		super.create();
		var title = new FlxText(0, 0, 0, "Morphing World", 48);
		title.screenCenter();
		add(title);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
