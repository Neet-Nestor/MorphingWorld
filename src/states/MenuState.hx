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
        loadBG();
        loadTitle();
        loadStart();
        loadAboutUS();
        loadOptions();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.loadGraphic("assets/images/menubg.jpg");
        back.x = 0;
        back.y = 0;
        add(back);
    }

    private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "Morphing World", 48);
        title.screenCenter();
        add(title);
    }

    private function loadStart():Void {
        startBtn = new FlxButton(0, title.getScreenPosition().y + 100, "Start", onStart);
        startBtn.screenCenter(FlxAxes.X);
        add(startBtn);
    }

    private function loadAboutUS():Void {
        var aboutUsBtn = new FlxButton(0, title.getScreenPosition().y + 150, "About Us", onStart);
        aboutUsBtn.screenCenter(FlxAxes.X);
        add(aboutUsBtn);
    }

    private function loadOptions():Void {
        var optionsBtn = new FlxButton(0, title.getScreenPosition().y + 125, "Options", onStart);
        optionsBtn.screenCenter(FlxAxes.X);
        add(optionsBtn);
    }

    private function onStart():Void {
        FlxG.switchState(new PlayState());
    }
}