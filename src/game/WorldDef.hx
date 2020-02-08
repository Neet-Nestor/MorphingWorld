package game;

import config.Config;
import flixel.addons.editors.tiled.TiledMap;
import lycan.entities.LSprite;
import lycan.util.CameraSprite;
import lycan.util.NamedCollection;

class WorldDef implements Named {
	public var name:String;
	public var path:String;
	public var tiledMap:TiledMap;
	public var owned:Bool;
	public var previewSprite:LSprite;

	// Internal for rendering previews of each world
	public static var camSprite:CameraSprite;

	public function new(name:String, path:String) {
		if (camSprite == null) {
			camSprite = new CameraSprite(Config.WORLD_WIDTH, Config.WORLD_HEIGHT);
		}

		this.name = name;
		this.path = path;

		// Keep cache of parsed tiled map data
		tiledMap = new TiledMap(path);

		// Create an inventory sprite for this world
		// Loads a temporary version then draws it to the sprite
		// TODO: dont show some things such as player?
		generatePreview();
	}

	public function generatePreview():Void {
		previewSprite = new LSprite(0, 0);
		previewSprite.makeGraphic(Config.WORLD_WIDTH, Config.WORLD_HEIGHT, 0, false, "worldPreview_" + name);
		var world = new MiniWorld();
		WorldLoader.load(world, tiledMap, PlayState.instance);

		camSprite.group.add(world); //TODO may need to recursively position stuff to bodies?
		camSprite.group.forEach((b) -> { b.cameras = camSprite.group.cameras; }, true);
		camSprite.drawToSprite(previewSprite);
		camSprite.group.remove(world);
		world.destroy();
	}
}