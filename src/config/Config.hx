package config;

class Config {
	// Debug
    public static inline final IS_DEBUG:Bool = #if debug true #else false #end;

    // Number of frames on the player image per row
    public static inline final PLAYER_FRAME_PER_ROW:Int = 13;

    // Player image dimension in sprite sheet
    public static inline final PLAYER_HEIGHT:Int = 32;
    public static inline final PLAYER_WIDTH:Int = 32;
    public static inline final PLAYER_SCALE:Float = 1;

    // Map Path
    public static inline final MAP_PATH:String = "assets/data/";

	// Physics
    public static inline final GRAVITY:Float = 200;

	// Zoom
    public static inline final SPRITE_ZOOM:Int = 1;
	public static inline final DEFAULT_ZOOM:Float = 2;
	public static inline final WORLD_EDITING_ZOOM:Float = 0.5;

    // Camera
	public static inline final CAMERA_LERP_NORMAL:Float = 0.3;
    public static inline final CAMERA_OFFSET_Y:Float = -55;

    // World
	public static inline final TILE_SIZE:Int = 32;
	public static inline final WORLD_TILE_WIDTH:Int = 14;
	public static inline final WORLD_TILE_HEIGHT:Int = 14;
	public static inline final WORLD_WIDTH:Int = TILE_SIZE * WORLD_TILE_WIDTH;
    public static inline final WORLD_HEIGHT:Int = TILE_SIZE * WORLD_TILE_HEIGHT;
    public static inline final WORLD_TILE_PADDING:Int = 0; // How many empty tiles pad around the world (and can overlap with over worlds)
    public static inline final SWATCH_SCALE:Float = 2 / 5;
    
    public static final STAGES:Array<Array<String>> = [
        ["00_00"],
        ["01_00", "01_01"],
        ["02_00", "02_01"],
        ["03_00", "03_01"],
        ["04_00", "04_01", "04_02"],
        ["05_00"],
        ["win"]
    ];
}