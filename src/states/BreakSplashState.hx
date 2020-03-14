package states;

import flixel.FlxCamera.FlxCameraFollowStyle;
import config.Config;
import game.WorldDef;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectShader;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxSubState;
using flixel.util.FlxSpriteUtil;
import flixel.system.FlxAssets.FlxShader;

// Passing Animation State
class BreakSplashState extends FlxSubState {
    public var cb:() -> Void; // if false, reload this stage instead of going to next one
    public var checkDialog:Bool;

    public var backGround:FlxSprite;
    public var circle:FlxSprite;
    public var radius:Float;
    public var screenRadius:Float;

    public function new(?cb:() -> Void, checkDialog:Bool = false) {
        super();
        this.cb = cb;
        this.checkDialog = checkDialog;
    }
    
    override public function create():Void {
        super.create();

        screenRadius = Math.ceil(Math.sqrt(Math.pow(FlxG.width, 2) + Math.pow(FlxG.height, 2))) / 2.2;
        radius = screenRadius;

        backGround = new FlxSprite();
        backGround.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
        backGround.camera = PlayState.instance.uiCamera;
        backGround.screenCenter();

        circle = new FlxSprite();
        circle.camera = PlayState.instance.uiCamera;
        circle.drawCircle(0, 0, screenRadius, FlxColor.WHITE, null, { smoothing: true });
        circle.screenCenter();
        circle.scale.set(0, 0);
        
        var completeHandler = (_) -> {
            if (checkDialog) {
                // Check whether there is stage start dialog
                var dialogKey = null;
                switch PlayState.instance.curStage {
                    case 1: dialogKey = "pass";
                    case 9: dialogKey = "difficult";
                    case 11: dialogKey = "push";
                    case 12: dialogKey = "soon";
                    default: dialogKey = null;
                }

                if (PlayState.instance.curStage == Config.STAGES.length - 1) dialogKey = "win";

                if (dialogKey != null && Config.DIALOGS.exists(dialogKey)) {
                    persistentUpdate = false;
                    FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y_DIALOG;

                    var dialogState = new DialogState(dialogKey);
                    dialogState.closeCallback = () -> {
                        persistentUpdate = true;
                        FlxTween.tween(FlxG.camera.targetOffset, { y:Config.CAMERA_OFFSET_Y }, 0.3);
                        close();
                    }
                    openSubState(dialogState);
                } else {
                    close();
                }
            } else {
                close();
            }
        };
        
        FlxTween.tween(circle.scale, { x: 1, y: 1 }, 0.8, { ease: FlxEase.cubeIn, onComplete: (_) -> {
            if (cb != null) cb();
            FlxTween.tween(circle.scale, { x: 0, y: 0 },
                0.8, { ease: FlxEase.cubeOut, onComplete: completeHandler});
        }});

        add(backGround);
    }

    override public function update(dt:Float):Void {
        super.update(dt);
    }
}