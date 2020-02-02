package states;

import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.ui.FlxButton;
import flixel.FlxState;
import flixel.FlxG;

class MenuState extends FlxState {
    var _startBtn:FlxButton;
    var _title:FlxText;

	override public function create():Void {
        super.create();
		_title = new FlxText(0, 0, 0, "Morphing World", 48);
		_title.screenCenter();
		add(_title);
		_startBtn = new FlxButton(0, _title.getScreenPosition().y + 150, "Start", onStart);
        _startBtn.screenCenter(FlxAxes.X);
        add(_startBtn);
	}

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function onStart():Void {
        FlxG.switchState(new PlayState());
    }
}