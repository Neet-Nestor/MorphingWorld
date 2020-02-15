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

class DieState extends FlxSubState {
	private var restartBtn:FlxButton;
	private var menuBtn:FlxButton;
    private var title:FlxText;

    public var uiGroup:FlxSpriteGroup;

    public var _sndDie:FlxSound;

    override public function create():Void {
        super.create();
		uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
        _sndDie = FlxG.sound.load(AssetPaths.die__wav);
        _sndDie.play();
		loadBG();
		loadTitle();
		loadMenu();
        loadReStart();
        add(uiGroup);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
        back.x = 0;
		back.y = 0;
		back.alpha = 0.4;
        uiGroup.add(back);
	}
	
	private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "You Died!", 48);
        title.screenCenter();
        uiGroup.add(title);
    }

    private function loadReStart():Void {
        restartBtn = new FlxButton(0, title.y + 100, "Try Again", onReStart);
        restartBtn.screenCenter(FlxAxes.X);
        uiGroup.add(restartBtn);
	}
	
	private function loadMenu():Void {
        menuBtn = new FlxButton(0, title.y + 150, "Main Menu", onMenu);
        menuBtn.screenCenter(FlxAxes.X);
        uiGroup.add(menuBtn);
    }

    private function onReStart():Void {
		close();
	}
	
	private function onMenu():Void {
		FlxG.switchState(new MenuState());
    }
}