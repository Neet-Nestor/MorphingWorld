package game;

import states.PlayState;
import sprites.TiledSprite;
import sprites.Player;
import sprites.PhysSprite;
import nape.phys.Material;
import nape.phys.BodyType;
import nape.phys.Body;
import nape.geom.Vec2;
import nape.dynamics.InteractionGroup;
import nape.constraint.WeldJoint;
import nape.constraint.PivotJoint;
import nape.constraint.AngleJoint;
import lycan.world.layer.TileLayer;
import lycan.world.layer.PhysicsTileLayer;
import lycan.world.layer.ObjectLayer;
import flixel.system.FlxAssets;
import lycan.world.components.PhysicsEntity;
import lycan.world.WorldLayer;
import lycan.world.WorldHandlers;
import lycan.world.TiledWorld;
import lycan.system.FpsText;
import lycan.states.LycanState;
import lycan.phys.PlatformerPhysics;
import lycan.phys.Phys;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import haxe.io.Path;
import haxe.ds.Map;
import flixel.util.FlxPath;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.math.FlxPoint;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxBasic;
import config.Config;

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

	public function setupLayerHandlers():Void {
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
				// tl.body.shapes.foreach(s->s.filter = PlatformerPhysics.worldFilter);
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
				layer.worldLayer.world.layers.set(tiledLayer.name, spr);

				// TODO better unification of layer and object loading
				setCollisionGroup(tiledLayer, layer, layer.worldLayer.world.layers);

				var bodyType:Null<String> = tiledLayer.properties.get("bodyType");
				if (bodyType != null) setBodyType(tl, bodyType);

				var weldId:Null<Int> = tiledLayer.properties.getInt("weldTo");
				if (weldId != null) {
					layer.worldLayer.world.onLoadingComplete.addOnce(()->{
						weld(tl, layer.worldLayer.world.layers.get(weldId));
					});
				}
			}
		});

		// TODO duplicated, implement for layers and layers at same time
		layerLoadedHandlers.add(function(tiledLayer, layer) {
			layer.worldLayer.world.onLoadingComplete.addOnce(()->{
				if (tiledLayer.properties.contains("onLoad")) {
					var expr = PlayState.instance.parser.parseString(tiledLayer.properties.get("onLoad"));
					PlayState.instance.interp.execute(expr);
				}
			});
		});
	}

	public function setupObjectHandlers():Void {
		var spriteZoom = Config.SPRITE_ZOOM;

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
			// Offset layers based on world offset
			trace((cast layer.worldLayer.world:MiniWorld).x);
			obj.x += Math.round((cast layer.worldLayer.world:MiniWorld).x);
			obj.y += Math.round((cast layer.worldLayer.world:MiniWorld).y);
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

		var runlayerscript = function(obj:Dynamic, expr:Expr, world:TiledWorld) {
			PlayState.instance.interp.variables.set("obj", obj);
			PlayState.instance.interp.variables.set("world", world);
			PlayState.instance.interp.variables.set("object", function(id) {
				return world.layers.get(id);
			});
			PlayState.instance.interp.execute(expr);
			PlayState.instance.interp.variables.remove("obj");
		}

		loadObject("player", (obj, layer, map)->{
			var player:Player = playState.player;
			if (player == null) {
				player = new Player(0, 0, Config.PLAYER_WIDTH, Config.PLAYER_HEIGHT);
			}
			if (PlayState.instance.reloadPlayerPosition) {
				PlayState.instance.reloadPlayerPosition = false;
				player.physics.body.position.setxy(obj.x, obj.y + obj.height / 2 - Config.PLAYER_HEIGHT / 2);
				player.physics.snapEntityToBody();
				map.set(obj.name, player);
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
			map.set(obj.name, block);
			layer.add(block);
		});

		objectHandlers.add((obj, layer, map)->{
			if (!obj.properties.getBool("visible", true)) {
				map[obj.name].visible = false;
			}
		});

		// The default object just creates a FlxSprite with image
		objectHandlers.add((obj, layer, map)->{
			if (obj.type == "") {
				var spr = new FlxSprite(getGraphicFromTile(obj));
				spr.setCenter(obj.x, obj.y);
				layer.add(spr);
				map.set(obj.name, spr);
			}
		});

		lateLoad((obj, layer, map)->{
			var o = map.get(obj.name);
			if (!Std.is(o, FlxSprite)) return;
			var s:FlxSprite = cast o;
			s.flipX = obj.flippedHorizontally;
			s.flipY = obj.flippedVertically;
			null;
		});

		// TODO better way to do for both layers and tilemaps
		objectHandlers.add((obj, layer, map)->{
			setCollisionGroup(obj, layer, map);
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("bodyType")) {
				var po:PhysicsEntity = cast map.get(obj.name);
				setBodyType(po, obj.properties.get("bodyType"));

			}
		});

		//TODO split into components... and you know... make all of this nicer
		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("padHitbox")) {
				var po:PhysicsEntity = cast map.get(obj.name);
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
				map[obj.name] = joint;
			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.getBool("oneway")) {
				var po:PhysicsEntity = cast map.get(obj.name);
				po.physics.body.cbTypes.add(PlatformerPhysics.onewayType);

			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("weldTo")) {
				var weldTarget:PhysicsEntity = cast map.get(obj.properties.getInt("weldTo"));
				var weldee:PhysicsEntity = cast map.get(obj.name);
				weld(weldTarget, weldee);
			}
		});

		lateLoad((obj, layer, map)->{
			if (obj.properties.contains("onLoad")) {
				runlayerscript(map.get(obj.name), PlayState.instance.parser.parseString(obj.properties.get("onLoad")), layer.worldLayer.world);
			}
		});

	}

	public function getGraphicFromTile(obj:TiledObject):FlxGraphicAsset {
			if (obj.gid > 0) {
				var graphicSrc = obj.layer.map.getGidOwner(obj.gid).getImageSourceByGid(obj.gid).source;
				var path = new Path(graphicSrc);
				// TODO better determination of asset path
				return "assets/images/" + path.file + "." + path.ext;
			}
			return null;
		}

    public function setBodyType(po:PhysicsEntity, bodyTypeString:String):Void {
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

	public function weld(weldTarget:PhysicsEntity, weldee:PhysicsEntity):Void {
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

	public function setCollisionGroup(obj:Dynamic, layer:WorldLayer, map:Map<Int, Dynamic>):Void {
		if (obj.properties.contains("collisionLayers")) {
			var groupName = obj.properties.get("collisionLayers");
			var groups = layer.worldLayer.world.collisionLayers;
			var group = groups.get(groupName);
			if (group == null) {
				group = new InteractionGroup(true);
				groups.set(groupName, group);
			}
			(cast (map[obj.name]):PhysicsEntity).physics.body.group = group;
		}
	}
}
