package sprites;

import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class UIButton extends FlxSpriteGroup {
    public var background:FlxSprite;
    public var label:FlxText;
    public var overlay:FlxSprite;
    public var pressed:Bool;
	public var mousePos:FlxPoint;
    public var onClick:() -> Void;
    public var refCam:FlxCamera;

    public function new(x:Float, y:Float, text:String, ?cb:() -> Void, ?referenceCamera:FlxCamera) {
        super();
        this.pressed = false;
        onClick = cb != null ? cb : () -> {};
        refCam = referenceCamera;
		mousePos = FlxPoint.get();

        background = new FlxSprite(x, y);
        background.loadGraphic(AssetPaths.uibutton__png, true, 200, 40);
        background.animation.add("idle", [0], 0);
        background.animation.add("pressed", [1], 0);
        background.animation.play("idle");

        label = new FlxText(text);
        label.size = 12;
        label.color = FlxColor.BLACK;
        label.x = background.x + (background.width / 2.0) - (label.width / 2.0);
        label.y = background.y + (background.height / 2.0) - (label.height / 2.0);

        // While hovering, show a white overlay
        overlay = new FlxSprite();
		overlay.makeGraphic(200, 40);
		overlay.anchorTo(background, 0, 0, 0, 0);
        overlay.alpha = 0;

        add(background);
        add(label);
        add(overlay);
    }

    override public function update(dt:Float):Void {
        super.update(dt);
        
        FlxG.mouse.getScreenPosition(refCam, mousePos);

        if (background.overlapsPoint(mousePos)) {
            overlay.alpha = 0.3;
        } else {
            overlay.alpha = 0;
        }

        if (FlxG.mouse.justPressed && background.overlapsPoint(mousePos)) {
            // Mouse Down inside the button
            pressed = true;
        } else if (FlxG.mouse.justReleased) {
            // If clicked (mouse up inside && mouse previously down inside)
            if (background.overlapsPoint(mousePos) && pressed) onClick();

            pressed = false;
        }

        background.animation.play(pressed ? "pressed" : "idle");
    }

    override public function destroy():Void {
        super.destroy();
        mousePos.put();
    }
}