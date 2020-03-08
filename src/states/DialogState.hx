package states;

import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import sprites.Dialog;

class DialogState extends FlxSubState {
    public var uiGroup:FlxSpriteGroup;
    public var dialogSprite:Dialog;
    public var dialogs:Array<String>;
    public var curDialogIndex:Int;

    public function new(dialogs:Array<String>) {
        super();
        this.dialogs = dialogs;
        curDialogIndex = 0;
    }

    override public function create():Void {
        super.create();
		uiGroup = new FlxSpriteGroup();
        uiGroup.camera = PlayState.instance.uiCamera;
        dialogSprite = new Dialog((FlxG.width - 1400) / 2, FlxG.height - 300 - 20, dialogs[0]);

        uiGroup.add(dialogSprite);
        add(uiGroup);
    }

    override public function update(dt:Float):Void {
        super.update(dt);
        
        if (FlxG.keys.anyJustPressed([FlxKey.SPACE])) {
            curDialogIndex++;
            if (curDialogIndex >= dialogs.length) {
                close();
                return;
            }
            dialogSprite.dialog = dialogs[curDialogIndex];
        }
    }
}