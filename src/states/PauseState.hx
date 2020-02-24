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
import flixel.input.keyboard.FlxKey;
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
    private var optionsBtn:FlxButton;
    private var retryBtn:FlxButton;

    public var uiGroup:FlxSpriteGroup;

    override public function create():Void {
        super.create();
		uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
		loadBG();
		loadTitle();
        loadButtons();
        add(uiGroup);
        // Main.logger.logDie(Main.user.getLastStage());
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE])) close();
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

    private function loadButtons():Void {
        var vOffset = 100;
        backBtn = new FlxButton(0, title.y + vOffset, "Back", onBack);
        backBtn.screenCenter(FlxAxes.X);
        uiGroup.add(backBtn);
        
        vOffset += 25;
        retryBtn = new FlxButton(0, title.y + vOffset, "Retry", onRetry);
        retryBtn.screenCenter(FlxAxes.X);
        uiGroup.add(retryBtn);

        vOffset += 25;
        optionsBtn = new FlxButton(0, title.y + vOffset, "Options", onOptions);
        optionsBtn.screenCenter(FlxAxes.X);
        uiGroup.add(optionsBtn);

        vOffset += 25;
        menuBtn = new FlxButton(0, title.y + vOffset, "Main Menu", onMenu);
        menuBtn.screenCenter(FlxAxes.X);
        uiGroup.add(menuBtn);
	}

    private function onBack():Void {
		close();
	}
	
	private function onMenu():Void {
		FlxG.switchState(new MenuState());
    }

    private function onRetry():Void {
        PlayState.instance.onReload(false);
    }

    private function onOptions():Void {
        var option = new OptionPauseState();
        // option.loadCamera();
        openSubState(option);
    }
}