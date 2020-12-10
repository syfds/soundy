using GLib;


public void test_presets_read() {
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><presets><preset id=\"1\" createdOn=\"1545166209\" updatedOn=\"1607376626\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"catalog/playlists/recent/../B07KFB1CRN/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Akustik-Pop zum entspannten Arbeiten</itemName><containerArt>https://m.media-amazon.com/images/I/81+Cxr9XZSL._SX150_SY150_.jpg</containerArt></ContentItem></preset><preset id=\"2\" createdOn=\"1482155750\" updatedOn=\"1601714518\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"catalog/stations/recent/../A2G4Z50YFCKIB8/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Best Of Charts</itemName><containerArt>https://images-na.ssl-images-amazon.com/images/G/03/DE-digital-music/hawkfire/NewReleases/Editorial/130117_Best_of_Charts/DE_DM_BestofCharts_Station_480x480._V520474746_SX150_SY150_.jpg</containerArt></ContentItem></preset><preset id=\"3\" createdOn=\"1542824634\" updatedOn=\"1559414692\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem></preset><preset id=\"4\" createdOn=\"1482155972\" updatedOn=\"1542824623\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s81838\" sourceAccount=\"\" isPresetable=\"true\"><itemName>DFM Russian Dance</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s81838q.png</containerArt></ContentItem></preset><preset id=\"5\" createdOn=\"1482159061\" updatedOn=\"1606600107\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"search/../catalog/albums/B01F0X3F08/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Meditationsmusik dezent – Entspannungsmusik zum Meditieren, Einschlafen und Stressabbau</itemName><containerArt>https://m.media-amazon.com/images/I/61Hj5hQtQWL._SX150_SY150_.jpg</containerArt></ContentItem></preset><preset id=\"6\" createdOn=\"1482413715\" updatedOn=\"1594539731\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"search/../catalog/albums/B01G823TR4/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Звучит</itemName><containerArt>https://m.media-amazon.com/images/I/81jd0IXoGuL.jpg</containerArt></ContentItem></preset></presets>";
    var m = new PresetsMessage(xml);
    assert(m.get_presets().size == 6);
}
public void test_now_playing_message_read() {
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><nowPlaying deviceID=\"689E1991C463\" source=\"TUNEIN\" sourceAccount=\"\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem><track>Bayern 3</track><artist>Martin Solveig - Hey Now</artist><album></album><stationName>Bayern 3</stationName><art artImageStatus=\"IMAGE_PRESENT\">http://cdn-albums.tunein.com/gn/95TC6BCT5Mg.jpg</art><favoriteEnabled /><playStatus>STOP_STATE</playStatus><streamType>RADIO_STREAMING</streamType></nowPlaying>";
    NowPlayingChangeMessage m = new NowPlayingChangeMessage.from_rest_api(xml);
    assert(m.image_url == "http://cdn-albums.tunein.com/gn/95TC6BCT5Mg.jpg");
    assert(m.artist == "Martin Solveig - Hey Now");
    assert(m.standby == false);
}


public void test_now_playing_update_message_read() {
    string xml="<updates deviceID=\"689E1991C463\"><nowPlayingUpdated><nowPlaying deviceID=\"689E1991C463\" source=\"TUNEIN\" sourceAccount=\"\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\" / v1 / playback / station / s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem><track>Bayern 3</track><artist>Snow Patrol - Chasing Cars</artist><album></album><stationName>Bayern 3</stationName><art artImageStatus=\"IMAGE_PRESENT\">http://cdn-albums.tunein.com/gn/VDR068M5JDg.jpg</art><favoriteEnabled /><playStatus>STOP_STATE</playStatus><streamType>RADIO_STREAMING</streamType></nowPlaying></nowPlayingUpdated></updates>";
    SoundtouchMessage message = new SoundtouchMessageParser().read(xml);
    assert(message is NowPlayingChangeMessage);

    NowPlayingChangeMessage nowPlaying = (NowPlayingChangeMessage)message;

    assert(nowPlaying.track == "Bayern 3");
    assert(nowPlaying.artist == "Snow Patrol - Chasing Cars");
    assert(nowPlaying.image_url == "http://cdn-albums.tunein.com/gn/VDR068M5JDg.jpg");
    assert(nowPlaying.standby == false);
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_now_playing_update_message_read", test_now_playing_update_message_read);
    Test.add_func("/test_now_playing_message_read", test_now_playing_message_read);
    Test.add_func("/test_presets_read", test_presets_read);
    return Test.run();
}
