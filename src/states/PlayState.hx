package states;

import config.Config;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.MiniWorld;
import game.Universe;
import game.WorldCollection;
import game.WorldDef;
import game.WorldLoader;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import lycan.phys.Phys;
import lycan.phys.PlatformerPhysics;
import lycan.states.LycanState;
import lycan.world.layer.PhysicsTileLayer;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import Sound;
import sprites.Board;
import sprites.Button;
import sprites.CameraFocus;
import sprites.DamagerSprite;
import sprites.Player;
import sprites.Portal;
import sprites.PuffEmitter;
import sprites.WorldPiece;

class Hint {
    public var triggered:Bool;
    public var tween:FlxTween;
    public var text:FlxText;
    public var triggerCondition:Void -> Bool;
    public var callback:Void -> Void;

    public function new() { }
}

class PlayState extends LycanState {
    public var player:Player;
    public var universe:Universe;
	public var cameraFocus:CameraFocus;
    public var reloadPlayerPosition:Bool;
    public var curStage:Int;
    // For Dynamic difficulty change
    public var stageStartTime:Float;
    public var deathsInStage:Int;

    // For transition effects
    public var timeFactor(default, set):Float = 1;

    // For phys pausing
    public var oldVel:Vec2;

    // For emitter effects
	public var puffEmitter:PuffEmitter;

    // World Editing related
    public var isWorldEditing:Bool;
    public var editingTransitionAmount(default, set):Float = 0;

    // Disabled actions
    public var worldEditingDisabled:Bool;

    // Hints
    public var editHintShown:Bool;
    public var removeHintShown:Bool;
    public var hintList:List<Hint>;
    
    // Managers
	public var timers:FlxTimerManager;
    public var tweens:FlxTweenManager;

    // Sound
    public var _sndDie:FlxSound;

	public static var instance(default, null):PlayState;

    public function new(?initStage:Int) {
        super();
        instance = this;
        curStage = initStage == null ? 0 : initStage;
    }

    /**
     * From FlxState API Doc (http://api.haxeflixel.com/flixel/FlxState.html):
     *   We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
     **/
    override public function create():Void {
        Main.logger.logEnter(curStage);

		persistentDraw = true;
        persistentUpdate = true;
        reloadPlayerPosition = false;
        isWorldEditing = false;
        editHintShown = false;
        removeHintShown = false;
        deathsInStage = 0;
        worldEditingDisabled = curStage <= 1;
        hintList = new List<Hint>();
        _sndDie = FlxG.sound.load(AssetPaths.die__wav);
        // In case it was set before by fault
        Phys.FORCE_TIMESTEP = null;

        super.create();
        initPhysics();
        initManagers();
        WorldCollection.init();
        initUniverse();
        reloadStage();
        initCamera();
        add(player);

        // start dialog
        var dialogKey = null;
        switch curStage {
            case 0: dialogKey = "start";
            case 1: dialogKey = "pass";
            case 9: dialogKey = "difficult";
            case 11: dialogKey = "push";
            case 12: dialogKey = "soon";
            default: dialogKey = null;
        }

        if (curStage == Config.STAGES.length - 1) dialogKey = "win";

        if (dialogKey != null && Config.DIALOGS.exists(dialogKey)) {
            persistentUpdate = false;
            FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y_DIALOG;

            var dialogState = new DialogState(dialogKey);
            dialogState.closeCallback = () -> {
                persistentUpdate = true;
                FlxTween.tween(FlxG.camera.targetOffset, { y:Config.CAMERA_OFFSET_Y }, 0.3);
            }
            openSubState(dialogState);
        }
    }

    // Initializers

    private function initPhysics():Void {
        // Initialize physics
        Phys.init();
        PlatformerPhysics.setupPlatformerPhysics();

        // Setup gravity
        Phys.space.gravity.setxy(0, Config.GRAVITY);

        // Game listeners setup
        // -- Piece Found listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR,
            WorldPiece.WORLD_PIECE_TYPE, PlatformerPhysics.CHARACTER_TYPE, (cb:InteractionCallback) -> {
			var piece:WorldPiece = cast cb.int1.userData.entity;
			piece.collectable.collect((cb.int2.userData.entity:Player));
        }));
        
        // -- Portal listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR,
            Portal.PORTAL_TYPE, PlatformerPhysics.CHARACTER_TYPE, (cb:InteractionCallback) -> {
			var portal:Portal = cast cb.int1.userData.entity;
			portal.port((cb.int2.userData.entity:Player));
        }));
        
        // -- Damage listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION,
            PlatformerPhysics.CHARACTER_TYPE, DamagerSprite.DAMAGER_TYPE, function(cb:InteractionCallback) {
                die();
        }));
        
        // -- Switch listener
        Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR,
            PlatformerPhysics.CHARACTER_TYPE, Button.SWITCH_TYPE, function(cb:InteractionCallback) {
                var bt:Button = cast cb.int2.userData.entity;
                bt.switcher.on = true;
		}));
    }

    private function initManagers():Void {
		timers = new FlxTimerManager();
		tweens = new FlxTweenManager();
        puffEmitter = new PuffEmitter();
		add(timers);
        add(tweens);
        add(puffEmitter);
    }
    
    private function initUniverse():Void {
        universe = new Universe();
        reloadPlayerPosition = true;
        add(universe);
    }

    private function initCamera():Void {
        baseZoom = Config.DEFAULT_ZOOM;
        worldZoom = 1;
        
		cameraFocus = new CameraFocus();
		cameraFocus.add(new ObjectTargetInfluencer(player));
		FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
        FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
        if (curStage == 0 || curStage == 1 || curStage == 11 || curStage == Config.STAGES.length - 1) {
            FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y_DIALOG;
        }
		FlxG.camera.snapToTarget();
    }

    // FlxSprite Overrides

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Check any hint has been triggered
        for (hint in hintList) {
            if (!hint.triggered && hint.triggerCondition()) {
                hint.triggered = true;
                hint.callback();
            }
        }
        
        // actions
        if (FlxG.keys.anyJustPressed([FlxKey.UP, FlxKey.W, FlxKey.SPACE])) {
            player.characterController.jump();
        }
        if (FlxG.keys.anyPressed([FlxKey.LEFT, FlxKey.A])) {
            player.characterController.leftPressed = true;
        } else {
            player.characterController.leftPressed = false;
        }
        if (FlxG.keys.anyPressed([FlxKey.RIGHT, FlxKey.D])) {
            player.characterController.rightPressed = true;
        } else {
            player.characterController.rightPressed = false;
        }

        if (!worldEditingDisabled) {
            if (FlxG.mouse.wheel > 0) beginWorldEditing();
            else if (FlxG.mouse.wheel < 0) endWorldEditing();
            else if (FlxG.keys.anyJustReleased([FlxKey.E])) toggleWorldEditing();
        }
        
        if (FlxG.keys.anyJustPressed([FlxKey.ESCAPE])) {
            var pauseState = new PauseState();

            var prevPersistentUpdate = persistentUpdate;
            persistentUpdate = false;
            player.characterController.leftPressed = false;
            player.characterController.rightPressed = false;
            player.characterController.stop();
            pausePhys();
            
            if (subState != null) {
                subState.persistentUpdate = false;
                pauseState.closeCallback = () -> {
                    subState.persistentUpdate = true;
                    persistentUpdate = prevPersistentUpdate;
                    resumePhys();
                }
                subState.openSubState(pauseState);
            } else {
                pauseState.closeCallback = () -> {
                    persistentUpdate = prevPersistentUpdate;
                    resumePhys();
                }
                openSubState(pauseState);
            }
        }

        #if cpp
        if (FlxG.keys.anyJustPressed([FlxKey.F])) FlxG.fullscreen = !FlxG.fullscreen;
        #end

        // TODO: better way to detech death
        if (player.physics.body.velocity.y > 800) {
            die();
        }

        FlxG.watch.addQuick("player xy", FlxPoint.weak(player.x, player.y));
        FlxG.watch.addQuick("player position", player.physics.body.position);
        FlxG.watch.addQuick("player velocity", player.physics.body.velocity);
        FlxG.watch.addQuick("Space Gravity", Phys.space.gravity);
    }

	override public function draw():Void {
		cameraFocus.update(FlxG.elapsed);
		super.draw();
    }

    // Handlers
    public function die():Void {
        // Log
        deathsInStage++;
        Main.logger.logDie(curStage);

        endWorldEditing();
        player.characterController.hasControl = false;
        player.dead = true;
        player.characterController.stop();
        // Main.sound.playSound(Effect.Die, Main.user.getSettings().sound);
        if (Main.user.getSettings().sound) _sndDie.play();
        player.animation.finishCallback = (_) -> {
            persistentUpdate = false;
            pausePhys();
            var dieState = new DieState();
            dieState.closeCallback = () -> {
                remove(player);
                player.destroy();
                player = null;
                universe.reset();
                add(player);
                FlxG.camera.follow(null);
                cameraFocus.destroy();
                cameraFocus = new CameraFocus();
                cameraFocus.add(new ObjectTargetInfluencer(player));
                FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
                FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
                FlxG.camera.snapToTarget();
                persistentUpdate = true;
                resumePhys(false);
            }
            openSubState(dieState);
        };
    }

    public function onReload(pass:Bool = false):Void {
        if (isWorldEditing) endWorldEditing();
        if (subState != null) subState.close();
        // logging
        if (pass) {
            Main.logger.logPass(curStage);
            Main.user.setLastStage(curStage);
        }
        
        var passState = new BreakSplashState(pass ? this.toNextStage : this.reloadStage, true);
        persistentUpdate = false;
        player.characterController.hasControl = false;
        player.characterController.leftPressed = false;
        player.characterController.rightPressed = false;
        player.characterController.stop();
        pausePhys();
        passState.closeCallback = () -> {
            resumePhys(false);
            player.characterController.hasControl = true;
            persistentUpdate = true;
        };
        openSubState(passState);
    }

    public function toNextStage():Void {
        // Reset numbers
        deathsInStage = 0;

        // ABTest: Dynamically change difficulty
        if (curStage == 5) {
            var curTime = Sys.time();
            if (curTime - stageStartTime > 50 || deathsInStage > 2) {
                trace("Difficulty has been set to easy");
                Main.user.setDifficulty(User.Difficulty.EASY);
            }
        }

        if (Main.user.getDifficulty() == User.Difficulty.EASY) {
            // SKIP 6th stage
            curStage++;
        }
        curStage++;

        if (curStage >= Config.STAGES.length) {
            FlxG.switchState(new MenuState());
            close();
            return;
        }

        reloadStage();
    }

    override public function destroy():Void {
        PlayState.instance = null;
        super.destroy();
    }

    public function reloadStage():Void {
        WorldCollection.reset();
        WorldCollection.defineWorlds(curStage);
        remove(player);
        player.destroy();
        player = null;

        var nextWorld = WorldCollection.get(Config.STAGES[curStage][0]);
        if (nextWorld.name == "win") Main.logger.logWin();
        nextWorld.owned = true;
        universe.reset();
        add(player);
        FlxG.camera.follow(null);
        if (cameraFocus != null) {
            cameraFocus.destroy();
            cameraFocus = new CameraFocus();
            cameraFocus.add(new ObjectTargetInfluencer(player));
            FlxG.camera.follow(cameraFocus, FlxCameraFollowStyle.LOCKON, 0.12);
            FlxG.camera.targetOffset.y = Config.CAMERA_OFFSET_Y;
            FlxG.camera.snapToTarget();
        }
        showHints();

        // Reset start time
        stageStartTime = Sys.time();
    }

    public function showHints():Void {
        // Hint Setup
        if (curStage == 0) {
            // Move hint
            showHint("[A/D or LEFT/RIGHT to move]",
            () -> FlxG.keys.anyJustPressed([FlxKey.A, FlxKey.D, FlxKey.UP, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT]));
        } else if (curStage == 1) {
            showHint("[W/UP/SPACE to jump]", () -> FlxG.keys.anyJustPressed([FlxKey.UP, FlxKey.W, FlxKey.SPACE]));
        } else if (curStage == 3) {
            showHint("[S/Down to drop through boards]", () -> {
                var initSlot = universe.getSlot(0, 0);
                return initSlot == null || initSlot.world == null || !initSlot.world.bodyOverlaps(player.physics.body);
            });
        }
    }

    public function collectWorld(worldDef:WorldDef):Void {
        var foundState = new PieceFoundState(worldDef);
        player.characterController.hasControl = false;
        player.characterController.leftPressed = false;
        player.characterController.rightPressed = false;
        player.characterController.stop();
        pausePhys();
        if (isWorldEditing) {
            var editState:EditState = cast subState;
            editState.persistentUpdate = false;
            foundState.closeCallback = () -> {
                editState.persistentUpdate = true;
                player.characterController.hasControl = true;
                resumePhys();
                editState.addNewWorldPiece(worldDef);
            };
            editState.openSubState(foundState);
        } else {
            // Reset running status
            persistentUpdate = false;
            foundState.closeCallback = () -> {
                persistentUpdate = true;
                resumePhys();
                if (curStage == 1 && !editHintShown) {
                    worldEditingDisabled = false;
                    player.characterController.hasControl = false;
                    showHint("[Scroll Up or E to change the world]",
                        () -> FlxG.keys.anyJustPressed([FlxKey.E]) || FlxG.mouse.wheel > 0);
                } else {
                    player.characterController.hasControl = true;
                }
            };
            openSubState(foundState);
        }
    }

    public function beginWorldEditing():Void {
        if (isWorldEditing || WorldCollection.instance.collectedCount <= 0) {
            return;
        }
        isWorldEditing = true;
        exclusiveTween("editTransition", this, { editingTransitionAmount: 1 }, 0.7, { ease: FlxEase.quadOut });
        openSubState(new EditState());
    }

    public function endWorldEditing(?callback:Void -> Void, fast:Bool = false):Void {
        if (!isWorldEditing) {
            return;
        }
        isWorldEditing = false;
        exclusiveTween("editTransition", this, { editingTransitionAmount: 0 }, fast ? 0.4 : 0.6, { ease: FlxEase.quadOut });
        var editState:EditState = cast subState;
        editState.transitionOut(() -> {
            editState = null;
            if (callback != null) callback();
        }, fast);
    }

    public function toggleWorldEditing():Void {
        if (isWorldEditing) {
            endWorldEditing();
        } else {
            beginWorldEditing();
        }
    }

    // Helper functions
    // Transfer to hint state
    public function showHint(text:String, triggerCondition:Void -> Bool, ?cb:Void -> Void):Void {
        // cancel previous hint
        var hint = new Hint();
        hint.triggered = false;
        hint.text = new FlxText(0, FlxG.height - 50, 0, text, 20);
        hint.text.screenCenter(FlxAxes.X);
        hint.text.alpha = 0;
        hint.triggerCondition = triggerCondition;
        hint.callback = () -> {
            if (!hint.tween.finished) hint.tween.cancel();
            if (cb != null) cb();
            hintList.remove(hint);
            FlxTween.tween(hint.text, {alpha: 0}, 0.6, { onComplete: (_) -> {
                uiGroup.remove(hint.text);
            }});
        };
        hint.tween = FlxTween.tween(hint.text, {alpha: 1}, 0.6);
        hintList.add(hint);
        uiGroup.add(hint.text);
    }

    public function pausePhys():Void {
        oldVel = player.physics.body.velocity.copy(true);
        player.characterController.stop();
        player.physics.body.velocity.setxy(0, 0);
        Phys.space.gravity.y = 0;
        Phys.FORCE_TIMESTEP = 0;
    }

    public function resumePhys(resumeOldVel:Bool = true):Void {
        Phys.space.gravity.y = Config.GRAVITY;
        Phys.FORCE_TIMESTEP = null;
        if (resumeOldVel) player.physics.body.velocity.set(oldVel);
        oldVel = null;
    }
    
    // Setters

	private function set_timeFactor(val:Float):Float {
		this.timeFactor = val;
		// TODO: better solution for this
		Phys.FORCE_TIMESTEP = (val == 0) ? null : FlxG.elapsed * timeFactor;
		return val;
    }
    
    private function set_editingTransitionAmount(val:Float):Float {
		this.editingTransitionAmount = val;

		worldCamera.zoom = FlxMath.lerp(Config.DEFAULT_ZOOM, Config.WORLD_EDITING_ZOOM, val);
		worldCamera.targetOffset.y = Config.CAMERA_OFFSET_Y - val * 60;

		// music.volume = Math.max(0.01, 1 - val);
		// musicLowPass.volume = Math.max(0.01, val);

		// TODO: better solution for this
		Phys.FORCE_TIMESTEP = (val == 0) ? null : FlxG.elapsed * timeFactor;

		return val;
	}
}
