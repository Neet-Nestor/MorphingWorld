package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import states.PlayState;

class Dialog extends FlxSpriteGroup {
    public var background:FlxSprite;
    public var dialog(default, set):String;
    public var label:FlxText;
    public var promote:FlxText;

    public function new(x:Float = 0, y:Float = 0, dialog:String) {
        super();

        background = new FlxSprite(x, y);
        background.loadGraphic(AssetPaths.dialog__png, false, 1400, 300);

        label = new FlxText(0, 0, 0.8 * 1400, dialog, 32);
        label.x = x + (background.width  - label.width)  / 2.0;
        label.y = y + (background.height - label.height) / 2.0;

        promote = new FlxText(0, 0, 0, "[SPACE]", 20);
        promote.x = x + (background.width - 50 - promote.width);
        promote.y = y + (background.height - 50);

        this.dialog = dialog;
        
        add(background);
        add(label);
        add(promote);
    }

    public function set_dialog(val:String):String {
        label.text = val;
        dialog = val;
        return val;
    }
}