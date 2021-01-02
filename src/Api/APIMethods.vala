public class GetMethod : Soundy.APIMethod, GLib.Object {
    private string path {set; get;}

    public GetMethod(string path) {
        this.path = path;
    }

    public override bool with_body() {return false;}
    public override string get_method() {return "GET";}
    public override uint8[] get_body() {assert_not_reached();}
    public override string get_path() {return path;}
}

public class GetVolume : GetMethod {
    public GetVolume() {
        base("/volume");
    }
}

public class GetNowPlaying : GetMethod {
    public GetNowPlaying() {
        base("/now_playing");
    }
}

