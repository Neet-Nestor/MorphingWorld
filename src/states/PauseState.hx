package states;

import flixel.math.FlxPoint;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
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
import sprites.UIButton;

class PauseState extends FlxSubState {
	private var backBtn:UIButton;
	private var menuBtn:UIButton;
    private var title:FlxText;
    private var optionsBtn:UIButton;
    private var retryBtn:UIButton;

    public var uiGroup:FlxSpriteGroup;

    override public function create():Void {
        super.create();
		uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
		loadBG();
		loadTitle();
        loadButtons();
        add(uiGroup);
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
        title.y -= 30;
        uiGroup.add(title);
    }

    private function loadButtons():Void {
        var vOffset = 100;
        backBtn = new UIButton(0, title.y + vOffset, "Back", onBack, uiGroup.camera);
        backBtn.screenCenter(FlxAxes.X);
        uiGroup.add(backBtn);
        
        vOffset += 45;
        retryBtn = new UIButton(0, title.y + vOffset, "Retry", onRetry, uiGroup.camera);
        retryBtn.screenCenter(FlxAxes.X);
        uiGroup.add(retryBtn);

        vOffset += 45;
        optionsBtn = new UIButton(0, title.y + vOffset, "Options", onOptions, uiGroup.camera);
        optionsBtn.screenCenter(FlxAxes.X);
        uiGroup.add(optionsBtn);

        vOffset += 45;
        menuBtn = new UIButton(0, title.y + vOffset, "Main Menu", onMenu, uiGroup.camera);
        menuBtn.screenCenter(FlxAxes.X);
        uiGroup.add(menuBtn);
	}

    private function onBack():Void {
		close();
	}
	
	private function onMenu():Void {
        FlxG.switchState(new MenuState());
        
        // ABTest: Dynamically change difficulty
        if (PlayState.instance.curStage == 5) {
            trace("Difficulty has been set to easy since player exit at level 5");
            Main.user.setEasyMode();
        }
    }

    private function onRetry():Void {
        PlayState.instance.onReload(false);
    }

    private function onOptions():Void {
        openSubState(new OptionPauseState());
    }
}