public class SoundtouchMessageParser: GLib.Object {

    public SoundtouchMessage read(string xml) {

        if (xml.contains("nowPlayingUpdated")) {
            return new NowPlayingChangeMessage(xml);
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
    public NowPlayingChangeMessage(string xml) {
        base(NotificationType.NOW_PLAYING_CHANGE);

        var ctx = context(xml);
        string play_state_value = get_value(ctx, "/updates/nowPlayingUpdated/nowPlaying/playStatus");
        play_state = play_state_value == "STOP_STATE" ? PlayState.STOP_STATE : PlayState.PLAY_STATE;
    }
}

public enum PlayState {
    STOP_STATE,
    PLAY_STATE
}

public enum NotificationType {
    NOW_PLAYING_CHANGE
}
