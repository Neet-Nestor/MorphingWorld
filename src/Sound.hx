package;

import lime.media.vorbis.VorbisInfo;
import flixel.FlxG;
import flixel.system.FlxSound;

enum Effect {
    Jump1;
    Jump2;
    Step;
    Pass;
    Die;
}

class Sound {
    public var _sndStep:FlxSound;
	public var _sndJump1:FlxSound;
    public var _sndJump2:FlxSound;
    public var _sndPass:FlxSound;
    public var _sndDie:FlxSound;

    public function new() {
		_sndStep = FlxG.sound.load(AssetPaths.step__wav);
		_sndJump1 = FlxG.sound.load(AssetPaths.jump1__wav);
        _sndJump2 = FlxG.sound.load(AssetPaths.jump2__wav);
        _sndPass = FlxG.sound.load(AssetPaths.pass__wav);
        _sndDie = FlxG.sound.load(AssetPaths.die__wav);
        FlxG.sound.changeVolume(Main.user.getSettings().volume / 100 - FlxG.sound.volume);
    }

    public function playMusic(): Void {
        if (FlxG.sound.music == null) { // don't restart the music if it's already playing
            FlxG.sound.playMusic(AssetPaths.bgmtemp2__ogg, 0.65, true);
        }
        Main.user.getSettings().music;
        if (!Main.user.getSettings().music) {
            pauseMusic();
        }
    }

    public function pauseMusic(): Void {
        if (FlxG.sound.music != null && FlxG.sound.music.active) {
            FlxG.sound.music.pause();
        }
    }

    public function resumeMusic(): Void {
        if (FlxG.sound.music != null && !FlxG.sound.music.active) {
            FlxG.sound.music.resume();
        }
    }

    public function playSound(effect: Effect, play: Bool): Void {
        var sound:FlxSound;
        switch (effect) {
            case Jump1:
                sound = _sndJump1;
            case Jump2:
                sound = _sndJump2;
            case Step:
                sound = _sndStep;
            case Pass:
                sound = _sndPass;
            case Die:
                sound = _sndDie;
        }
        if (sound != null && play) {
            sound.play();
        }
    }
}