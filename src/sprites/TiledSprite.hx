package sprites;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxSpriteUtil;
import lycan.world.layer.PhysicsTileLayer;
import nape.callbacks.CbType;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import nape.phys.BodyType;
import lycan.util.GraphicUtil;
import lycan.world.components.PhysicsEntity;
import lycan.game3D.components.Physics3D;
import lycan.entities.LSprite;
import lycan.world.components.Collectable;

class TiledSprite extends LSprite implements PhysicsEntity {
	public var layer:PhysicsTileLayer;
	
	var renderCamera:FlxCamera;
	
	public function new() {
		super();
		renderCamera = new FlxCamera();
	}
	
	public function initFromLayer(layer:PhysicsTileLayer):Void {
		this.layer = layer;
		
		var minX:Int = layer.widthInTiles;
		var maxX:Int = 0;
		var minY:Int = layer.widthInTiles;
		var maxY:Int = 0;
        for (x in 0...layer.widthInTiles) {
            for (y in 0...layer.heightInTiles) {
                if (layer.getTile(x, y) > 0) {
                    if (x < minX) minX = x;
                    if (y < minY) minY = y;
                    if (x > maxX) maxX = x;
                    if (y > maxY) maxY = y;
                }
            }
		}
		
		var actualWidth:Int = maxX - minX + 1;
		var actualHeight:Int = maxY - minY + 1;
		
		makeGraphic(Std.int(actualWidth * layer.tileWidth), Std.int(actualHeight * layer.tileHeight), 0, true);
		
		layer.camera = renderCamera;
		renderCamera.width = frameWidth;
		renderCamera.height = frameHeight;
		
		renderCamera.scroll.set(minX * layer.tileWidth, minY * layer.tileHeight);
		
		layer.draw();
		
		if (!FlxG.renderBlit) {
			@:privateAccess renderCamera.render();
		}
		
		GraphicUtil.drawCamera(this, renderCamera);
		
		physics.enableUpdate = true;
		physics.body = layer.physics.body;
		physics.enabled = false;
		physics.body.userData.entity = this;
		physics.body.align();
		var ax = physics.body.position.x - physics.body.bounds.x;
		var ay = physics.body.position.y - physics.body.bounds.y;
		origin.set(ax, ay);
		
		setPosition(minX * layer.tileWidth, minY * layer.tileHeight);
		physics.snapBodyToEntity();
		
		physics.enabled = true;
	}
	
	override function destroy():Void {
		super.destroy();
		layer.destroy();
	}
}