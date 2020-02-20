package lycan.util;

import haxe.ds.StringMap;

interface Named {
	public var name:String;
}

@:autoBuild(lycan.util.NamedCollectionBuilder.build())
class NamedCollection<T:Named> {
	public var list:Array<T>;
	public var map:StringMap<T>;
	
	public function new() {
		list = [];
		map = new StringMap<T>();
	}
	
	public function add(t:T):Void {
		list.push(t);
		map.set(t.name.toLowerCase(), t);
	}
		
	public function exists(key:String):Bool {
		return map.exists(key);
	}

	public function remove(key:String):Void {
		list.filter(t -> t.name.toLowerCase() != key.toLowerCase());
		map.remove(key);
	}

	public function clear():Void {
		list = [];
		map.clear();
	}
}
