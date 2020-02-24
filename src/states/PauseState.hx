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
	private var restartBtn:FlxButton;
	private var menuBtn:FlxButton;
    private var title:FlxText;
    private var hint:FlxText;

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
        Main.logger.logDie(Main.user.getLastStage());
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE);
        back.x = 0;
		back.y = 0;
		back.alpha = 0.4;
        uiGroup.add(back);
	}
	
	private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "PAUSE", 48);
        title.screenCenter();
        title.y -= 30;
        uiGroup.add(title);
    }

    private function loadBack():Void {
        restartBtn = new FlxButton(0, hint.y + 100, "Back", onBack);
        restartBtn.screenCenter(FlxAxes.X);
        uiGroup.add(restartBtn);
	}
	
	private function loadMenu():Void {
        menuBtn = new FlxButton(0, hint.y + 125, "Main Menu", onMenu);
        menuBtn.screenCenter(FlxAxes.X);
        uiGroup.add(menuBtn);
    }

    private function loadSettings():Void {
        menuBtn = new FlxButton(0, hint.y + 150, "Settings", onSetting);
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
        var option = new OptionState();
        option.prevState = this;
        FlxG.switchState(option);
    }
}