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
    public var avatar:FlxSprite;
    public var dialog:{name:String, dialog:String, avatar:String};
    public var nameLabel:FlxText;
    public var label:FlxText;
    public var promote:FlxText;

    public function new(x:Float = 0, y:Float = 0, dialog:{name:String, dialog:String, avatar:String}) {
        super();

        background = new FlxSprite(x, y);
        background.loadGraphic(AssetPaths.dialog__png, false, 1400, 300);

        avatar = new FlxSprite(0, 0);
        avatar.loadGraphic(dialog.avatar, false);
        var avatarPadding = (background.height - avatar.height) / 2.0;
        avatar.x = x + avatarPadding;
        avatar.y = y + avatarPadding;

        nameLabel = new FlxText(0, 0, 0, dialog.name, 32);
        while (nameLabel.width > 950) {
            nameLabel.size -= 2;
        }
        nameLabel.x = avatar.x + avatar.width + 20;
        nameLabel.y = y + 20;

        label = new FlxText(0, 0, 1400 - avatar.width - 70, dialog.dialog, 20);
        while (label.height > 240) {
            nameLabel.size -= 2;
        }
        label.x = avatar.x + avatar.width + 20;
        label.y = nameLabel.y + nameLabel.height + 20;

        promote = new FlxText(0, 0, 0, "[SPACE]", 20);
        promote.x = x + (background.width - 50 - promote.width);
        promote.y = y + (background.height - 50);

        this.dialog = dialog;
        
        add(background);
        add(avatar);
        add(nameLabel);
        add(label);
        add(promote);
    }

    public function setDialog(newDialog:{name:String, dialog:String, avatar:String}):Void {
        dialog = newDialog;
        reRender();
    }

    private function reRender():Void {
        nameLabel.text = dialog.name;
        label.text = dialog.dialog;
        nameLabel.size = 32;
        while (nameLabel.width > 950) {
            nameLabel.size -= 2;
            if (nameLabel.size < 1) {
                nameLabel.size = 1;
                break;
            }
        }
        nameLabel.x = avatar.x + avatar.width + 20;
        nameLabel.y = background.y + 20;

        label.size = 20;
        while (label.height > 240) {
            label.size -= 2;
            if (label.size < 1) {
                label.size = 1;
                break;
            }
        }
        label.x = avatar.x + avatar.width + 20;
        label.y = nameLabel.y + nameLabel.height + 20;
        
        avatar.loadGraphic(dialog.avatar, false);
        var avatarPadding = (background.height - avatar.height) / 2.0;
        avatar.x = background.x + avatarPadding;
        avatar.y = background.y + avatarPadding;
    }
}