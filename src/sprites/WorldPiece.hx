package sprites;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lycan.phys.PlatformerPhysics;
import nape.callbacks.CbType;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import nape.phys.BodyType;
import lycan.util.GraphicUtil;
import lycan.world.components.PhysicsEntity;
import lycan.game3D.components.Physics3D;
import lycan.entities.LSprite;
import lycan.world.components.Collectable;
import game.WorldCollection;
import game.WorldDef;
import states.PlayState;

/**
  * Collectable World Pieces
  */
class WorldPiece extends LSprite implements PhysicsEntity implements Collectable {
    public static var WORLD_PIECE_TYPE:CbType = new CbType();
    
	public var worldDef:WorldDef;
	public var parentWorldDef:WorldDef;
	public var vanishTween:FlxTween;
	public var scaleTween:FlxTween;
	
	public function new() {
		super();
		
        loadGraphic(AssetPaths.chest__png, true, 32, 32, false);
		animation.add("open", [0], 0);
		animation.add("close", [1], 0);
		animation.play("close");
		physics.init(BodyType.STATIC, true, false);
		physics.body.userData.entity = this;
		physics.enabled = true;
		physics.body.shapes.at(0).sensorEnabled = true;
		physics.body.cbTypes.add(WORLD_PIECE_TYPE);
		physics.body.shapes.at(0).filter = PlatformerPhysics.OVERLAPPING_FILTER;
		
		collectable.onCollect = function(c) {
			var player:Player = cast c;
			physics.enabled = false;
			physics.enableUpdate = false;
			animation.play("open");
			if (!worldDef.owned) {
				worldDef.owned = true;
				new FlxTimer().start(0.22, (_) -> {PlayState.instance.collectWorld(worldDef);});
				PlayState.instance.universe.forEachOfType(WorldPiece, (piece) -> {
					if (piece.worldDef == worldDef && piece != this) piece.collectable.collect(player);
				}, true);
			}
			if (parentWorldDef != null) parentWorldDef.generatePreview();
		}
	}

    override public function destroy():Void {
		super.destroy();
		physics.destroy();
	}
}