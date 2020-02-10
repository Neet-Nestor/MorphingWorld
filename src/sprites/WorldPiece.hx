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
		
        // loadGraphic("assets/images/worldpiece.png", true, 25, 26, false);
		// animation.add("spinning", [0, 1, 2, 3, 4, 5], 10);
		// animation.play("spinning");
        makeGraphic(28, 28, FlxColor.WHITE);
		physics.init(BodyType.KINEMATIC, false, false);
		physics.createRectangularBody(28, 28, BodyType.KINEMATIC);
		physics.body.userData.entity = this;
		physics.enabled = true;
		physics.body.shapes.at(0).sensorEnabled = true;
		physics.body.cbTypes.add(WORLD_PIECE_TYPE);
		physics.body.shapes.at(0).filter = PlatformerPhysics.OVERLAPPING_OBJECT_FILTER;
		
		collectable.onCollect = function(c) {
			var player:Player = cast c;
			physics.enabled = false;
			physics.enableUpdate = false;
			moves = true;
			velocity.y = -250;
			acceleration.y = 550;
			// animation.curAnim.frameRate = 30;
			vanishTween = FlxTween.tween(this, {alpha: 0}, 0.7, {ease: FlxEase.quadIn});
			scaleTween = FlxTween.tween(this.scale, {x: 0, y: 0}, 0.7, {ease: FlxEase.quadIn});
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