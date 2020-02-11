package sprites;

import nape.phys.BodyType;
import config.Config;
import flixel.FlxBasic;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import haxe.ds.Map;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.WorldHandlers;
import lycan.world.TiledWorld;
import lycan.world.layer.ObjectLayer;
import nape.phys.Material;
import lycan.phys.PlatformerPhysics;
import flixel.addons.editors.tiled.TiledMap;
import flixel.group.FlxGroup;
import game.MiniWorld;
import game.Universe;
import game.WorldLoader;
import lycan.world.components.PhysicsEntity;
import flixel.FlxSprite;
import states.PlayState;
import flixel.group.FlxSpriteGroup;
import game.WorldDef;
import game.WorldCollection;

class WorldSlot extends FlxSpriteGroup {
	
	public var gridPos:GridPosition;
	public var world(default, set):MiniWorld;
	public var universe:Universe;
	
	public var outline:PhysSprite;  // TODO: physics should be on it's own object, not borowing outline
	
	public function new(gridX:Int = 0, gridY:Int = 0, universe:Universe) {
		super();
		this.universe = universe;
		
		gridPos = {x: gridX, y: gridY};
		
		outline = new PhysSprite();
		outline.loadGraphic("assets/images/slot_thick.png", false, 448, 448);
		outline.physics.init(BodyType.STATIC, true, false);
		outline.physics.setBodyMaterial(0, 1, 2, 1, 1);
		outline.physics.body.position.setxy(gridX * Config.WORLD_WIDTH  + Config.WORLD_WIDTH  / 2,
										    gridY * Config.WORLD_HEIGHT + Config.WORLD_HEIGHT / 2);
        outline.physics.snapEntityToBody();
		outline.visible = true;
		outline.alpha = 0;
		add(outline);
		
		world = null;
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (outline.visible) {
			// For Animation
			outline.alpha = PlayState.instance.editingTransitionAmount * 0.4;
		}
	}
	
	public function loadWorld(worldDef:WorldDef):MiniWorld {
		if (world != null) {
            return null;
        }
		
		world = new MiniWorld();
		world.worldDef = worldDef;
		WorldLoader.load(world, new TiledMap(worldDef.path), gridPos.x * Config.WORLD_WIDTH, gridPos.y * Config.WORLD_HEIGHT);
		if (world == null) {
            return null;
        }
		universe.worldLayer.add(world); // TODO: correct layers for loading
		padWithEmptySlots();
		outline.visible = false;
		outline.physics.enabled = false; // TODO: invert for unloading a world
		
		return world;
	}
	
	public function padWithEmptySlots():Void {
		for (xy in [{x: -1, y: 0}, {x: 0, y: -1}, {x: 1, y: 0}, {x: 0, y: 1}]) {
			var x = gridPos.x + xy.x;
			var y = gridPos.y + xy.y;
			
			var slot = universe.getSlot(x, y);
			if (slot == null) {
				universe.makeSlot(x, y);
			}
		}
	}
	
	override public function destroy():Void {
		super.destroy();
		if (world != null) world.destroy();
		world = null;
		universe = null;
	}
	
	public function unloadWorld(animate:Bool = true):Void {
		if (world == null) {
            return;
        }
		
		universe.worldLayer.remove(world);
		// Effect
		// if (animate) {
		// 	var emitter = PlayState.instance.puffEmitter;
		// 	emitter.setPosition(world.x, world.y);
		// 	emitter.setSize(Config.WORLD_WIDTH, Config.WORLD_HEIGHT);
		// 	emitter.start(true, 0.1, 200);
		// }

		world.destroy();
		world = null;
		outline.visible = true;
		
		// Check local area in Universe for removing slots
		for (xy in [{x: -1, y: 0}, {x: 0, y: -1}, {x: 1, y: 0}, {x: 0, y: 1}]) {
			universe.checkRemoveSlot(universe.getSlot(gridPos.x + xy.x, gridPos.y + xy.y));
		}
		
		universe.checkRemoveSlot(this);
	}
	
	private function set_world(world:MiniWorld):MiniWorld {
		if (world == null) {
			outline.physics.enabled = true;
		} else {
			outline.physics.enabled = false;
		}
		this.world = world;
		return world;
	}
	
}