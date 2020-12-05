public class SoundtouchMessageParser: GLib.Object {

    public SoundtouchMessage read(string xml) {

        Xml.Doc* doc = Xml.Parser.parse_doc(xml);
        Xml.XPath.Context cntx = new Xml.XPath.Context(doc);
        Xml.XPath.Object* res = cntx.eval_expression("/nowPlaying/track");

        var track = res->nodesetval->item(0)->get_content();

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

}
public class NowPlayingChangeMessage : SoundtouchMessage {
    public PlayState play_state {get;set;}
    public NowPlayingChangeMessage(string xml) {
        base(NotificationType.NOW_PLAYING_CHANGE);

    }
}

public enum PlayState {
    STOP_STATE,
    PLAY_STATE
}

public enum NotificationType {
    NOW_PLAYING_CHANGE
}
