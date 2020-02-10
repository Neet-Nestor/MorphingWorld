package lycan.phys;


import flixel.math.FlxPoint;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import lime.math.Rectangle;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import lycan.world.components.Groundable;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import openfl.geom.Matrix3D;
import lycan.game3D.Point3D;
import lycan.game3D.PerspectiveProjection;

class Phys {
	public static var space:Space;

	/** Iterations for resolving velocity (default 10) */
	public static var velocityIterations:Int = 10;
	/** Iterations for resolving position (default 10) */
	public static var positionIterations:Int = 10;
	public static var steps:Int = 1;
	/** Force a fixed timestep for integrator. Null means use FlxG.elapsed */
	public static var forceTimestep:Null<Float> = null;

	public static var floorPos:Bool = false;

	public static var matrix3D:Matrix3D;
	public static var projection:PerspectiveProjection;//TODO general projections

	// CbTypes
	public static var tilemapShapeType:CbType = new CbType();
	public static var sensorFilter:InteractionFilter = new InteractionFilter(0, 0, 1, 1, 0, 0);

	public static function init():Void {
		if (space != null) return;
		space = new Space(Vec2.weak(0, 3));
		space.gravity.y = 2500;

		FlxG.signals.preUpdate.add(update);
		FlxG.signals.preStateSwitch.add(onStateSwitch);
	}

	public static function destroy():Void {
		space = null;

		FlxG.signals.preUpdate.remove(update);
		FlxG.signals.preStateSwitch.remove(onStateSwitch);

		GroundableComponent.clearGroundsSignal.removeAll();

	}

	/**
	 * Creates simple walls around the game area - useful for prototying.
	 *
	 * @param   minX        The smallest X value of your level (usually 0).
	 * @param   minY        The smallest Y value of your level (usually 0).
	 * @param   maxX        The largest X value of your level - 0 means FlxG.width (usually the level width).
	 * @param   maxY        The largest Y value of your level - 0 means FlxG.height (usually the level height).
	 * @param   thickness   How thick the walls are. 10 by default.
	 * @param   material    The Material to use for the physics body of the walls.
	 */
	public static function createWalls(minX:Float = 0, minY:Float = 0, maxX:Float = 0, maxY:Float = 0, thickness:Float = 10, ?material:Material):Body {
		if (maxX == 0) 	maxX = FlxG.width;
		if (maxY == 0)	maxY = FlxG.height;
		if (material == null) material = new Material();

		var walls:Body = new Body(BodyType.STATIC);

		// Left, right, top, bottom
		walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, minY, thickness, maxY - minY)));
		walls.shapes.add(new Polygon(Polygon.rect(maxX, minY, thickness, maxY - minY)));
		walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, minY - thickness, maxX - minX + thickness * 2, thickness)));
		walls.shapes.add(new Polygon(Polygon.rect(minX - thickness, maxY, maxX - minX + thickness * 2, thickness)));

		walls.space = space;
		walls.setShapeMaterials(material);

		return walls;
	}

	public static function update():Void {
		var dt = forceTimestep == null ? FlxG.elapsed : forceTimestep;
		if (space != null && dt > 0) {
			// TODO better method or location for this?
			GroundableComponent.clearGroundsSignal.dispatch();

			if (steps == 1) {
				space.step(dt, velocityIterations, positionIterations);
			} else {
				var sdt = dt / steps;
				var velItr = Std.int(velocityIterations / steps);
				var posItr = Std.int(positionIterations / steps);
				for (i in 0...steps) {
					space.step(sdt, velItr, posItr);
				}
			}

		}
	}

	private static function onStateSwitch():Void {
		if (space != null) {
			space.clear();
			space = null; // resets attributes like gravity.
		}
	}
}
