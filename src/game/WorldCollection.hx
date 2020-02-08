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
import haxe.ds.Map;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.util.CameraSprite;
import lycan.util.NamedCollection;
import lycan.world.TiledWorld;
import lycan.world.WorldHandlers;
import lycan.world.layer.ObjectLayer;
import nape.phys.Material;
import sprites.Player;
import states.PlayState;

class WorldCollection extends NamedCollection<WorldDef> {

	public var collectedCount(get, never):Int;

	public function new() {
		super();
	}

	public static function init():Void {
		defineWorld("world", false);
		defineWorld("world2", false);
		defineWorld("world3", false);
	}

	private static function defineWorld(name:String, owned:Bool = false):WorldDef {
		var wd = new WorldDef(name, Config.MAP_PATH + name + ".tmx");
		trace("Adding world def for " + name);
		wd.owned = owned;
		instance.add(wd);
		trace(WorldCollection.get(name));
		return wd;
	}

	private function get_collectedCount():Int {
		var count:Int = 0;
		for (w in list) {
			if (w.owned) count++;
		}
		return count;
	}

}

class WorldDef implements Named {
	public var name:String;
	public var path:String;
	public var tiledMap:TiledMap;
	public var owned:Bool;
	public var previewSprite:LSprite;

	// Internal for rendering previews of each world
	static var camSprite:CameraSprite;

	public function new(name:String, path:String) {
		if (camSprite == null) {
			camSprite = new CameraSprite(Config.WORLD_WIDTH, Config.WORLD_HEIGHT);
		}

		this.name = name;
		this.path = path;

		tiledMap = new TiledMap(path);

		// Keep cache of parsed tiled map data

		// Create an inventory sprite for this world
		// Loads a temporary version then draws it to the sprite
		// TODO dont show some things such as player?
		// generatePreview();
	}

	// public function generatePreview():Void {
	// 	previewSprite = new LSprite(0, 0);
	// 	previewSprite.makeGraphic(Config.WORLD_WIDTH, Config.WORLD_HEIGHT, 0, false, "worldPreview_" + name);
	// 	var world = new MiniWorld();
	// 	WorldLoader.load(world, tiledMap, PlayState.get);

	// 	camSprite.group.add(world);//TODO may need to recursively position stuff to bodies?
	// 	camSprite.group.forEach((b)->b.cameras = camSprite.group.cameras, true);
	// 	camSprite.drawToSprite(previewSprite);
	// 	camSprite.group.remove(world);
	// 	world.destroy();
	// }
}