package sprites;
import flixel.addons.ui.FlxSlider;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

class UISlider extends FlxSlider {
    public var refCam:FlxCamera;
    public var mousePos:FlxPoint;

    public function new(Object:Dynamic, VarString:String, X:Float = 0, Y:Float = 0, MinValue:Float = 0, MaxValue:Float = 10, Width:Int = 100, Height:Int = 15, Thickness:Int = 3, Color:Int = 0xFF000000, HandleColor:Int = 0xFF828282, referenceCamera:FlxCamera)
        {
            super(Object, VarString, X, Y, MinValue, MaxValue, Width, Height, Thickness, Color, HandleColor);
            refCam = referenceCamera;
            mousePos = FlxPoint.get();
        }

        override public function update(elapsed:Float):Void
            {
                // Clicking and sound logic
                if (isOverlap()) 
                {
                    if (hoverAlpha != 1)
                    {
                        alpha = hoverAlpha;
                    }
                    
                    #if FLX_SOUND_SYSTEM
                    if (hoverSound != null && !_justHovered)
                    {
                        FlxG.sound.play(hoverSound);
                    }
                    #end
                    
                    _justHovered = true;
                    
                    if (FlxG.mouse.pressed) 
                    {
                        handle.x = FlxG.mouse.getScreenPosition(refCam, mousePos).x;
                        updateValue();
                        
                        #if FLX_SOUND_SYSTEM
                        if (clickSound != null && !_justClicked) 
                        {
                            FlxG.sound.play(clickSound);
                            _justClicked = true;
                        }
                        #end
                    }
                    if (!FlxG.mouse.pressed)
                    {
                        _justClicked = false;
                    }
                }
                else 
                {
                    if (hoverAlpha != 1)
                    {
                        alpha = 1;
                    }
                    
                    _justHovered = false;
                }
                
                // Update the target value whenever the slider is being used
                if ((FlxG.mouse.pressed) && (isOverlap()))
                {
                    updateValue();
                }
                
                // Update the value variable
                if ((varString != null) && (Reflect.getProperty(_object, varString) != null))
                {
                    value = Reflect.getProperty(_object, varString);
                }
                
                // Changes to value from outside update the handle pos
                if (handle.x != expectedPos) 
                {
                    handle.x = expectedPos;
                }
                
                // Finally, update the valueLabel
                valueLabel.text = Std.string(FlxMath.roundDecimal(value, decimals));
                
                super.update(elapsed);
            }

    private function isOverlap():Bool {
        FlxG.mouse.getScreenPosition(refCam, mousePos);
        return this.overlapsPoint(mousePos);
    }

    override public function destroy():Void {
        super.destroy();
        mousePos.put();
    }
}
