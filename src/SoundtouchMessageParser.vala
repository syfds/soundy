public class SoundtouchMessageParser: GLib.Object {

    public SoundtouchMessage read(string xml) {

        if (xml.contains("nowPlayingUpdated")) {
            return new NowPlayingChangeMessage.from_websocket(xml);
        }

        return new SoundtouchMessage(NotificationType.NOW_PLAYING_CHANGE);
    }
}


public class SoundtouchMessage : GLib.Object {
    public NotificationType notification_type;

    public SoundtouchMessage(NotificationType notification_type) {
        this.notification_type = notification_type;
    }

    public NotificationType get_notification_type() {
        return notification_type;
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

        base(NotificationType.NOW_PLAYING_CHANGE);

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
