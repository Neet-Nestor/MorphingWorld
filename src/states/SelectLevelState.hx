package states;

import config.Config;
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

class SelectLevelState extends LycanState {
    private var title:FlxText;
    private var up:UIButton;
    private var down:UIButton;
    private var btnArr:Array<UIButton>;
    private var page:Int;
    private var lastStageUnlocked:Int;

    override public function create():Void {
        super.create();
        // if (FlxG.sound.music == null) { // don't restart the music if it's already playing
        //     //FlxG.sound.playMusic(AssetPaths.bgmtemp2__ogg, 0.65, true);
        // }
        Main.sound.playMusic();
        lastStageUnlocked = Main.user.getLastStage();
        page = 0;
        loadBG();
        loadTitle();
        loadupdown();
        loadList();
        loadBack();
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
        title = new FlxText(0, 0, 0, "Select Level", 48);
        title.screenCenter();
        title.y -= 100;
        add(title);

        var hint = new FlxText(0, title.y + 50, 0, "You were at level " + Main.user.getLastStage(), 14);
        hint.screenCenter(FlxAxes.X);
        add(hint);
    }

    private function loadupdown():Void {
        up = new UIButton(0, title.getScreenPosition().y + 100, "Previous Page", onUp);
        up.screenCenter(FlxAxes.X);
        up.hidden = true;
        add(up);

        // down
        down = new UIButton(0, title.getScreenPosition().y + 420, "Next Page", onDown);
        down.screenCenter(FlxAxes.X);
        down.hidden = page * 5 + 5 >= Config.STAGES.length - 1;
        add(down);
    }

    private function loadList():Void {
        btnArr = [];
        for (i in 0...5) {
            var btn = new UIButton(0, title.getScreenPosition().y + 170 + 45 * i, "Level " + (i + 1), () -> {
                onSelect(i);
            });
            btn.screenCenter(FlxAxes.X);
            btn.disabled = i > lastStageUnlocked;
            btn.hidden = i >= Config.STAGES.length - 1;
            btnArr.push(btn);
            add(btn);
        }
    }

    private function onUp():Void {
        this.page -= 1;
        for (i in 0...5) {
            var level = page * 5 + i;
            btnArr[i].text = "Level " + (level + 1);
            btnArr[i].disabled = level > lastStageUnlocked;
            btnArr[i].hidden = level >= Config.STAGES.length - 1;
        }
        up.hidden = page == 0;
        down.hidden = page * 5 + 5 >= Config.STAGES.length - 1;
    }

    private function onDown():Void {
        this.page += 1;
        for (i in 0...5) {
            var level = page * 5 + i;
            btnArr[i].text = "Level " + (level + 1);
            btnArr[i].disabled = level > lastStageUnlocked;
            btnArr[i].hidden = level >= Config.STAGES.length - 1;
        }
        up.hidden = page == 0;
        down.hidden = page * 5 + 5 >= Config.STAGES.length - 1;
    }

    private function onSelect(i:Int):Void {
        var selected = page * 5 + i;
        if (selected <= lastStageUnlocked && selected < Config.STAGES.length - 1) {
            // move to the selected stage
            FlxG.switchState(new PlayState(selected));
        }
        trace("PANIC: select stage over bound");
    }

    private function loadBack():Void {
        var back = new UIButton(0, title.getScreenPosition().y + 490, "Back", () -> {
            FlxG.switchState(new MenuState());
        });
        back.screenCenter(FlxAxes.X);
        add(back);
    }
}