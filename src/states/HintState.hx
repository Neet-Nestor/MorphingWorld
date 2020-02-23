package states;

import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
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

class HintState extends FlxSubState {
    public var hintText:FlxText;
    public var tween:FlxTween;
    public var uiGroup:FlxSpriteGroup;
    public var triggerKeys:Array<FlxKey>;
    public var hasTriggerd:Bool;
    public var untilMouseWheelUp:Bool;
    public var untilMouseWheelDown:Bool;

    public function new(hint:String, untilKeys:Array<FlxKey>, untilMouseWheelUp:Bool = false, untilMouseWheelDown:Bool = false) {
        super();
        hintText = new FlxText(0, FlxG.height - 50, 0, hint, 20);
		hintText.screenCenter(FlxAxes.X);
        hintText.alpha = 0;
        triggerKeys = untilKeys;
        hasTriggerd = false;
        this.untilMouseWheelUp = untilMouseWheelUp;
        this.untilMouseWheelDown = untilMouseWheelDown;
    }

    override public function create():Void {
        super.create();
		uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
        tween = FlxTween.tween(hintText, {alpha: 1}, 0.6);
        uiGroup.add(hintText);
        add(uiGroup);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (!hasTriggerd && FlxG.keys.anyJustPressed(triggerKeys)) {
            hasTriggerd = true;
            if (tween != null) tween.cancel();
            FlxTween.tween(hintText, {alpha: 0}, 0.6, {onComplete: (_) -> {
                close();
            }});
        }

        if (!hasTriggerd && ((untilMouseWheelUp && FlxG.mouse.wheel > 0) || (untilMouseWheelDown && FlxG.mouse.wheel < 0))) {
            hasTriggerd = true;
            if (tween != null) tween.cancel();
            FlxTween.tween(hintText, {alpha: 0}, 0.6, {onComplete: (_) -> {
                close();
            }});
        }
    }
}