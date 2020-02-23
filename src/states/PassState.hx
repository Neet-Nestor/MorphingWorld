package states;

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
class PassState extends FlxSubState {
    public var backGround:FlxSprite;
    public var alphaMask:FlxSprite;
    public var radius:Float;
    public var screenRadius:Float;
    public var tween:FlxTween;
    public var animating:Bool;
    public var nextWorld:WorldDef;
    public var maskShader:BitmapMaskShader;

    public function new(nextWorld:WorldDef) {
        super();
        this.nextWorld = nextWorld;
    }
    
    override public function create():Void {
        super.create();

        animating = false;
        screenRadius = Math.ceil(Math.sqrt(Math.pow(FlxG.width, 2) + Math.pow(FlxG.height, 2))) / 2;
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
        
        FlxTween.tween(this, { radius: 0 }, 0.8, { ease: FlxEase.linear, onComplete: (_) -> {
            PlayState.instance.switchWorld(nextWorld);
            FlxTween.tween(this, { radius: screenRadius },
                0.8, { ease: FlxEase.quadInOut, onComplete: (_) -> { close(); }});
        }});

        add(backGround);
    }

    override public function draw():Void {
        trace(radius);
        if (radius > 0 && radius < screenRadius) {
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