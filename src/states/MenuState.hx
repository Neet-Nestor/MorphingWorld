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

class MenuState extends LycanState {
    private var startBtn:FlxButton;
    private var title:FlxText;

    override public function create():Void {
        super.create();
        title = new FlxText(0, 0, 0, "Morphing World", 48);
        title.screenCenter();
        // var back = new FlxSprite(0, 0, "assets/images/menubg.jpg");
        // back.resize(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
        // back.scale.set(0.5, 0.5);
        var back = new FlxSprite();
        back.loadGraphic("assets/images/menubg.jpg");
        back.x = 0;
        back.y = 0;
        add(back);
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