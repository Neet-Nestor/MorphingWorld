package game;

import states.PlayState;
import sprites.Player;
import nape.phys.Material;
import nape.phys.Body;
import lycan.world.layer.ObjectLayer;
import lycan.world.components.PhysicsEntity;
import lycan.world.WorldHandlers;
import lycan.world.TiledWorld;
import lycan.system.FpsText;
import lycan.states.LycanState;
import lycan.phys.PlatformerPhysics;
import lycan.phys.Phys;
import haxe.ds.Map;
import game.WorldCollection;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxBasic;
import config.Config;

/**
 * The preview of an actual World
 */
class MiniWorld extends TiledWorld {
	// TODO bring offsetting into here

	public var x:Float = 0;
	public var y:Float = 0;
	public var worldDef:WorldDef;

	public function new() {
		super(Config.SPRITE_ZOOM);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	public function bodyOverlaps(body:Body):Bool {
		return
			body.bounds.x < x + width &&
			body.bounds.max.x > x &&
			body.bounds.y < y + height &&
			body.bounds.max.y > y;
	}

}