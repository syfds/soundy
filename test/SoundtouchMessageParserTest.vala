using GLib;

/* Copyright 2021 Sergej Dobryak <sergej.dobryak@gmail.com>
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*/

public void test_volume_updated_read() {
    string xml = """
    <updates deviceID="689E1991C463">
        <volumeUpdated>
            <volume>
                <targetvolume>34</targetvolume>
                <actualvolume>34</actualvolume>
                <muteenabled>false</muteenabled>
            </volume>
        </volumeUpdated>
    </updates>
    """;

    SoundtouchMessage message = new SoundtouchMessageParser().read(xml);
    assert(message is VolumeUpdatedMessage);

    VolumeUpdatedMessage volumeUpdated = (VolumeUpdatedMessage)message;

    assert(volumeUpdated.target_volume == 34);
    assert(volumeUpdated.actual_volume == 34);
    assert(volumeUpdated.mute_enabled == false);
}

public void test_now_playing_message_read() {
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><nowPlaying deviceID=\"689E1991C463\" source=\"TUNEIN\" sourceAccount=\"\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem><track>Bayern 3</track><artist>Martin Solveig - Hey Now</artist><album></album><stationName>Bayern 3</stationName><art artImageStatus=\"IMAGE_PRESENT\">http://cdn-albums.tunein.com/gn/95TC6BCT5Mg.jpg</art><favoriteEnabled /><playStatus>STOP_STATE</playStatus><streamType>RADIO_STREAMING</streamType></nowPlaying>";
    NowPlayingChangeMessage m = new NowPlayingChangeMessage.from_rest_api(xml);
    assert(m.image_url == "http://cdn-albums.tunein.com/gn/95TC6BCT5Mg.jpg");
    assert(m.artist == "Martin Solveig - Hey Now");
    assert(m.standby == false);
    assert(m.play_state == PlayState.STOP_STATE);
    assert(m.track == "Bayern 3");
    assert(m.device_id == "689E1991C463");
}

public void test_now_selection_update_message_read() {
    string xml= """
        <updates deviceID="689E1991C463">
            <nowSelectionUpdated>
                <preset id="2">
                    <ContentItem source="TUNEIN" type="stationurl" location="/v1/playback/station/s293289" sourceAccount="" isPresetable="true">
                        <itemName>ENERGY - HIT MUSIC ONLY !</itemName>
                        <containerArt>http://cdn-profiles.tunein.com/s293289/images/logoq.png?t=1</containerArt>
                    </ContentItem>
                </preset>
            </nowSelectionUpdated>
        </updates>
    """;

    var m = new NowSelectionChangeMessage(xml);
    assert(m.image_url == "http://cdn-profiles.tunein.com/s293289/images/logoq.png?t=1");
    assert(m.track == "ENERGY - HIT MUSIC ONLY !");
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
    assert(nowPlaying.is_radio_streaming == true);
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_now_playing_update_message_read", test_now_playing_update_message_read);
    Test.add_func("/test_now_selection_update_message_read", test_now_selection_update_message_read);
    Test.add_func("/test_volume_updated_message_read", test_volume_updated_read);
    Test.add_func("/test_now_playing_message_read", test_now_playing_message_read);
    return Test.run();
}
