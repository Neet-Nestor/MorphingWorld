package;

import haxe.Json;

class User {
    private var res:{uuid: String, volume: Int, music: Bool, sound: Bool, lastStage:Int, playTimes: Int};

    public function new() {
        var _uuid = Uuid.v4();
        #if sys
        if (!sys.FileSystem.exists("data.json")) {
            // uuid and default settings
            res = {uuid: _uuid, volume: 100, music: true, sound: true, lastStage: -1, playTimes: 1};
            var content:String = haxe.Json.stringify(res);
            sys.io.File.saveContent("data.json", content);
            trace("uuid not found, generating new uuid");
        } else {
            var content:String = sys.io.File.getContent("data.json");
            res = haxe.Json.parse(content);
            res.playTimes = res.playTimes + 1;
            var content:String = haxe.Json.stringify(res);
            sys.io.File.saveContent("data.json", content);
            trace("uuid: " + res.uuid);
        }
        #else
        res = {uuid: _uuid, volume: 1, music: true, sound: true, playTimes: 1, lastStage: -1};
        trace("sys not available, generating new uuid");
        #end
    }

    public function getUUID():String {
        return this.res.uuid;
    }

    public function getSettings():{volume: Int, music: Bool, sound: Bool} {
        var result = {volume: res.volume, music: res.music, sound: res.sound};
        return result;
    }

    public function setSetting(setting: {volume: Int, music: Bool, sound: Bool}):Void {
        res.volume = setting.volume;
        res.music = setting.music;
        res.sound = setting.sound;
        save();
    }

    public function setLastStage(lastStage:Int):Void {
        if (lastStage > res.lastStage) {
            res.lastStage = lastStage;
            save();
        }
    }

    public function cleanSaveData():Void {
        res.playTimes = res.playTimes + 1;
        res.lastStage = -1;
        save();
    }

    public function getLastStage():Int {
        return res.lastStage;
    }

    public function getPlayTimes():Int {
        return res.playTimes;
    }

    public function save():Void {
        #if sys
        var content:String = haxe.Json.stringify(res);
        sys.io.File.saveContent("data.json", content);
        #end
    }
}