package states;

import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween.FlxTweenManager;
import lycan.util.GraphicUtil;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.FlxSubState;
import game.WorldCollection;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import config.Config;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledMap;
import flixel.math.FlxPoint;
import flixel.util.FlxGradient;
import game.WorldDef;

class WorldPieceSwatch extends FlxSprite {
	public var worldDef:WorldDef;
	public var tween:FlxTween;
	public var isHovered:Bool;
	
	public function new(worldDef:WorldDef) {
		super();
		
        this.worldDef = worldDef;
        isHovered = false;
		loadGraphicFromSprite(worldDef.previewSprite);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
	
	public function hover():Void {
		if (isHovered) {
            return;
        }
		isHovered = true;
		if (tween != null) {
            tween.cancel();
        }
		var targetScale = Config.SWATCH_SCALE * 1.2;
		tween = FlxTween.tween(scale, {x: targetScale, y: targetScale}, 0.5, {ease: FlxEase.elasticOut});
	}
	
	public function unhover():Void {
		if (!isHovered) {
            return;
        }
		isHovered = false;
		if (tween != null) {
            tween.cancel();
        }
		tween = FlxTween.tween(scale, {x: Config.SWATCH_SCALE, y: Config.SWATCH_SCALE}, 0.5, {ease: FlxEase.elasticOut});
	}
}

class EditState extends FlxSubState {
	public var swatchGroup:FlxTypedSpriteGroup<WorldPieceSwatch>;
	public var brush:FlxSprite;
	public var selectedSwatch:WorldPieceSwatch;
	public var swatchBackground:FlxSprite;
	public var tweens:FlxTweenManager;
	public var mousePos:FlxPoint;
	public var uiGroup:FlxSpriteGroup;
	
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		
		var xOffset = 0;
		uiGroup = new FlxSpriteGroup();
		uiGroup.camera = PlayState.instance.uiCamera;

		swatchGroup = new FlxTypedSpriteGroup<WorldPieceSwatch>();
		tweens = new FlxTweenManager();
		add(tweens);
		
		brush = new FlxSprite();
		add(brush);
		brush.visible = false;
		
		var color:FlxColor = 0xFF000000;
		swatchBackground = FlxGradient.createGradientFlxSprite(FlxG.width, 155, [0x00000000, color, color], 2, 270);
		swatchBackground.camera = PlayState.instance.uiCamera;
		swatchBackground.alpha = 0;
		
		mousePos = FlxPoint.get();
		
		for (piece in WorldCollection.instance.list) {
			if (!piece.owned) continue;  // Don't add pieces we haven't collected yet
			var swatch = new WorldPieceSwatch(piece);
			swatchGroup.add(swatch);
			swatch.setPosition(xOffset, 15);
			swatch.scale.set(Config.SWATCH_SCALE, Config.SWATCH_SCALE);
			swatch.updateHitbox();
			xOffset += Std.int(swatch.width) + 20;
		}
		
		swatchGroup.screenCenter(FlxAxes.X);
		
		swatchGroup.camera = PlayState.instance.uiCamera;
		
		add(swatchBackground);
		add(swatchGroup);
		add(uiGroup);
		
		swatchGroup.camera = PlayState.instance.uiCamera;
		openCallback = () -> { transitionIn(); };
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		FlxG.mouse.getScreenPosition(PlayState.instance.uiCamera, mousePos);
		swatchBackground.alpha = PlayState.instance.editingTransitionAmount;
		
		var isHoveringSwatch:Bool = false;
		
		for (swatch in swatchGroup) {
			if (swatch.overlapsPoint(mousePos)) {
				swatch.hover();
				isHoveringSwatch = true;
				
				if (FlxG.mouse.justPressed) {
					brush.visible = true;
					selectedSwatch = swatch;
					brush.loadGraphicFromSprite(swatch);
					break;
				}
			} else {
				swatch.unhover();
			}
		}
		
		// Hover effect of slot
		for (slot in PlayState.instance.universe.slots) {
			if (FlxG.mouse.overlaps(slot) && slot.world != null && !slot.world.bodyOverlaps(PlayState.instance.player.physics.body)) {
				slot.hover();
			} else {
				slot.unhover();
			}
		}

		if (FlxG.mouse.justReleased) {
			brush.visible = false;
			for (slot in PlayState.instance.universe.slots) {
				if (FlxG.mouse.overlaps(slot)) {
					// If dropping piece into slot
					if (selectedSwatch != null) {
						slot.loadWorld(selectedSwatch.worldDef);
						// Sounds.playSound(SoundAssets.snapin);
						break;
					}
				}
			}
			selectedSwatch = null;
		}
		
		if (FlxG.mouse.justPressed && !isHoveringSwatch) {
			for (slot in PlayState.instance.universe.slots) {
				if (FlxG.mouse.overlaps(slot)) {
					if (slot.world != null && !slot.world.bodyOverlaps(PlayState.instance.player.physics.body)) {
						slot.unloadWorld();
						// Sounds.playSound(SoundAssets.delete);
						break;
					}
				}
			}
		}
		brush.setPosition(FlxG.mouse.x - brush.width / 2, FlxG.mouse.y - brush.height / 2);
	}
	
	public function transitionIn():Void {
		var delay = 0.3;
		for (swatch in swatchGroup) {
			swatch.y = -swatch.height;
			tweens.tween(swatch, {y: 15}, 1.3, {ease: FlxEase.elasticOut, startDelay: delay});
			delay += 0.15;
		}
		
	}
	
	public function transitionOut(?callback:Void -> Void, fast:Bool = false):Void {
		tweens.clear();
		var delay:Float = 0;
		
		for (swatch in swatchGroup) {
			tweens.tween(swatch, {y: -swatch.height}, 0.3, {ease: FlxEase.expoIn, startDelay: delay});
			delay += fast ? 0 : 0.07;
		}

		for (slot in PlayState.instance.universe.slots) {
			slot.unhover();
		}
		
		var endTime = fast ? 0.4 : 1 + (swatchGroup.length - 1) * 0.1;
		new FlxTimer().start(endTime, (_) -> {
			close();
			if (callback != null) callback();
		});
	}
}
