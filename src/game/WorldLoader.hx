package game;

import config.Config;
import sprites.PhysSprite;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.WorldHandlers;
import lycan.world.TiledWorld;
import lycan.world.layer.TileLayer;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.PhysicsTileLayer;
import lycan.world.components.PhysicsEntity;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.addons.editors.tiled.TiledMap;

using lycan.world.TiledPropertyExt;

class WorldLoader {

	public static var instance(default, never):WorldLoader = new WorldLoader();

	var objectHandlers:ObjectHandlers = new ObjectHandlers();
	var layerLoadedHandlers:LayerLoadedHandlers = new LayerLoadedHandlers();

	static var playState:PlayState;

	// TODO this is a bit of a hacky way of loading a map in an an offset. These are used within handlers for layers
	static var offsetX:Float = 0;
	static var offsetY:Float = 0;

	public function new() {
		setupObjectHandlers();
		setupLayerHandlers();
	}

	public static function load(world:MiniWorld, tiledMap:TiledMap, state:PlayState, offsetX:Float = 0, offsetY:Float = 0):TiledWorld {
		playState = state;

		world.x = offsetX;
		world.y = offsetY;

		world.load(tiledMap, instance.objectHandlers, instance.layerLoadedHandlers, WorldCollisionType.PHYSICS);

		world.forEachExists((o)->{
			if (Std.is(o, PhysicsTileLayer)) {
				var p:PhysicsEntity = cast o;
				var wasEnabled = p.physics.enabled;
				p.physics.enabled = false;
				p.physics.position.x += offsetX;
				p.physics.position.y += offsetY;
				p.physics.snapEntityToBody();
				p.physics.enabled = wasEnabled;
			}
		}, true);
		return world;
	}

	private function setupLayerHandlers():Void {
		layerLoadedHandlers.add(function(tiledLayer, layer) {
			if (layer.worldLayer.type == TiledLayerType.TILE) {
				var tl:PhysicsTileLayer = cast layer;
				tl.body.shapes.foreach(s->s.filter = PlatformerPhysics.worldFilter);
				if (tl.properties.getBool("oneway", false)) tl.body.shapes.foreach(s->s.cbTypes.add(PlatformerPhysics.onewayType));
			}
		});

		layerLoadedHandlers.add(function(tiledLayer, layer) {
			if (layer.worldLayer.type == TiledLayerType.TILE && Std.is(layer, PhysicsTileLayer)) {
				var tl:PhysicsTileLayer = cast layer;
				tl.body.shapes.foreach(s->s.filter = PlatformerPhysics.worldFilter);
				if (tl.properties.getBool("oneway", false)) tl.body.shapes.foreach(s->s.cbTypes.add(PlatformerPhysics.onewayType));
			}
		});

		layerLoadedHandlers.add(function(tiledLayer, layer) {
			if (layer.worldLayer.type == TiledLayerType.TILE) {
				var tl:TileLayer = cast layer;
				tl.alpha = tiledLayer.opacity;
				var scrollFactor = tiledLayer.properties.contains("scrollFactor") ? tiledLayer.properties.getFloat("scrollFactor") : 1;
				tl.scrollFactor.set(scrollFactor, scrollFactor);
			}
		});

		layerLoadedHandlers.add(function(tiledLayer, layer) {
			if (layer.worldLayer.type == TiledLayerType.TILE && tiledLayer.properties.contains("sprite")) {
				var tl:PhysicsTileLayer = cast layer;
				var spr = new TiledSprite();
				spr.initFromLayer(tl);
				tl.worldLayer.world.insert(tl.worldLayer.world.members.indexOf(tl), spr);
				tl.worldLayer.world.remove(tl);
				layer.worldLayer.world.objects.set(tiledLayer.id, spr);

				// TODO better unification of layer and object loading
				setCollisionGroup(tiledLayer, layer, layer.worldLayer.world.objects);

				var bodyType:Null<String> = tiledLayer.properties.get("bodyType");
				if (bodyType != null) setBodyType(tl, bodyType);

				var weldId:Null<Int> = tiledLayer.properties.getInt("weldTo");
				if (weldId != null) {
					layer.worldLayer.world.onLoadingComplete.addOnce(()->{
						weld(tl, layer.worldLayer.world.objects.get(weldId));
					});
				}
			}
		});

		// TODO duplicated, implement for layers and objects at same time
		layerLoadedHandlers.add(function(tiledLayer, layer) {
			layer.worldLayer.world.onLoadingComplete.addOnce(()->{
				if (tiledLayer.properties.contains("onLoad")) {
					var expr = PlayState.get.parser.parseString(tiledLayer.properties.get("onLoad"));
					PlayState.get.interp.execute(expr);
				}
			});
		});
	}

	private function setupObjectHandlers():Void {
		var spriteZoom = Config.spriteZoom;

		// Scale everything up and position it based on world pos
		objectHandlers.add((obj, layer, map)->{
			// Normalise object positions to be center
			var theta:Float = obj.angle * FlxAngle.TO_RAD;
			var isTile = obj.objectType == TiledObject.TILE;
			var hw = obj.width / 2;
			var hh = (isTile ? -1 : 1) * obj.height / 2;
			var sina = Math.sin(theta);
			var cosa = Math.cos(theta);

			obj.x = obj.x + hw * cosa - hh * sina;
			obj.y = obj.y + hw * sina + hh * cosa;

			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		});

		objectHandlers.add((obj, layer, map)->{
			// Offset objects based on world offset
			trace((cast layer.worldLayer.world:MiniWorld).x);
			obj.x += (cast layer.worldLayer.world:MiniWorld).x;
			obj.y += (cast layer.worldLayer.world:MiniWorld).y;
		});

		var loadObject = function(type:String, handler:ObjectHandler) {
			objectHandlers.add((obj, layer, map)->{
				if (obj.type.toLowerCase() == type.toLowerCase()) {
					handler(obj, layer, map);
				}
			});
		};

		var lateLoad = function(handler:ObjectHandler) {
			objectHandlers.add((obj, layer, map)->{
				layer.worldLayer.world.onLoadingComplete.addOnce(()->{
					handler(obj, layer, map);
				});
			});
		};

		var runObjectScript = function(obj:Dynamic, expr:Expr, world:TiledWorld) {
			PlayState.get.interp.variables.set("obj", obj);
			PlayState.get.interp.variables.set("world", world);
			PlayState.get.interp.variables.set("object", function(id) {
				return world.objects.get(id);
			});
			PlayState.get.interp.execute(expr);
			PlayState.get.interp.variables.remove("obj");
		}

		loadObject("player", (obj, layer, map)->{
			var player:Player = playState.player;
			if (player == null) {
				player = new Player(0, 0, Config.playerWidth, Config.playerHeight);
			}
			if (PlayState.get.reloadPlayerPosition) {
				PlayState.get.reloadPlayerPosition = false;
				player.physics.body.position.setxy(obj.x, obj.y + obj.height / 2 - Config.playerHeight / 2);
				player.physics.snapEntityToBody();
				map.set(obj.id, player);
				playState.player = player;
			}
		});

		loadObject("block", (obj, layer, map)->{
			var block = new PhysSprite();
			block.loadGraphic(getGraphicFromTile(obj));
			block.updateHitbox();
			block.physics.init(BodyType.STATIC);
			block.setCenter(obj.x, obj.y);
			block.physics.snapBodyToEntity();
			map.set(obj.id, block);
			layer.add(block);
		});

		objectHandlers.add((obj, layer, map)->{
			if (!obj.properties.getBool("visible", true)) {
				map[obj.id].visible = false;
			}
		});

		// The default object just creates a FlxSprite with image
		objectHandlers.add((obj, layer, map)->{
			if (obj.type == "") {
				var spr = new FlxSprite(getGraphicFromTile(obj));
				spr.setCenter(obj.x, obj.y);
				layer.add(spr);
				map.set(obj.id, spr);
			}
		});

		lateLoad((obj, layer, map)->{
			var o = map.get(obj.id);
			if (!Std.is(o, FlxSprite)) return;
			var s:FlxSprite = cast o;
			s.flipX = obj.flippedHorizontally;
			s.flipY = obj.flippedVertically;
			null;
		});

		// TODO better way to do for both objects and tilemaps
		objectHandlers.add((obj, layer, map)->{
			setCollisionGroup(obj, layer, map);
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("bodyType")) {
				var po:PhysicsEntity = cast map.get(obj.id);
				setBodyType(po, obj.properties.get("bodyType"));

			}
		});

		//TODO split into components... and you know... make all of this nicer
		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("padHitbox")) {
				var po:PhysicsEntity = cast map.get(obj.id);
				var pad:Float = cast obj.properties.getFloat("padHitbox");
				var verts = po.physics.body.shapes.at(0).castPolygon.localVerts;
				verts.at(0).x -= pad;
				verts.at(0).y -= pad;
				verts.at(1).x += pad;
				verts.at(1).y -= pad;
				verts.at(2).x += pad;
				verts.at(2).y += pad;
				verts.at(3).x -= pad;
				verts.at(3).y += pad;
			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.type == "pivotJoint") {
				var body1Id = obj.properties.getInt("body1", -1);
				var body2Id = obj.properties.getInt("body2", -1);
				var body1:Body = body1Id >= 0 ? map.get(body1Id).physics.body : Phys.space.world;
				var body2:Body = body2Id >= 0 ? map.get(body2Id).physics.body : Phys.space.world;
				var worldPoint:Vec2 = Vec2.get(obj.x, obj.y);
				var joint:PivotJoint = new PivotJoint(body1, body2, body1.worldPointToLocal(worldPoint), body2.worldPointToLocal(worldPoint));
				worldPoint.dispose();
				joint.space = Phys.space;
				map[obj.id] = joint;
			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.getBool("oneway")) {
				var po:PhysicsEntity = cast map.get(obj.id);
				po.physics.body.cbTypes.add(PlatformerPhysics.onewayType);

			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("weldTo")) {
				var weldTarget:PhysicsEntity = cast map.get(obj.properties.getInt("weldTo"));
				var weldee:PhysicsEntity = cast map.get(obj.id);
				weld(weldTarget, weldee);
			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("onLoad")) {
				runObjectScript(map.get(obj.id), PlayState.get.parser.parseString(obj.properties.get("onLoad")), layer.worldLayer.world);
			}
		});

	}

	private function getGraphicFromTile(obj:TiledObject):Void {
			if (obj.gid > 0) {
				var graphicSrc = obj.layer.map.getGidOwner(obj.gid).getImageSourceByGid(obj.gid).source;
				var path = new Path(graphicSrc);
				// TODO better determination of asset path
				return "assets/images/" + path.file + "." + path.ext;
			}
			return null;
		}

	private function setBodyType(po:PhysicsEntity, bodyTypeString:String):Void {
		var bodyType:BodyType = switch(bodyTypeString.toLowerCase()) {
			case "kinematic": BodyType.KINEMATIC;
			case "dynamic": BodyType.DYNAMIC;
			case "static": BodyType.STATIC;
			case _: throw("Invalid bodyType");
		}

		po.physics.body.type = bodyType;

		// HACK
		// No idea why, but kinematic stuff doesn't wake constraints properly without wake
		// This weird wake fixes it but makes gravity too high on dynamics... WTF
		if (bodyType == BodyType.KINEMATIC) {
			@:privateAccess Phys.space.zpp_inner.really_wake(po.physics.body.zpp_inner, false);
		}
	}

	private function weld(weldTarget:PhysicsEntity, weldee:PhysicsEntity):Void {
		var b1 = weldee.physics.body;
		var b2 = weldTarget.physics.body;
		var mid:Vec2 = Vec2.get((b1.position.x + b2.position.x) / 2, (b1.position.y + b2.position.y) / 2);
		var joint = new PivotJoint(b1, b2, b1.worldPointToLocal(mid), b2.worldPointToLocal(mid));
		joint.stiff = false;
		joint.frequency = 60;
		joint.damping = 1;
		joint.space = b1.space;//TODO compound?
		var diff = b2.rotation - b1.rotation;
		var joint2 = new AngleJoint(b1, b2, diff, diff);
		joint2.stiff = false;
		joint2.damping = 1;
		joint2.space = b1.space;
		joint2.frequency = 60;

		@:privateAccess joint.zpp_inner.wake();
	}

	private function setCollisionGroup(obj:Dynamic, layer:WorldLayer, map:Map<Int, Dynamic>):Void {
		if (obj.properties.contains("collisionGroup")) {
			var groupName = obj.properties.get("collisionGroup");
			var groups = layer.worldLayer.world.collisionGroups;
			var group = groups.get(groupName);
			if (group == null) {
				group = new InteractionGroup(true);
				groups.set(groupName, group);
			}
			(cast (map[obj.id]):PhysicsEntity).physics.body.group = group;
		}
	}
}
