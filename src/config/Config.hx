package config;

class Config {
	// Debug
    public static inline var IS_DEBUG:Bool = #if debug true #else false #end;

    // Number of frames on the player image per row
    public static inline var PLAYER_FRAME_PER_ROW:Int = 13;

    // Player image dimension in sprite sheet
    public static inline var PLAYER_HEIGHT:Int = 32;
    public static inline var PLAYER_WIDTH:Int = 32;

    // Map Path
    public static inline var MAP_PATH:String = "assets/data/";

	// Physics
    public static inline var GRAVITY:Float = 800;

	// Zoom
    public static inline var SPRITE_ZOOM:Int = 1;
	public static inline var DEFAULT_ZOOM:Float = 2;
	public static inline var WORLD_EDITING_ZOOM:Float = 0.5;

    // Camera
	public static inline var CAMERA_LERP_NORMAL:Float = 0.3;
    public static inline var CAMERA_OFFSET_Y:Float = -55;

    // World
	public static inline var TILE_SIZE:Int = 32;
	public static inline var WORLD_TILE_WIDTH:Int = 14;
	public static inline var WORLD_TILE_HEIGHT:Int = 14;
	public static inline var WORLD_WIDTH = TILE_SIZE * WORLD_TILE_WIDTH;
    public static inline var WORLD_HEIGHT = TILE_SIZE * WORLD_TILE_HEIGHT;
    public static inline var WORLD_TILE_PADDING:Int = 0; // How many empty tiles pad around the world (and can overlap with over worlds)
	public static inline var SWATCH_SCALE:Float = 1 / 4;
}