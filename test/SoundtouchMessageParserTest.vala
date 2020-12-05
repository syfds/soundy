using GLib;


public void test_now_playing_message_read() {
    string xml="<updates deviceID=\"689E1991C463\"><nowPlayingUpdated><nowPlaying deviceID=\"689E1991C463\" source=\"TUNEIN\" sourceAccount=\"\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\" / v1 / playback / station / s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem><track>Bayern 3</track><artist>Snow Patrol - Chasing Cars</artist><album></album><stationName>Bayern 3</stationName><art artImageStatus=\"IMAGE_PRESENT\">http://cdn-albums.tunein.com/gn/VDR068M5JDg.jpg</art><favoriteEnabled /><playStatus>STOP_STATE</playStatus><streamType>RADIO_STREAMING</streamType></nowPlaying></nowPlayingUpdated></updates>";
    SoundtouchMessage message = new SoundtouchMessageParser().read(xml);
    assert(message is NowPlayingChangeMessage);
    assert(message.get_notification_type() == NotificationType.NOW_PLAYING_CHANGE);

    NowPlayingChangeMessage nowPlaying = (NowPlayingChangeMessage)message;

    assert(nowPlaying.track == "Bayern 3");
    assert(nowPlaying.artist == "Snow Patrol - Chasing Cars");
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_now_playing_message_read", test_now_playing_message_read);
    return Test.run();
}
