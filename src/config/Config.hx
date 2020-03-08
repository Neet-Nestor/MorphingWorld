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

    // Spike bury offset
    public static inline final SPIKE_OFFSET_Y:Float = 6;

    // World
	public static inline final TILE_SIZE:Int = 32;
	public static inline final WORLD_TILE_WIDTH:Int = 14;
	public static inline final WORLD_TILE_HEIGHT:Int = 14;
	public static inline final WORLD_WIDTH:Int = TILE_SIZE * WORLD_TILE_WIDTH;
    public static inline final WORLD_HEIGHT:Int = TILE_SIZE * WORLD_TILE_HEIGHT;
    public static inline final WORLD_TILE_PADDING:Int = 0; // How many empty tiles pad around the world (and can overlap with over worlds)
    public static inline final SWATCH_SCALE:Float = 2 / 5;
    
    public static final STAGES:Array<Array<String>> = [
        ["00_00_00"],
        ["00_01_00", "00_01_01"],
        ["00_02_00", "00_02_01"],
        ["00_03_00", "00_03_01"],
        ["01_00_00", "01_00_01"],
        ["01_01_00", "01_01_01"],
        ["01_02_00", "01_02_01", "01_02_02"],
        ["05_00"],
        ["06_00", "06_01"],
        ["007_00"],
        ["07_00", "07_01", "07_02"],
        ["08_00", "08_01", "08_02"],
        ["09_00", "09_01", "09_02"],
        ["win"]
    ];

    public static final INIT_UNIVERSE:Map<Int, Map<{x:Int, y:Int}, String>> = [
        2 => [ {x:0, y:0} => "00_02_00",
               {x:1, y:0} => "00_02_01", {x:0, y:1} => "00_02_01", {x:-1, y:0} => "00_02_01", {x:0, y:-1} => "00_02_01",
               {x:-1, y:-1} => "00_02_01", {x:-1, y:1} => "00_02_01", {x:1, y:-1} => "00_02_01", {x:1, y:1} => "00_02_01" ]
    ];

    /**
    public static final DIALOGS:Map<Int, Array<{name:String, dialog:String, avatar:String}>> = [
        // start dialogs
        0 => [
            {name: "You", dialog: "What Happened? Where am I?", avatar: AssetPaths.bob__png},
            {name: "Someone", dialog: "You are in a happy place.", avatar: AssetPaths.dark__png},
            {name: "You", dialog: "Really? Who are you?", avatar: AssetPaths.bob__png},
            {name: "Someone", dialog: "My name is Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord.", avatar: AssetPaths.dark__png},
            {name: "You", dialog: "Al..right. My name is Bob the guy.", avatar: AssetPaths.bob__png},
            {name: "Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord", dialog: "Hello, Bob de guy. It appears that you accidentally stepped foot in my land, the land of the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord. As the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord, the lord of this land, I welcome you to join me with this journey to explore the land of the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord.", avatar: AssetPaths.dark__png},
            {name: "You", dialog: "Uhhhhh, can we just call you Vlad? And even though it’s my pleasure to “step foot” on your land, can you get me out of this place? I’m waiting on my pizza delivery. And no offense, it smells like someone died here and was rotten a hundreds of years ago.", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "Oh don’t worry about that, Bob the guy, what you just described is exactly what happened to this place.", avatar: AssetPaths.dark__png},
            {name: "You", dialog: "How is this a happy place?", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "It’s a happy place for me! And don’t you worry about going out of this place. You are indeed a rare find. I just couldn’t get enough of human suffering. Enjoy the rest of your life here! HAHAHAHAHAHAHA...", avatar: AssetPaths.dark__png},
            {name: "You", dialog: "...", avatar: AssetPaths.bob__png},
            {name: "A beautiful voice", dialog: "Hello, Bob the guy, my name is Angela Alicephere Von Rose...", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "Stop! You are Alice! What do you want?", avatar: AssetPaths.bob__png},
            {name: "Alice", dialog: "There there, Bob the guy. I’ll help you to get out of this world. See the door over there? Go to it!", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "Sure... If it isn’t obvious enough...", avatar: AssetPaths.bob__png}
        ]
    ];
    **/
}