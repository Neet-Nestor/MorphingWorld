package states;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxPath;
import lycan.components.CenterPositionable;
import lycan.util.ParallaxUtil;
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

class MouseCursor extends FlxSprite implements CenterPositionable {
	public var scheduled:Bool;

    public function new() {
		super();
		scheduled = false;

        loadGraphic(AssetPaths.mouse_cursor__png);
        scale.set(0.1, 0.1);
		updateHitbox();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		// Check path finished and restart it
		if (path != null && path.finished && !scheduled) {
			scheduled = true;
			new FlxTimer().start(0.6, (_) -> {
				scheduled = false;
				setPosition(path.head().x - width / 2, path.head().y - height / 2);
				path.restart();
			});
		}
	}
}

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
	public var lastSwatch:WorldPieceSwatch;
	
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
			swatch.setPosition(xOffset, 20);
			swatch.scale.set(Config.SWATCH_SCALE, Config.SWATCH_SCALE);
			swatch.updateHitbox();
			lastSwatch = swatch;
			xOffset += Std.int(swatch.width) + 20;
		}
		
		swatchGroup.screenCenter(FlxAxes.X);
		swatchGroup.camera = PlayState.instance.uiCamera;

		// Drag hint
		if (PlayState.instance.curStage == 1 && !PlayState.instance.editHintShown) {
			PlayState.instance.editHintShown = true;
			// Get screen location of the path
			// Magic: 400, 225 in uiCamera = 0, 0 in WorldCamera

			var mouseCursor = new MouseCursor();
			var departure = lastSwatch.getPosition();
			var destinationSlot = PlayState.instance.universe.getSlot(1, 0).outline;
			var destination = destinationSlot.getPosition();
			destination.x = (destination.x - destinationSlot.camera.scroll.x) / destinationSlot.camera.zoom + 400;
			destination.y = (destination.y - destinationSlot.camera.scroll.y) / destinationSlot.camera.zoom + 225;

			// Add offsets
			departure.x += lastSwatch.width / 2 + mouseCursor.width / 2;
			departure.y += lastSwatch.height / 2 + mouseCursor.height / 2;
			destination.x += (destinationSlot.width / 2)  / destinationSlot.camera.zoom + mouseCursor.width  / 2;
			destination.y += (destinationSlot.height / 2) / destinationSlot.camera.zoom + mouseCursor.height / 2;

			mouseCursor.setPosition(departure.x, departure.y);
			mouseCursor.path = new FlxPath().start([departure, destination], 200, FlxPath.FORWARD);
			uiGroup.add(mouseCursor);
			// don't allow the user to exit editing mode
			PlayState.instance.worldEditingDisabled = true;

			var previousSlots = PlayState.instance.universe.slots.length;
			PlayState.instance.showHint("[Drag & Drop]",
				() -> PlayState.instance.universe.slots.length > previousSlots,
				() -> {
					uiGroup.remove(mouseCursor);
					persistentUpdate = false;
					PlayState.instance.persistentUpdate = false;
					var dialogState = new DialogState("map_done");
					dialogState.closeCallback = () -> {
						persistentUpdate = true;
						PlayState.instance.persistentUpdate = true;
						PlayState.instance.worldEditingDisabled = false;
						PlayState.instance.showHint("[Scroll Down or E again to finish]",
							() -> FlxG.keys.anyJustPressed([FlxKey.E]) || FlxG.mouse.wheel < 0,
							() -> { PlayState.instance.player.characterController.hasControl = true; });
					}
					openSubState(dialogState);
				});
		}

		if (PlayState.instance.curStage == 2 && !PlayState.instance.removeHintShown) {
			PlayState.instance.removeHintShown = true;
			// Get screen location of the path
			// Magic: 400, 225 in uiCamera = 0, 0 in WorldCamera
			persistentUpdate = false;
			PlayState.instance.persistentUpdate = false;
			PlayState.instance.player.characterController.stop();
			PlayState.instance.player.characterController.hasControl = false;
			PlayState.instance.player.characterController.leftPressed = false;
			PlayState.instance.player.characterController.rightPressed = false;
			PlayState.instance.pausePhys();
			var dialogState = new DialogState("delete");
			dialogState.closeCallback = () -> {
				persistentUpdate = true;
				PlayState.instance.persistentUpdate = true;
				PlayState.instance.resumePhys(false);
				PlayState.instance.player.characterController.hasControl = true;
				var mouseCursor = new MouseCursor();
				var slotToRemove = PlayState.instance.universe.getSlot(-1, 0).outline;
				var pos = slotToRemove.getPosition();
				pos.x = (pos.x - slotToRemove.camera.scroll.x) / slotToRemove.camera.zoom + 400;
				pos.y = (pos.y - slotToRemove.camera.scroll.y) / slotToRemove.camera.zoom + 225;

				// Add offsets
				pos.x += (slotToRemove.width / 2)  / slotToRemove.camera.zoom + mouseCursor.width  / 2;
				pos.y += (slotToRemove.height / 2) / slotToRemove.camera.zoom + mouseCursor.height / 2;

				mouseCursor.setPosition(pos.x, pos.y);
				mouseCursor.alpha = 0;
				uiGroup.add(mouseCursor);

				FlxTween.tween(mouseCursor, { alpha: 1 }, 1);

				// don't allow the user to exit editing mode
				PlayState.instance.worldEditingDisabled = true;
				var initWorld = PlayState.instance.universe.getSlot(-1, 0).world;
				PlayState.instance.showHint("[Click to destroy world or Directly replace it]",
					() -> PlayState.instance.universe.getSlot(-1, 0) == null || PlayState.instance.universe.getSlot(-1, 0).world != initWorld ||
						!PlayState.instance.isWorldEditing,  // Just in case that user exit editing state for some reason
					() -> {
						uiGroup.remove(mouseCursor);
						PlayState.instance.worldEditingDisabled = false;
					});
			}
			openSubState(dialogState);
		}
		
		add(swatchBackground);
		add(swatchGroup);
		add(uiGroup);
		
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
			if (FlxG.mouse.overlaps(slot) &&
				((slot.world == null && FlxG.mouse.pressed && selectedSwatch != null) ||
				 (slot.world != null && !slot.world.bodyOverlaps(PlayState.instance.player.physics.body)))) {
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
						if (slot.world == null || !slot.world.bodyOverlaps(PlayState.instance.player.physics.body)) {
							if (slot.world != null) slot.unloadWorld();
							slot.loadWorld(selectedSwatch.worldDef);
						}
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
	
	public function addNewWorldPiece(piece:WorldDef):Void {
		if (!piece.owned) return;  // Don't add pieces we haven't collected yet
		for (swatch in swatchGroup) {
			if (swatch.worldDef == piece) return; // Don't duplicate adding
		}
		var swatch = new WorldPieceSwatch(piece);
		swatchGroup.add(swatch);
		swatch.setPosition(lastSwatch.x + Std.int(lastSwatch.width) + 20, lastSwatch.y);
		swatch.scale.set(Config.SWATCH_SCALE, Config.SWATCH_SCALE);
		swatch.updateHitbox();
		lastSwatch = swatch;

		// Transit new piece in
		swatch.y = -swatch.height;
		tweens.tween(swatch, {y: 15}, 0.3, {ease: FlxEase.circOut });
		tweens.tween(swatchGroup, {x: FlxG.width / 2 - swatchGroup.width / 2}, 0.6, { ease: FlxEase.circOut });
	}

	public function transitionIn():Void {
		var delay = 0.3;
		for (swatch in swatchGroup) {
			swatch.y = -swatch.height;
			tweens.tween(swatch, {y: 15}, 0.3, {ease: FlxEase.circOut, startDelay: delay});
			delay += 0.15;
		}
	}
	
	public function transitionOut(?callback:Void -> Void, fast:Bool = false):Void {
		tweens.clear();
		var delay:Float = 0;

		for (ui in uiGroup) {
			tweens.tween(ui, {alpha: 0}, 0.3, {ease: FlxEase.elasticOut, startDelay: delay});
		}

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

	override public function destroy():Void {
		super.destroy();
		mousePos.put();
	}
}
