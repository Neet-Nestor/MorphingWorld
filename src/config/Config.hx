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
    public static inline final CAMERA_OFFSET_Y_DIALOG:Float = 25;

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
        ["00_00_00"], // 0
        ["00_01_00", "00_01_01"], // 1
        ["00_02_00", "00_02_01"], // 2
        ["00_03_00", "00_03_01"], // 3
        ["01_00_00", "01_00_01"], // 4
        ["01_01_00", "01_01_01"], // 5
        ["01_02_00", "01_02_01", "01_02_02"], // 6
        ["02_00_00"], // 7
        ["02_01_00", "02_01_01"], // 8
        ["02_02_00"], // 9
        ["02_03_00", "02_03_01", "02_03_02"], // 10
        ["02_04_00", "02_04_01", "02_04_02"], // 11
        ["02_05_00", "02_05_01", "02_05_02"], // 12
        ["win"]
    ];

    public static final STAGES_EASY:Array<Array<String>> = [
        ["00_00_00"], // 0
        ["00_01_00", "00_01_01"], // 1
        ["00_02_00", "00_02_01"], // 2
        ["00_03_00", "00_03_01"], // 3
        ["01_00_00", "01_00_01"], // 4
        ["01_01_00", "01_01_01"], // 5
        ["02_00_00"], // 7
        ["02_01_00", "02_01_01"], // 8
        ["02_02_00"], // 9
        ["02_03_00", "02_03_01", "02_03_02"], // 10
        ["02_04_00", "02_04_01", "02_04_02"], // 11
        ["01_02_00", "01_02_01", "01_02_02"], // 6
        ["02_05_00", "02_05_01", "02_05_02"], // 12
        ["win"]
    ];

    public static final INIT_UNIVERSE:Map<String, Map<{x:Int, y:Int}, String>> = [
        "00_02_00" => [ {x:0, y:0} => "00_02_00",
                        {x:1, y:0} => "00_02_01", {x:0, y:1} => "00_02_01", {x:-1, y:0} => "00_02_01", {x:0, y:-1} => "00_02_01",
                        {x:-1, y:-1} => "00_02_01", {x:-1, y:1} => "00_02_01", {x:1, y:-1} => "00_02_01", {x:1, y:1} => "00_02_01" ]
    ];

    public static final DIALOGS_KEYS:Map<Int, String> = [
        0 => "start", 1 => "pass", 9 => "difficult", 11 => "push", 12 => "soon"
    ]
    public static final DIALOGS_KEYS_EASY:Map<Int, String> = [
        0 => "start", 1 => "pass", 8 => "difficult", 10 => "push", 12 => "soon"
    ]
    
    public static final DIALOGS:Map<String, Array<{name:String, dialog:String, avatar:String}>> = [
        // start dialogs
        "start" => [
            {name: "You", dialog: "What Happened? Where am I?", avatar: AssetPaths.bob__png},
            {name: "Someone", dialog: "You are in a happy place.", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "Really? Who are you?", avatar: AssetPaths.bob__png},
            {name: "Someone", dialog: "My name is Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord.", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "Al..right. My name is Bob the guy.", avatar: AssetPaths.bob__png},
            {name: "Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord", dialog: "Hello, Bob de guy. It appears that you accidentally stepped foot in my land, the land of the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord. As the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord, the lord of this land, I welcome you to join me with this journey to explore the land of the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord.", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "Uhhhhh, can we just call you Vlad? And even though it’s my pleasure to “step foot” on your land, can you get me out of this place? I’m waiting on my pizza delivery. And no offense, it smells like someone died here and was rotten a hundreds of years ago.", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "Oh don’t worry about that, Bob the guy, what you just described is exactly what happened to this place.", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "How is this a happy place?", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "It’s a happy place for me! And don’t you worry about going out of this place. You are indeed a rare find. I just couldn’t get enough of human suffering. Enjoy the rest of your life here! HAHAHAHAHAHAHA...", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "...", avatar: AssetPaths.bob__png},
            {name: "A beautiful voice", dialog: "Hello, Bob the guy, my name is Angela Alicephere Von Rose...", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "Stop! You are Alice! What do you want?", avatar: AssetPaths.bob__png},
            {name: "Alice", dialog: "There there, Bob the guy. I’ll help you to get out of this world. See the door over there? Go to it!", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "Sure... If it isn’t obvious enough...", avatar: AssetPaths.bob__png}
        ],
        "pass" => [
            {name: "You", dialog: "Where am I now?", avatar: AssetPaths.bob__png},
            {name: "Alice", dialog: "You are in the other side of the portal you sweet dummy! See that loot box over there? Go fetch!", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "Hey!", avatar: AssetPaths.bob__png}
        ],
        "map_collected" => [
            {name: "You", dialog: "What now?", avatar: AssetPaths.bob__png},
            {name: "Alice", dialog: "This is a piece of map. The way the world looks is under your control. As long as you have the map pieces, you can build your own world with the pieces you have.", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "Then how would I do that?", avatar: AssetPaths.bob__png},
            {name: "Alice", dialog: "It’s simple, you just need the kind person sitting in front of the screen to press E for you.", avatar: AssetPaths.alice__png}
        ],
        "map_done" => [
            {name: "You", dialog: "Wow! That was amazing! Thank you! Whoever kind person you are! I’ll give you something good when you get me out of this place! Now lets get going!", avatar: AssetPaths.bob__png}
        ],
        "delete" => [
            {name: "You", dialog: "Looks like there is no way out...", avatar: AssetPaths.bob__png}
        ],
        "push" => [
            {name: "You", dialog: "Oh its getting physical", avatar: AssetPaths.bob__png}
        ],
        "difficult" => [
            {name: "You", dialog: "This one looks complicated, but you will help me right? Remember, there is something special for you when you help me get out. Thank you thank you thank you!", avatar: AssetPaths.bob__png}
        ],
        "soon" => [
            {name: "Alice", dialog: "Hang on tight! You are getting there!", avatar: AssetPaths.alice__png}
        ],
        "win" => [
            {name: "You", dialog: "Oh we are finally here! But why am I still in this nasty world?", avatar: AssetPaths.bob__png},
            {name: "Alice", dialog: "Because there is no way out in the land of the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord. HAHAHAHAHAHA", avatar: AssetPaths.alice__png},
            {name: "You", dialog: "???", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "Surprise! I, the great Vladimir Adolf Nashvile Wulfstan Agyros Van de Lord is a part time actor and Alice is my most popular persona!", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "???", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "There is no way out HAHAHAHAHA. You should see the look on your face!", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "I know, I am programed to only have two faces.", avatar: AssetPaths.bob__png},
            {name: "Vlad", dialog: "Oh you are such a buzzkill. Talking to you is no fun. I’ll just keep watching you die in this forgotten land HAHAHAHAHA!", avatar: AssetPaths.vlad__png},
            {name: "Vlad", dialog: "Vlad disappears", avatar: AssetPaths.vlad__png},
            {name: "You", dialog: "Alrght, thank you for getting me there, the kind person sitting in front of the screen.", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "Don’t worry about me, because I am just a character that you play in this game. So I’m technically not stocked in this world as I am not in this world. Well, I am, but you are not and I am you.", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "Anyways, you did get me here but technically you didn’t get me out of this world because I was not in this world. Well, I am, but you are not and I am you. I think you get the gist.", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "However, I’ll still give you something, not necessarily good, but something, just like the way you halfway completed your mission. Get it? You get me to win but not out of this world, and I give you something but not necessarily good?", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "You’ll get it eventually.", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "Here you go!", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "I hereby pronouce you \"The Lord of Morphing World\". Congratulations on your new title!", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "Cherish it, defend it. I trust you!", avatar: AssetPaths.bob__png},
            {name: "You", dialog: "Bye bye!", avatar: AssetPaths.bob__png}
        ]
    ];
}