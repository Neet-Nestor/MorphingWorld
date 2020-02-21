package;

import sys.Http;
import haxe.Json;

class Logger {
    public function new() {
        
    }

    public function logExit(last: String, times: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "type" : "EXIT",
            "lastStage" : last,
            "times" : times,
            "settings" : Main.user.getSettings()
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    public function logStart(times: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "type" : "Start",
            "times" : times
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    public function logPass(level: String):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "type" : "Pass",
            "level" : level
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    // on collect
    public function logCollect(level:String, gem:String):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "type" : "Collect",
            "level" : level,
            "gem" : gem
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    // on win
    public function logWin():Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "type" : "Win"
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    // on die
    public function logDie(level:String):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "type" : "Die",
            "level" : level
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    private function commit(content:String):Void {
        trace("content: " + content);
        var req = new Http("45.32.231.66:4596/api/mwlog");
        req.addHeader("Content-Type", "application/json");
        req.setPostData(content);
        req.onStatus = function(status:Int) {
            if (status == 200) {
                trace ("Logging successful");
            } else {
                trace ("Logginig Unsuccessful, error: " + status);
            }
        }
        req.onError = function(msg: String) {
            trace("Error: msg: " + msg);
        }
        req.request(true);
    }
}