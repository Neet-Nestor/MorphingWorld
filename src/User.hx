package;

class User {
    private var _uuid:String;
    public function new() {
        #if sys
        if (!sys.FileSystem.exists("data.json")) {
            _uuid = Uuid.v4();
            var user = {uuid: _uuid};
            var content:String = haxe.Json.stringify(user);
            sys.io.File.saveContent("data.json", content);
            trace("uuid not found, generating new uuid");
        } else {
            var content:String = sys.io.File.getContent("data.json");
            var res = haxe.Json.parse(content);
            _uuid = res.uuid;
            trace("uuid: " + _uuid);
        }
        #else
        _uuid = Uuid.v4();
        trace("sys not available, generating new uuid")
        #end
    }

    public function getUUID() {
        return this._uuid;
    }
}