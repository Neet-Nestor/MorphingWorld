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
    public var text(default, set):String;
    public var hoveredOverlay:FlxSprite;
    public var disabledOverlay:FlxSprite;
    public var pressed:Bool;
    public var hidden(default, set):Bool;
	public var mousePos:FlxPoint;
    public var onClick:() -> Void;
    public var refCam:FlxCamera;
    public var disabled:Bool;

    public function new(x:Float, y:Float, text:String, ?onClick:() -> Void, disabled:Bool = false, ?referenceCamera:FlxCamera) {
        super();
        this.hidden = false;
        this.pressed = false;
        this.text = text;
        this.onClick = onClick != null ? onClick : () -> {};
        this.disabled = disabled;
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
        hoveredOverlay = new FlxSprite();
		hoveredOverlay.makeGraphic(200, 40);
		hoveredOverlay.anchorTo(background, 0, 0, 0, 0);
        hoveredOverlay.alpha = 0;

        disabledOverlay = new FlxSprite();
        disabledOverlay.makeGraphic(200, 40, FlxColor.GRAY);
		disabledOverlay.anchorTo(background, 0, 0, 0, 0);
        disabledOverlay.alpha = 0;

        add(background);
        add(label);
        add(hoveredOverlay);
        add(disabledOverlay);
    }

    override public function update(dt:Float):Void {
        super.update(dt);
        if (disabled) {
            disabledOverlay.alpha = 0.3;
        } else {
            disabledOverlay.alpha = 0;
        }
        // Click & Hover handling
        if (!hidden && !disabled) {
            FlxG.mouse.getScreenPosition(refCam, mousePos);

            if (background.overlapsPoint(mousePos)) {
                hoveredOverlay.alpha = 0.3;
            } else {
                hoveredOverlay.alpha = 0;
            }
    
            if (FlxG.mouse.justPressed && background.overlapsPoint(mousePos)) {
                // Mouse Down inside the button
                pressed = true;
                hoveredOverlay.alpha = 0;
            } else if (FlxG.mouse.justReleased) {
                // If clicked (mouse up inside && mouse previously down inside)
                if (background.overlapsPoint(mousePos) && pressed) onClick();
    
                pressed = false;
            }
    
            background.animation.play(pressed ? "pressed" : "idle");
        }
    }

    public function set_text(val:String):String {
        label.text = val;
        this.text = val;
        return val;
    }

    public function set_hidden(val:Bool):Bool {
        if (val) {
            this.background.alpha = 0.0;
            this.label.alpha = 0.0;
            this.hoveredOverlay.alpha = 0.0;
            this.disabledOverlay.alpha = 0.0;
        } else {
            this.background.alpha = 1.0;
            this.label.alpha = 1.0;
            this.hoveredOverlay.alpha = 0.3;
            this.disabledOverlay.alpha = 0.3;
        }
        this.hidden = val;
        return val;
    }

    override public function destroy():Void {
        super.destroy();
        mousePos.put();
    }
}