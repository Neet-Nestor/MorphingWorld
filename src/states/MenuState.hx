package states;

import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.ui.FlxButton;
import flixel.FlxState;
import flixel.FlxG;

class MenuState extends FlxState {
    private var startBtn:FlxButton;
    private var title:FlxText;

    override public function create():Void {
        super.create();
        title = new FlxText(0, 0, 0, "Morphing World", 48);
        title.screenCenter();
        add(title);
        startBtn = new FlxButton(0, title.getScreenPosition().y + 150, "Start", onStart);
        startBtn.screenCenter(FlxAxes.X);
        add(startBtn);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function onStart():Void {
        FlxG.switchState(new PlayState());
    }
}