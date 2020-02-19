package;

import haxe.Json;

class User {
    private var res:{uuid: String, volume: Int, music: Bool, sound: Bool, times: Int};
    private var last:String;
    public function new() {
        var _uuid = Uuid.v4();
        #if sys
        if (!sys.FileSystem.exists("data.json")) {
            // uuid and default settings
            res = {uuid: _uuid, volume: 100, music: true, sound: true, times: 1};
            var content:String = haxe.Json.stringify(res);
            sys.io.File.saveContent("data.json", content);
            trace("uuid not found, generating new uuid");
        } else {
            var content:String = sys.io.File.getContent("data.json");
            res = haxe.Json.parse(content);
            res.times = res.times + 1;
            var content:String = haxe.Json.stringify(res);
            sys.io.File.saveContent("data.json", content);
            trace("uuid: " + res.uuid);
        }
        #else
        res = {uuid: _uuid, volume: 1, music: true, sound: true, times: 1};
        trace("sys not available, generating new uuid");
        #end
        this.last = "Menu";
    }

    public function getUUID():String {
        return this.res.uuid;
    }

    public function getSettings():{volume: Int, music: Bool, sound: Bool} {
        var result = {volume: res.volume, music: res.music, sound: res.sound};
        return result;
    }

    public function save(setting: {volume: Int, music: Bool, sound: Bool}):Void {
        var _res = {uuid: res.uuid, volume: setting.volume, music: setting.music, sound: setting.sound, times: res.times};
        this.res = _res;
        #if sys
        var content:String = haxe.Json.stringify(res);
        sys.io.File.saveContent("data.json", content);
        #end
    }

    public function setLast(_last:String):Void {
        last = _last;
    }

    public function getLast():String {
        return last;
    }

    public function getTimes():Int {
        return res.times;
    }
}