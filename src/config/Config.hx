package config;

class Config {
	// Debug
    public static inline var isDebug = #if debug true #else false #end;

    // Number of frames on the player image per row
    public static inline var playerFramePerRow:Int = 13;

    // Player image dimension in sprite sheet
    public static inline var playerHeight:Int = 32;
    public static inline var playerWidth:Int = 32;

    // Map Path
    public static inline var mapPath:String = "assets/data/";

	// Physics
    public static inline var gravity:Float = 800;

	// Window
    public static inline var spriteZoom:Int = 1;

    // Camera
	public static inline var cameraLerpNormal:Float = 0.3;
	public static inline var cameraOffsetY:Float = -55;
}