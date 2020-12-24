public class SoundtouchMessageParser: GLib.Object {

    public SoundtouchMessage read(string xml) {

        if (xml.contains("nowPlayingUpdated")) {
            return new NowPlayingChangeMessage.from_websocket(xml);
        }
        if (xml.contains("volumeUpdated")) {
            return new VolumeUpdatedMessage.from_websocket(xml);
        }

        return new SoundtouchMessage();
    }
}


public class SoundtouchMessage : GLib.Object {

    public SoundtouchMessage() {
    }


    public Xml.XPath.Context context(string xml) {
        Xml.Doc* doc = Xml.Parser.parse_doc(xml);
        Xml.XPath.Context cntx = new Xml.XPath.Context(doc);
        return cntx;
    }

    public string get_value(Xml.XPath.Context context, string xpath) {
        Xml.XPath.Object* res = context.eval_expression(xpath);
        return res->nodesetval->item(0)->get_content();
    }

    public int get_int_value(Xml.XPath.Context context, string xpath) {
        string value = get_value(context, xpath);
        return value.to_int();
    }

}
public class VolumeUpdatedMessage : SoundtouchMessage {

    public bool mute_enabled {get;set; default=false;}
    public uint8 target_volume {get;set; }
    public uint8 actual_volume {get;set;}


    public VolumeUpdatedMessage.from_websocket(string xml) {
        base();
        var ctx = this.context(xml);
        this.read_mute_enabled(ctx);
        this.read_target_volume(ctx);
        this.read_actual_volume(ctx);
    }


    public void read_mute_enabled(Xml.XPath.Context ctx) {
        var mute_enabled_string = get_value(ctx, "/updates/volumeUpdated/volume/muteenabled");
        this.mute_enabled = mute_enabled_string == "false" ? false : true;
    }

    public void read_target_volume(Xml.XPath.Context ctx) {
        this.target_volume = (uint8)get_int_value(ctx, "/updates/volumeUpdated/volume/targetvolume");
    }

    public void read_actual_volume(Xml.XPath.Context ctx) {
        this.actual_volume = (uint8)get_int_value(ctx, "/updates/volumeUpdated/volume/actualvolume");
    }
}
public class NowPlayingChangeMessage : SoundtouchMessage {
    public PlayState play_state {get;set;}
    public bool standby {get;set; default=false;}
    public string track {get;set; default="";}
    public string artist {get;set; default="";}
    public string image_url {get;set; default="";}

    private string base_xpath;

    public NowPlayingChangeMessage.from_rest_api(string xml) {
        this(xml, false);
    }

    public NowPlayingChangeMessage.from_websocket(string xml) {
        this(xml, true);
    }

    private NowPlayingChangeMessage(string xml, bool from_websocket) {

        base();

        this.base_xpath = from_websocket ? "/updates/nowPlayingUpdated" : "";

        var ctx = context(xml);
        if (xml.contains("STANDBY")) {
            this.standby = true;
        } else {
            this.read_play_state(ctx);
            this.read_track(ctx);
            this.read_artist(ctx);
            this.read_image_url(ctx);
        }
    }

    private void read_play_state(Xml.XPath.Context ctx) {
        string value = get_value(ctx, @"$base_xpath/nowPlaying/playStatus");
        play_state = value == "PAUSE_STATE" || value == "STOP_STATE" ? PlayState.STOP_STATE : PlayState.PLAY_STATE;

    }

    public void read_track(Xml.XPath.Context ctx) {
        track = get_value(ctx, @"$base_xpath/nowPlaying/track");
    }

    public void read_artist(Xml.XPath.Context ctx) {
        artist = get_value(ctx, @"$base_xpath/nowPlaying/artist");
    }

    public void read_image_url(Xml.XPath.Context ctx) {
        image_url = get_value(ctx, @"$base_xpath/nowPlaying/art");
    }
}

public enum PlayState {
    STOP_STATE,
    PLAY_STATE
}

public enum NotificationType {
    NOW_PLAYING_CHANGE
}

public class PresetsMessage : SoundtouchMessage {

    private Gee.ArrayList<Preset> presets = new Gee.ArrayList<Preset>();

    public PresetsMessage(string xml) {

        var ctx = context(xml);
        Xml.XPath.Object* result = ctx.eval_expression("count(//preset)");
        double count_preset = result->floatval;

        for (var i=1; i <= (int)count_preset; i++) {
            var item_id = get_value(ctx, @"/presets/preset[@id='$i']/@id");
            var item_name = get_value(ctx, @"/presets/preset[@id='$i']/ContentItem/itemName");
            var item_image_url = get_value(ctx, @"/presets/preset[@id='$i']/ContentItem/containerArt");
            var preset = new Preset();

            preset.item_id = item_id;
            preset.item_name = item_name;
            preset.item_image_url = item_image_url;
            presets.add(preset);

        }
        message("count preset " + result->floatval.to_string());

    }

    public Gee.ArrayList<Preset> get_presets() {
        return this.presets;
    }
}

public class Preset : GLib.Object {
    public string item_id {get;set;}
    public string item_name {get;set;}
    public string item_image_url {get;set;}
}
