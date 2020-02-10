package lycan.world;

import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.util.helpers.FlxRange;
import flixel.util.FlxColor;
import lycan.util.ext.StringExt;

class TiledPropertyExt {
	public static function getBool(props:TiledPropertySet, key:String, defaultVal:Bool = false):Bool {
		var val = props.get(key);
		if (val != null)
			return val.toLowerCase() == "true";
		else
			return defaultVal;
	}
	
	public static function getInt(props:TiledPropertySet, key:String, defaultVal:Int = -1):Int {
		if (props.contains(key))
			return Std.parseInt(props.get(key));
		else
			return defaultVal;
	}
	
	public static function getFloat(props:TiledPropertySet, key:String, defaultVal:Int = -1):Float {
		if (props.contains(key))
			return Std.parseFloat(props.get(key));
		else
			return defaultVal;
	}

	public static function getString(props:TiledPropertySet, key:String, defaultVal:String = ""):String {
		if (props.contains(key))
			return props.get(key);
		else
			return defaultVal;
	}
	
	public static function getRange(props:TiledPropertySet, key:String):{min:Float, max:Float} {
		return (cast props.get(key):String).parseRange();
	}

	public static function getColor(props:TiledPropertySet, key:String, defaultVal:FlxColor = FlxColor.WHITE):FlxColor {
		var val = props.get(key);
		if (val != null) {
			var a:Array<Int> = haxe.Json.parse(val);
			return FlxColor.fromRGB(a[0], a[1], a[2]);
		} else {
			return defaultVal;
		}
	}
}