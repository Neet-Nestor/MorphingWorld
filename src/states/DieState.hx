package states;

import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.ui.FlxButton;
import flixel.FlxG;
import lycan.states.LycanState;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;

class DieState extends LycanState {
    private var restartBtn:FlxButton;
    private var title:FlxText;

    override public function create():Void {
        super.create();
    }

    override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.camera.follow(null);
		//loadBG();
		loadTitle();
        loadReStart();
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.loadGraphic("assets/images/menubg.jpg");
        back.x = 0;
        back.y = 0;
        add(back);
	}
	
	private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "You Died!", 48);
        title.screenCenter();
        add(title);
    }

    private function loadReStart():Void {
        restartBtn = new FlxButton(0, 200, "Try Again", onReStart);
        restartBtn.screenCenter(FlxAxes.X);
        add(restartBtn);
    }

    private function onReStart():Void {
		trace("button");
		close();
		trace("button end");
    }
}