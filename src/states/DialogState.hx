package states;

import flixel.FlxObject;
import config.Config;
import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;
import sprites.Dialog;

class DialogState extends FlxSubState {
    public var uiGroup:FlxSpriteGroup;
    public var dialogSprite:Dialog;
    public var dialogs:Array<{name:String, dialog:String, avatar:String}>;
    public var curDialogIndex:Int;
    public var prevFocus:FlxObject;

    public function new() {
        super();
        curDialogIndex = 0;
    }

    override public function create():Void {
        super.create();
        
        if (!Config.DIALOGS.exists(PlayState.instance.curStage)) {
            // no dialogs, skip
            close();
            return;
        }

        prevFocus = FlxG.camera.target;
        FlxG.camera.follow(PlayState.instance.player);
		FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y_DIALOG;
		FlxG.camera.snapToTarget();

        this.dialogs = Config.DIALOGS[PlayState.instance.curStage];
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
            dialogSprite.setDialog(dialogs[curDialogIndex]);
        }
    }

    override public function close():Void {
        FlxG.camera.follow(prevFocus);
		FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
        super.close();
    }
}