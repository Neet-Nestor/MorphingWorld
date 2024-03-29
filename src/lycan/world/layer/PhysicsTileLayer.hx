package lycan.world.layer;

import lycan.world.WorldHandlers;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.world.WorldLayer;
import lycan.world.WorldHandlers;
import lycan.world.WorldLayer;
import lycan.world.components.PhysicsEntity;
import nape.callbacks.CbType;
import nape.callbacks.CbTypeList;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.tile.FlxBaseTilemap;
import flixel.system.FlxAssets;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import lycan.phys.Phys;

@:tink
class PhysicsTileLayer extends TileLayer implements PhysicsEntity {
	@:calc public var body:Body = physics.body;
	public var origin:FlxPoint;

	var _binaryData:Array<Int>;

	public function new(world:TiledWorld, tiledLayer:TiledTileLayer, bodyType:BodyType) {
		physics.init(bodyType, false);
		origin = FlxPoint.get();
		
		super(world, tiledLayer);
	}
	
	override public function setupCollisions(tiledLayer:TiledTileLayer):Void {
		setupCollideIndex(1, new Material(0, 1, 2, 0, 0.001), Phys.TILEMAP_SHAPE_TYPE);
		body.space = null;
		body.scaleShapes(scale.x, scale.y);
		body.space = Phys.space;
	}
	
	override public function loadMapFromCSV(MapData:String, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0,
			?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1):FlxTilemap {
		super.loadMapFromCSV(MapData, TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
		_binaryData = new Array<Int>();
		FlxArrayUtil.setLength(_binaryData, _data.length);
		return this;
	}

	override public function loadMapFromArray(MapData:Array<Int>, WidthInTiles:Int, HeightInTiles:Int, TileGraphic:FlxTilemapGraphicAsset,
			TileWidth:Int = 0, TileHeight:Int = 0, ?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1):FlxTilemap {
		super.loadMapFromArray(MapData, WidthInTiles, HeightInTiles, TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
		_binaryData = new Array<Int>();
		FlxArrayUtil.setLength(_binaryData, _data.length);
		return this;
	}

	override public function loadMapFrom2DArray(MapData:Array<Array<Int>>, TileGraphic:FlxTilemapGraphicAsset, TileWidth:Int = 0, TileHeight:Int = 0,
			?AutoTile:FlxTilemapAutoTiling, StartingIndex:Int = 0, DrawIndex:Int = 1, CollideIndex:Int = 1):FlxTilemap {
		super.loadMapFrom2DArray(MapData, TileGraphic, TileWidth, TileHeight, AutoTile, StartingIndex, DrawIndex, CollideIndex);
		_binaryData = new Array<Int>();
		FlxArrayUtil.setLength(_binaryData, _data.length);
		return this;
	}

	/**
	 * Adds a collision box for one tile at the specified position
	 * Using this many times will fragment the collider mesh, possibly impacting performance!
	 * If you are changing a lot of tiles, consider calling body.shapes.clear() and then setupCollideIndex or setupTileIndices
	 *
	 * @param	X		The X-Position of the tile
	 * @param	Y		The Y-Position of the tile
	 * @param	mat		The material for the collider. Defaults to default nape material
	 */
	public function addSolidTile(X:Int, Y:Int, ?mat:Material):Void {
		body.space = null;
		if (mat == null) {
			mat = new Material();
		}
		X *= _tileWidth;
		Y *= _tileHeight;
		var vertices = new Array<Vec2>();

		vertices.push(Vec2.get(X, Y));
		vertices.push(Vec2.get(X + _tileWidth, Y));
		vertices.push(Vec2.get(X + _tileWidth, Y + _tileHeight));
		vertices.push(Vec2.get(X, Y + _tileHeight));

		body.shapes.add(new Polygon(vertices, mat));

		body.space = Phys.space;
	}

	public function placeCustomPolygon(tileIndices:Array<Int>, vertices:Array<Vec2>, ?mat:Material):Void {
		body.space = null;
		var polygon:Polygon;
		for (index in tileIndices) {
			var coords:Array<FlxPoint> = getTileCoords(index, false);
			if (coords == null)
				continue;

			for (point in coords) {
				polygon = new Polygon(vertices, mat);
				polygon.translate(Vec2.get(point.x, point.y));
				body.shapes.add(polygon);
			}
		}

		body.space = Phys.space;
	}

	/**
	 * Builds the nape collider with all tiles indices greater or equal to CollideIndex
	 * as solid (like normally with FlxTilemap), and assigns the nape material
	 *
	 * @param	CollideIndex	All tiles with an index greater or equal to this will be solid
	 * @param	mat				The Nape physics material to use. Will use the default material if not specified
	 */
	public function setupCollideIndex(CollideIndex:Int = 1, ?mat:Material, ?cbType:CbType):Void {
		if (_data == null) {
			FlxG.log.error("loadMap has to be called first!");
			return;
		}
		var tileIndex = 0;
		// Iterate through the tilemap and convert it to a binary map, marking if a tile is solid (1) or not (0)
		for (y in 0...heightInTiles) {
			for (x in 0...widthInTiles) {
				tileIndex = x + (y * widthInTiles);
				_binaryData[tileIndex] = if (_data[tileIndex] >= CollideIndex) 1 else 0;
			}
		}
		constructCollider(mat, cbType);
	}

	/**
	 * Builds the nape collider with all indices in the array as solid, assigning the material
	 *
	 * @param	tileIndices		An array of all tile indices that should be solid
	 * @param	mat				The nape physics material applied to the collider. Defaults to nape default material
	 */
	public function setupTileIndices(tileIndices:Array<Int>, ?mat:Material, ?cbType:CbType):Void {
		if (_data == null) {
			FlxG.log.error("loadMap has to be called first!");
			return;
		}
		var tileIndex = 0;
		for (y in 0...heightInTiles) {
			for (x in 0...widthInTiles) {
				tileIndex = x + (y * widthInTiles);
				_binaryData[tileIndex] = if (Lambda.has(tileIndices, _data[tileIndex])) 1 else 0;
			}
		}
		constructCollider(mat, cbType);
	}

	public function constructCollider(?mat:Material, ?cbType:CbType):Void {
		if (mat == null) {
			mat = new Material();
		}
		var tileIndex = 0;
		var startRow = -1;
		var endRow = -1;
		var rects = new Array<FlxRect>();

		// Go over every column, then scan along them
		for (x in 0...widthInTiles) {
			for (y in 0...heightInTiles) {
				tileIndex = x + (y * widthInTiles);
				// Is that tile solid?
				if (_binaryData[tileIndex] == 1) {
					// Mark the beginning of a new rectangle
					if (startRow == -1)
						startRow = y;

					// Mark the tile as already read
					_binaryData[tileIndex] = -1;
				}
				// Is the tile not solid or already read
				else if (_binaryData[tileIndex] == 0 || _binaryData[tileIndex] == -1) {
					// If we marked the beginning a rectangle, end it and process it
					if (startRow != -1) {
						endRow = y - 1;
						rects.push(constructRectangle(x, startRow, endRow));
						startRow = -1;
						endRow = -1;
					}
				}
			}
			// If we reached the last line and marked the beginning of a rectangle, end it and process it
			if (startRow != -1) {
				endRow = heightInTiles - 1;
				rects.push(constructRectangle(x, startRow, endRow));
				startRow = -1;
				endRow = -1;
			}
		}

		body.space = null;
		// Convert the rectangles to nape polygons
		var vertices:Array<Vec2>;
		for (rect in rects) {
			vertices = new Array<Vec2>();
			rect.x *= _tileWidth;
			rect.y *= _tileHeight;
			rect.width++;
			rect.width *= _tileWidth;
			rect.height++;
			rect.height *= _tileHeight;

			vertices.push(Vec2.get(rect.x, rect.y));
			vertices.push(Vec2.get(rect.width, rect.y));
			vertices.push(Vec2.get(rect.width, rect.height));
			vertices.push(Vec2.get(rect.x, rect.height));
			var shape:Polygon = new Polygon(vertices, mat);
			if (cbType != null) shape.cbTypes.add(cbType);
			body.shapes.add(shape);
			rect.put();
		}

		body.space = Phys.space;
	}

	/**
	 * Scans along x in the rows between startY to endY for the biggest rectangle covering solid tiles in the binary data
	 *
	 * @param	StartX	The column in which the rectangle starts
	 * @param	startY	The row in which the rectangle starts
	 * @param	endY	The row in which the rectangle ends
	 * @return			The rectangle covering solid tiles. CAUTION: Width is used as bottom-right x coordinate, height is used as bottom-right y coordinate
	 */
	public function constructRectangle(startX:Int, startY:Int, endY:Int):FlxRect {
		// Increase startX by one to skip the first column, we checked that one already
		startX++;
		var rectFinished = false;
		var tileIndex = 0;
		// go along the columns from startX onwards, then scan along those columns in the range of startY to endY
		for (x in startX...widthInTiles) {
			for (y in startY...(endY + 1)) {
				tileIndex = x + (y * widthInTiles);
				// If the range includes a non-solid tile or a tile already read, the rectangle is finished
				if (_binaryData[tileIndex] == 0 || _binaryData[tileIndex] == -1) {
					rectFinished = true;
					break;
				}
			}
			if (rectFinished) {
				// If the rectangle is finished, fill the area covered with -1 (tiles have been read)
				for (u in startX...x) {
					for (v in startY...(endY + 1)) {
						tileIndex = u + (v * widthInTiles);
						_binaryData[tileIndex] = -1;
					}
				}
				// startX - 1 to counteract the increment in the beginning
				// Slight misuse of Rectangle here, width and height are used as x/y of the bottom right corner
				return FlxRect.get(startX - 1, startY, x - 1, endY);
			}
		}
		// We reached the end of the map without finding a non-solid/alread-read tile, finalize the rectangle with the map's right border as the endX
		for (u in startX...widthInTiles) {
			for (v in startY...(endY + 1)) {
				tileIndex = u + (v * widthInTiles);
				_binaryData[tileIndex] = -1;
			}
		}
		return FlxRect.get(startX - 1, startY, widthInTiles - 1, endY);
	}

	override public function destroy():Void {
		super.destroy();
		physics.destroy();
	}
}
