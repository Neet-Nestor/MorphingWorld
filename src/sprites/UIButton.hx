package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class UIButton extends FlxSpriteGroup {
    public var background:FlxSprite;
    public var label:FlxText;
    public var overlay:FlxSprite;
    public var pressed:Bool;
    public var cb:() -> Void;

    public function new(x:Float, y:Float, text:String, cb:() -> Void) {
        super();
        this.pressed = false;
        this.cb = cb;

        background = new FlxSprite(x, y);
        background.loadGraphic(AssetPaths.uibutton__png, true, 200, 40);
        background.animation.add("idle", [0], 0);
        background.animation.add("pressed", [1], 0);
        background.animation.play("idle");

        label = new FlxText(text);
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

        if (FlxG.mouse.overlaps(this)) {
            overlay.alpha = 0.3;
        } else {
            overlay.alpha = 0;
        }

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this)) {
            // Mouse Down inside the button
            pressed = true;
        } else if (FlxG.mouse.justReleased) {
            // If clicked (mouse up inside && mouse previously down inside)
            if (FlxG.mouse.overlaps(this) && pressed) cb();

            pressed = false;
        }

        background.animation.play(pressed ? "pressed" : "idle");
    }
}