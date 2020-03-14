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
    public var alphaMask:FlxSprite;
    public var radius:Float;
    public var screenRadius:Float;
    public var maskShader:BitmapMaskShader;

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

        alphaMask = new FlxSprite();
        alphaMask.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        alphaMask.camera = PlayState.instance.uiCamera;
        alphaMask.screenCenter();
        alphaMask.drawCircle(alphaMask.width / 2, alphaMask.height / 2, screenRadius, FlxColor.WHITE, null, { smoothing: true });

        maskShader = new BitmapMaskShader();
        maskShader.maskImage.input = alphaMask.pixels.clone();
        backGround.shader = maskShader;
        
        var completeHandler = (_) -> {
            if (checkDialog) {
                // Check whether there is stage start dialog
                var dialogKey = Main.user.isEasyMode() ? Config.DIALOGS_KEYS_EASY[PlayState.instance.curStage] : Config.DIALOGS_KEYS[PlayState.instance.curStage];
                var stages = Main.user.isEasyMode() ? Config.STAGES_EASY : Config.STAGES;
                if (PlayState.instance.curStage == stages.length - 1) dialogKey = "win";

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
        
        FlxTween.tween(this, { radius: 0 }, 0.8, { ease: FlxEase.cubeIn, onComplete: (_) -> {
            if (cb != null) cb();
            FlxTween.tween(this, { radius: screenRadius },
                0.8, { ease: FlxEase.cubeOut, onComplete: completeHandler});
        }});

        add(backGround);
    }

    override public function draw():Void {
        // Weird race condition
        if (radius > 2 && radius < screenRadius) {
            alphaMask.fill(FlxColor.TRANSPARENT);
            alphaMask.drawCircle(alphaMask.width / 2, alphaMask.height / 2, radius, FlxColor.WHITE, null, { smoothing: true });
            maskShader.maskImage.input = alphaMask.pixels.clone();
        }
        super.draw();
    }

    override public function update(dt:Float):Void {
        super.update(dt);
    }
}

class BitmapMaskShader extends FlxShader {
    @:glFragmentSource("
        #pragma header
		
		uniform sampler2D maskImage;
		
		void main(void) {
			#pragma body
			
			float mask = texture2D (maskImage, openfl_TextureCoordv).a;
            gl_FragColor *= (1.0 - mask);
		}
    ")
    
	public function new() {
        super();
	}
}