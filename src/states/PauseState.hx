package states;

import flixel.math.FlxPoint;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.FlxG;
import lycan.states.LycanState;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import flixel.system.FlxSound;

class PauseState extends FlxSubState {
	private var backBtn:FlxButton;
	private var menuBtn:FlxButton;
    private var title:FlxText;
    private var settingBtn:FlxButton;

    public var uiGroup:FlxSpriteGroup;

    override public function create():Void {
        super.create();
		uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
		loadBG();
		loadTitle();
        loadBack();
        loadMenu();
        loadSettings();
        add(uiGroup);
        // Main.logger.logDie(Main.user.getLastStage());
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        back.x = 0;
		back.y = 0;
		back.alpha = 0.2;
        uiGroup.add(back);
	}
	
	private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "PAUSE", 48);
        title.screenCenter();
        uiGroup.add(title);
    }

    private function loadBack():Void {
        backBtn = new FlxButton(0, title.y + 100, "Back", onBack);
        backBtn.screenCenter(FlxAxes.X);
        uiGroup.add(backBtn);
	}

    private function loadSettings():Void {
        settingBtn = new FlxButton(0, title.y + 125, "Settings", onSetting);
        settingBtn.screenCenter(FlxAxes.X);
        uiGroup.add(settingBtn);
    }
	
	private function loadMenu():Void {
        menuBtn = new FlxButton(0, title.y + 150, "Main Menu", onMenu);
        menuBtn.screenCenter(FlxAxes.X);
        uiGroup.add(menuBtn);
    }

    private function onBack():Void {
		close();
	}
	
	private function onMenu():Void {
		FlxG.switchState(new MenuState());
    }

    private function onSetting():Void {
        var option = new OptionPauseState();
        // option.loadCamera();
        openSubState(option);
    }
}