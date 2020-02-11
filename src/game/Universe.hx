package game;

import config.Config;
import flixel.FlxBasic;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import haxe.ds.StringMap;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.TiledWorld;
import lycan.world.WorldHandlers;
import lycan.world.layer.ObjectLayer;
import nape.phys.Material;
import sprites.Player;
import sprites.WorldSlot;
import states.PlayState;

typedef GridPosition = {x:Int, y:Int};

class Universe extends FlxGroup {
	public var worldLayer:FlxGroup;
	public var slots:FlxTypedGroup<WorldSlot>;
	public var slotMap:StringMap<WorldSlot>;
	
	public function new() {
		super();
		
		worldLayer = new FlxGroup();
		slots = new FlxTypedGroup<WorldSlot>();
		slotMap = new Map<String, WorldSlot>();
		
		add(worldLayer);
		add(slots);
	}

	override public function destroy():Void {
		for (slot in slots) removeSlot(slot);
		super.destroy();
	}
	
	public function reset(?initWorldName:String):Void {
		for (slot in slots) removeSlot(slot);
		for (world in worldLayer) world.destroy();
		worldLayer.clear();
		PlayState.instance.reloadPlayerPosition = true;
		if (initWorldName == null) {
			makeSlot(0, 0).loadWorld(PlayState.instance.initWorld);
		} else {
			makeSlot(0, 0).loadWorld(WorldCollection.get(initWorldName));
		}
	}

	public function makeSlot(x:Int, y:Int):WorldSlot {
        if (getSlot(x, y) != null) {
            return null;
        }
		var slot = new WorldSlot(x, y, this);
		slotMap.set('$x,$y', slot);
		slots.add(slot);
		return slot;
	}
	
	public function getSlot(x:Int, y:Int):WorldSlot {
		return slotMap.get('$x,$y');
	}
	
	public function removeSlot(slot:WorldSlot):Void {
		if (slot == null) {
            return;
        }
		if (slot.world != null) {
            slot.unloadWorld();
        }
		slotMap.remove('${slot.gridPos.x},${slot.gridPos.y}');
		slots.remove(slot);
		slot.destroy();
	}
	
	/**
	 * Check if a slot either has a world itself or has a world in a neighbour slot,
	 * otherwise remove it.
	 * @param slot The slot to check
	 * @return Bool Whether the slot was removed
	 */
	public function checkRemoveSlot(slot:WorldSlot):Bool {
		if (slot == null || slot.world != null) {
            return false;
        }
        // Search
		for (xy in [{x: -1, y: 0}, {x: 0, y: -1}, {x: 1, y: 0}, {x: 0, y: 1}]) {
			var currentSlot:WorldSlot = getSlot(slot.gridPos.x + xy.x, slot.gridPos.y + xy.y);
			if (currentSlot != null && currentSlot.world != null) {
				return false;
			}
		}
		
		// If all local slots are empty, remove this slot
		removeSlot(slot);
		return true;
	}
}