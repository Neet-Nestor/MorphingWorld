package;

import sys.Http;
import haxe.Json;

class Logger {
    public var enabled:Bool;

    public function new() {
        enabled = #if FLX_NO_DEBUG true #else false #end;
    }

    public function logClose(lastStage: Int, times: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Close",
            "lastStage" : lastStage,
            "times" : times,
            "settings" : Main.user.getSettings()
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    public function logStart(times: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Start",
            "times" : times
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    public function logEnter(stage: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Enter",
            "stage" : stage
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }
    
    public function logExit(fromStage: Int, lastStage:Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Exit",
            "fromStage" : fromStage,
            "lastStage" : lastStage
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    public function logPass(stage: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Pass",
            "stage" : stage
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }
    
    public function logReset(stage: Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Reset",
            "stage" : stage
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    // on collect
    public function logCollect(stage:Int, gem:String):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Collect",
            "stage" : stage,
            "gem" : gem
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    // on win
    public function logWin():Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Win"
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    // on die
    public function logDie(stage:Int):Void {
        var log = {user: Main.user.getUUID(), timestamp: Sys.time(), data: {
            "easy" : Main.user.isEasyMode(),
            "type" : "Die",
            "stage" : stage
        }};
        var content:String = haxe.Json.stringify(log);
        commit(content);
    }

    private function commit(content:String):Void {
        if (enabled) {
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
}