package game;

import config.Config;
import lycan.util.NamedCollection;

class WorldCollection extends NamedCollection<WorldDef> {
	public var collectedCount(get, null):Int;

	public function new() {
		super();
	}

	public static function init():Void {
		instance.clear();
	}

	public static function defineWorlds(forStage:Int):Void {
        var stages = Main.user.isEasyMode() ? Config.STAGES_EASY : Config.STAGES;
		if (forStage > stages.length) {
			trace("!!!! ERROR !!!!!, stage not exists");
			return;
		}
		instance.clear();
		for (world in stages[forStage]) {
			if (!instance.exists(world)) {
				defineWorld(world, false);
			}
		}
	}

	public static function defineWorld(name:String, owned:Bool = false):WorldDef {
		var wd = new WorldDef(name, Config.MAP_PATH + name + ".tmx");
		wd.owned = owned;
		instance.add(wd);
		return wd;
	}

	public static function reset():Void {
		for (w in instance.list) {
			w.owned = false;
		}
		instance.collectedCount = 0;
	}

	public function get_collectedCount():Int {
		var count:Int = 0;
		for (w in list) {
			if (w.owned) count++;
		}
		return count;
	}
}