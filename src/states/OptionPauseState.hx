package states;

import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
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

class OptionPauseState extends FlxSubState {
    private var startBtn:FlxButton;
    private var title:FlxText;
    // public var prevState:FlxSubState;
    public var uiGroup:FlxSpriteGroup;
    public var settings:{volume: Int, music: Bool, sound: Bool};

    override public function create():Void {
        super.create();
        // TODO: set value reflect to their current value;
        settings = Main.user.getSettings();
        uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
        loadBG();
        loadTitle();
        loadVolumeOption();
        loadMusic();
        loadSound();
        loadQuit();
        add(uiGroup);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.loadGraphic(AssetPaths.menubg__jpg);
        back.x = 0;
        back.y = 0;
        uiGroup.add(back);
    }

    private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "Options", 48);
        title.screenCenter();
        uiGroup.add(title);
    }

    private function loadVolumeOption():Void {
        var txt = new FlxText(title.x - 50, title.y + 100, 0, "Volume", 16);
        uiGroup.add(txt);
        var slide = new FlxSlider(null, "", title.x + 130, title.y + 80, 0, 100, 100, 20, 3, 0x66CCFF66, 0xFF828282);
        slide.value = settings.volume;
        slide.callback = function(newValue:Float) {
            slide.value = 100 * newValue;
            // TODO: change music volume
            FlxG.sound.changeVolume(newValue - FlxG.sound.volume);
            var iv:Int = cast slide.value;
            settings.volume = iv;
        }
        uiGroup.add(slide);
    }

    private function loadMusic():Void {
        var txt = new FlxText(title.x - 50, title.y + 135, 0, "Music", 16);
        uiGroup.add(txt);
        var check = new FlxUICheckBox(title.x + 180, title.y + 140, null, null, "", 100, [], null);
        check.checked = Main.user.getSettings().music;
        check.callback = function() {
            settings.music = check.checked;
            if (!check.checked) {
                Main.sound.pauseMusic();
            } else {
                Main.sound.resumeMusic();
            }
        }
        uiGroup.add(check);
    }

    private function loadSound():Void {
        var txt = new FlxText(title.x - 50, title.y + 170, 0, "Sound Effects", 16);
        uiGroup.add(txt);
        var check = new FlxUICheckBox(title.x + 180, title.y + 175, null, null, "", 100, [], null);
        check.checked = settings.sound;
        check.callback = function() {
            settings.sound = check.checked;
        }
        uiGroup.add(check);
    }

    private function loadQuit():Void {
        var quitUsBtn = new FlxButton(0, title.y + 205, "Back", onQuit);
        quitUsBtn.screenCenter(FlxAxes.X);
        uiGroup.add(quitUsBtn);
    }

    private function onQuit():Void {
        // TODO quit
        // if (this.prevState == null) {
        //     this.prevState = new MenuState();
        // }
        Main.user.save(settings);
        // FlxG.switchState(prevState);
        close();
    }
}