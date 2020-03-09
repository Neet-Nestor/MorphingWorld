package states;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.tweens.FlxEase;
import game.WorldCollection;
import game.WorldDef;
import flixel.FlxSprite;
import lycan.util.CircularGraphic;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.util.FlxColor;
import lycan.util.CircularGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class PieceFoundState extends FlxSubState {
	var bg:FlxSprite;
	var beams:CircularGraphic;
	var tweens:FlxTweenManager;
	var pieceSprite:FlxSprite;
	
	var group:FlxSpriteGroup;
	
	var exitEnabled:Bool = false;
	var cancelTweens:Array<FlxTween>;
	
	public function new(worldDef:WorldDef) {
		super();
		pieceSprite = new FlxSprite();
		pieceSprite.loadGraphicFromSprite(worldDef.previewSprite);
		pieceSprite.scale.set(0.5, 0.5);
		cancelTweens = [];
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		if (PlayState.instance.curStage > 1 && FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed) {
			transitionOut();
		}
    }

	override public function create():Void {
		super.create();
		
		group = new FlxSpriteGroup();
		group.camera = PlayState.instance.uiCamera;
		
		tweens =  new FlxTweenManager();
		bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000, true);
		bg.updateHitbox();
		
		beams = new CircularGraphic();
		beams.layers.push(new CircularGraphicLayer(FlxG.width * 0.75, 0, 16, 
			new PolygonSpoke([
				FlxPoint.get(0, 0),
				FlxPoint.get(-60, -FlxG.height),
				FlxPoint.get(60, -FlxG.height)
			])
		));
		bg.alpha = 0.3;
		beams.generate(FlxColor.WHITE);
		beams.alpha = 0.15;
		beams.screenCenter();
		beams.angularVelocity = 35;
		
		pieceSprite.screenCenter();
		group.add(bg);
		group.add(beams);
		group.add(pieceSprite);
		add(group);
		add(pieceSprite);
		add(tweens);
		
		transitionIn();
	}
	
	public function transitionIn():Void {
		bg.alpha = 0;
		beams.alpha = 0;
		pieceSprite.alpha = 0;
		pieceSprite.scale.set(0.01, 0.01);
		pieceSprite.angle = -4;
		
		cancelTweens.push(tweens.tween(bg, {alpha: 0.62}, 0.5, {ease: FlxEase.quadOut}));
		cancelTweens.push(tweens.tween(beams, {alpha: 0.11}, 0.5, {ease: FlxEase.quadOut}));
		cancelTweens.push(tweens.tween(pieceSprite, {alpha: 1}, 0.5, {ease: FlxEase.quadOut}));
		cancelTweens.push(tweens.tween(pieceSprite.scale, {x: 0.65, y: 0.65}, 1, {ease: FlxEase.elasticOut, onComplete: (_) -> {
			if (Main.user.isDialogEnabled() && PlayState.instance.curStage == 1) {
				var dialogState = new DialogState("map_collected");
				persistentUpdate = true;
				dialogState.closeCallback = () -> {
					transitionOut();
				}
				openSubState(dialogState);
			}
		}}));
		tweens.tween(pieceSprite, {angle: 4}, 1.9, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
	}
	
	public function transitionOut():Void {
		for (tween in cancelTweens){
            tween.cancel();
        }
		tweens.tween(bg, {alpha: 0}, 0.3, {ease: FlxEase.quadIn});
		tweens.tween(beams, {alpha: 0}, 0.3, {ease: FlxEase.quadIn});
		tweens.tween(pieceSprite, {alpha: 1}, 0, {ease: FlxEase.quadIn});
		tweens.tween(pieceSprite.scale, {x: 0, y: 0}, 0.2, {ease: FlxEase.quadIn, onComplete: (_) -> { close(); }});
	}
}