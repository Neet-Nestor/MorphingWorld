package states;

import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.FlxG;
import lime.system.System;
import lycan.states.LycanState;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIText;
import sprites.UIButton;

class MenuState extends LycanState {
    private var title:FlxText;

    override public function create():Void {
        super.create();
        // if (FlxG.sound.music == null) { // don't restart the music if it's already playing
        //     //FlxG.sound.playMusic(AssetPaths.bgmtemp2__ogg, 0.65, true);
        // }
        Main.sound.playMusic();
        loadBG();
        loadTitle();
        loadStart();
        loadSelectLevel();
        loadOptions();
        loadQuit();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    private function loadBG():Void {
        var back = new FlxSprite();
        back.loadGraphic(AssetPaths.menubg__jpg);
        back.x = 0;
        back.y = 0;
        add(back);
    }

    private function loadTitle():Void {
        title = new FlxText(0, 0, 0, "Morphing World", 48);
        title.screenCenter();
        title.y -= 30;
        add(title);
    }

    private function loadStart():Void {
        var startBtn = new UIButton(0, title.getScreenPosition().y + 100, "Start", onStart);
        startBtn.screenCenter(FlxAxes.X);
        add(startBtn);
    }

    private function loadSelectLevel():Void {
        var selectBtn = new UIButton(0, title.getScreenPosition().y + 145, "Select Level", onSelectLevel);
        selectBtn.screenCenter(FlxAxes.X);
        add(selectBtn);
    }

    private function loadOptions():Void {
        var optionsBtn = new UIButton(0, title.getScreenPosition().y + 190, "Options", onOption);
        optionsBtn.screenCenter(FlxAxes.X);
        add(optionsBtn);
    }

    // private function loadAboutUS():Void {
    //     // TODO: about us page
    //     var aboutUsBtn = new UIButton(0, title.getScreenPosition().y + 150, "About Us", () -> {});
    //     aboutUsBtn.screenCenter(FlxAxes.X);
    //     add(aboutUsBtn);
    // }

    private function loadQuit():Void {
        var quitUsBtn = new UIButton(0, title.getScreenPosition().y + 235, "Quit Game", onQuit);
        quitUsBtn.screenCenter(FlxAxes.X);
        add(quitUsBtn);
    }

    private function onStart():Void {
        FlxG.switchState(new PlayState());
    }

    private function onSelectLevel():Void {
        openSubState(new SelectLevelState());
    }

    private function onOption():Void {
        openSubState(new OptionState());
    }

    private function onQuit():Void {
        System.exit(0);
    }
}