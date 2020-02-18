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
import flixel.addons.ui.FlxSlider;

class OptionState extends LycanState {
    private var startBtn:FlxButton;
    private var title:FlxText;
    public var prevState:LycanState;

    override public function create():Void {
        super.create();
        // TODO: set value reflect to their current value;
        loadBG();
        loadTitle();
        loadVolumeOption();
        loadMusic();
        loadSound();
        loadQuit();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.loadGraphic(AssetPaths.menubg__jpg);
        back.x = 0;
        back.y = 0;
        add(back);
    }

    private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "Options", 48);
        title.screenCenter();
        add(title);
    }

    private function loadVolumeOption():Void {
        var txt = new FlxText(title.getScreenPosition().x - 50, title.getScreenPosition().y + 100, 0, "Volume", 16);
        add(txt);
        var slide = new FlxSlider(null, "", title.getScreenPosition().x + 130, title.getScreenPosition().y + 80, 0, 100, 100, 20, 3, 0x66CCFF66, 0xFF828282);
        slide.callback = function(newValue:Float) {
            slide.value = 100 * newValue;
            // TODO: change music volume
            FlxG.sound.changeVolume(newValue - FlxG.sound.volume);
        }
        add(slide);
    }

    private function loadMusic():Void {
        var txt = new FlxText(title.getScreenPosition().x - 50, title.getScreenPosition().y + 135, 0, "Music", 16);
        add(txt);
        var check = new FlxUICheckBox(title.getScreenPosition().x + 180, title.getScreenPosition().y + 140, null, null, "", 100, [], null);
        check.callback = function() {
            trace("Checked");
        }
        add(check);
    }

    private function loadSound():Void {
        var txt = new FlxText(title.getScreenPosition().x - 50, title.getScreenPosition().y + 170, 0, "Sound Effects", 16);
        add(txt);
        var check = new FlxUICheckBox(title.getScreenPosition().x + 180, title.getScreenPosition().y + 175, null, null, "", 100, [], null);
        check.callback = function() {
            trace("Checked");
        }
        add(check);
    }

    private function loadQuit():Void {
        var quitUsBtn = new FlxButton(0, title.getScreenPosition().y + 205, "Back", onQuit);
        quitUsBtn.screenCenter(FlxAxes.X);
        add(quitUsBtn);
    }

    private function onStart():Void {
        FlxG.switchState(new PlayState());
    }

    private function onOption():Void {
        FlxG.switchState(new OptionState());
    }

    private function onQuit():Void {
        // TODO quit
        if (this.prevState == null) {
            this.prevState = new MenuState();
        }
        FlxG.switchState(prevState);
    }
}