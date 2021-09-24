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

using GLib;

public void test_now_playing_message_read() {
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><nowPlaying deviceID=\"689E1991C463\" source=\"TUNEIN\" sourceAccount=\"\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem><track>Bayern 3</track><artist>Martin Solveig - Hey Now</artist><album></album><stationName>Bayern 3</stationName><art artImageStatus=\"IMAGE_PRESENT\">http://cdn-albums.tunein.com/gn/95TC6BCT5Mg.jpg</art><favoriteEnabled /><playStatus>STOP_STATE</playStatus><streamType>RADIO_STREAMING</streamType></nowPlaying>";
    NowPlayingChangeMessage m = new NowPlayingChangeMessage.from_rest_api(xml);
    assert(m.image_present == true);
    assert(m.image_url == "http://cdn-albums.tunein.com/gn/95TC6BCT5Mg.jpg");
    assert(m.artist == "Martin Solveig - Hey Now");
    assert(m.source == StreamingSource.TUNEIN);
    assert(m.standby == false);
    assert(m.play_state == PlayState.STOP_STATE);
    assert(m.track == "Bayern 3");
    assert(m.device_id == "689E1991C463");
}

public void test_now_playing_message_bluetooth_source() {
    string xml = """
            <nowPlaying deviceID="9884E39B4656" source="BLUETOOTH" sourceAccount=""><ContentItem source="BLUETOOTH" location="" sourceAccount="" isPresetable="false"><itemName>Precision-5530-44d6a2b6</itemName></ContentItem><track></track><artist></artist><album></album><stationName>Precision-5530-44d6a2b6</stationName><art artImageStatus="SHOW_DEFAULT_IMAGE" /><skipEnabled /><playStatus>STOP_STATE</playStatus><skipPreviousEnabled /><connectionStatusInfo status="CONNECTED" deviceName="Precision-5530-44d6a2b6" /></nowPlaying>
            """;
    NowPlayingChangeMessage m = new NowPlayingChangeMessage.from_rest_api(xml);
    assert(m.image_present == false);
    assert(m.image_url == "");
    assert(m.station_name == "Precision-5530-44d6a2b6");
    assert(m.artist == "");
    assert(m.source == StreamingSource.BLUETOOTH);
    assert(m.standby == false);
    assert(m.play_state == PlayState.STOP_STATE);
    assert(m.track == "");
    assert(m.device_id == "9884E39B4656");
    assert(m.connection_status == ConnectionStatus.CONNECTED);
}


public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_now_playing_message_read", test_now_playing_message_read);
    Test.add_func("/test_now_playing_message_bluetooth_source", test_now_playing_message_bluetooth_source);
    return Test.run();
}
