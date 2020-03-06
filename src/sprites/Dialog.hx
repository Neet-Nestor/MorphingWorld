package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import states.PlayState;

class Dialog extends FlxSpriteGroup {
    public var text:FlxText;
    public var background:FlxSprite;
    public var dialogs:Array<String>;
    public var curDialogIndex:Int;
    public var onFinish:() -> Void;

    public function new(dialogs:Array<String>, ?onFinish:() -> Void) {
        super();
        this.dialogs = dialogs;
        curDialogIndex = 0;
        camera = PlayState.instance.uiCamera;
        this.onFinish = onFinish != null ? onFinish : () -> {};

        background = new FlxSprite();
        background.loadGraphic(AssetPaths.dialog__png, false, 1400, 300);
        background.y = 0.7 * FlxG.height;
        background.width = FlxG.width;
        background.height = FlxG.height - y;
        background.screenCenter(FlxAxes.X);

        text = new FlxText(0, 0, 0.8 * FlxG.width, dialogs[0]);
        text.x = (background.width - text.width) / 2.0;
        text.y = (background.height - text.height) / 2.0;

        add(background);
        add(text);
    }

    override public function update(dt:Float):Void {
        super.update(dt);
        if (FlxG.keys.anyJustPressed([FlxKey.SPACE])) {
            curDialogIndex++;
            if (curDialogIndex >= dialogs.length) {
                onFinish();
                return;
            }
            text.text = dialogs[curDialogIndex];
        }
    }
}