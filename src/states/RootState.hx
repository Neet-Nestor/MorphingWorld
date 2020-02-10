package states;

import flixel.FlxG;
import lycan.states.LycanRootState;

class RootState extends LycanRootState {
	public function new() {
		super();
	}
	
	override public function create():Void {
        super.create();
		FlxG.scaleMode = new flixel.system.scaleModes.FillScaleMode();
        persistentUpdate = true;
        
		openSubState(new MenuState());
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);

		if (FlxG.keys.justPressed.R) {
			closeSubState();
			openSubState(new MenuState());
		}
	}
}