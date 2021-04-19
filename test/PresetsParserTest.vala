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


public void test_presets_read() {
    string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><presets><preset id=\"1\" createdOn=\"1545166209\" updatedOn=\"1607376626\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"catalog/playlists/recent/../B07KFB1CRN/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Akustik-Pop zum entspannten Arbeiten</itemName><containerArt>https://m.media-amazon.com/images/I/81+Cxr9XZSL._SX150_SY150_.jpg</containerArt></ContentItem></preset><preset id=\"2\" createdOn=\"1482155750\" updatedOn=\"1601714518\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"catalog/stations/recent/../A2G4Z50YFCKIB8/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Best Of Charts</itemName><containerArt>https://images-na.ssl-images-amazon.com/images/G/03/DE-digital-music/hawkfire/NewReleases/Editorial/130117_Best_of_Charts/DE_DM_BestofCharts_Station_480x480._V520474746_SX150_SY150_.jpg</containerArt></ContentItem></preset><preset id=\"3\" createdOn=\"1542824634\" updatedOn=\"1559414692\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s14991\" sourceAccount=\"\" isPresetable=\"true\"><itemName>Bayern 3</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s14991q.png</containerArt></ContentItem></preset><preset id=\"4\" createdOn=\"1482155972\" updatedOn=\"1542824623\"><ContentItem source=\"TUNEIN\" type=\"stationurl\" location=\"/v1/playback/station/s81838\" sourceAccount=\"\" isPresetable=\"true\"><itemName>DFM Russian Dance</itemName><containerArt>http://cdn-radiotime-logos.tunein.com/s81838q.png</containerArt></ContentItem></preset><preset id=\"5\" createdOn=\"1482159061\" updatedOn=\"1606600107\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"search/../catalog/albums/B01F0X3F08/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Meditationsmusik dezent – Entspannungsmusik zum Meditieren, Einschlafen und Stressabbau</itemName><containerArt>https://m.media-amazon.com/images/I/61Hj5hQtQWL._SX150_SY150_.jpg</containerArt></ContentItem></preset><preset id=\"6\" createdOn=\"1482413715\" updatedOn=\"1594539731\"><ContentItem source=\"AMAZON\" type=\"tracklist\" location=\"search/../catalog/albums/B01G823TR4/#playable\" sourceAccount=\"s@web.de\" isPresetable=\"true\"><itemName>Звучит</itemName><containerArt>https://m.media-amazon.com/images/I/81jd0IXoGuL.jpg</containerArt></ContentItem></preset></presets>";
    var m = new PresetsMessage(xml);
    assert(m.get_presets().size == 6);
}

public void test_presets_empty() {
    string xml = "<presets></presets>";
    var m = new PresetsMessage(xml);
    assert(m.get_presets().size == 0);
}

public void test_presets_empty_container_art() {
    string xml = """
        <presets>
            <preset id="1" createdOn="1524700000" updatedOn="1618000000">
                <ContentItem source="LOCAL_INTERNET_RADIO" type="stationurl" location="" sourceAccount="" isPresetable="true">
                    <itemName>LocalChannel</itemName>
                    <containerArt></containerArt>
                </ContentItem>
            </preset>
        </presets>
        """;

    var m = new PresetsMessage(xml);
    assert(m.get_presets().size == 1);
    assert(m.get_presets()[0].item_name == "LocalChannel");
    assert(m.get_presets()[0].item_id == "1");
    assert(m.get_presets()[0].item_image_url == "");
}

public void test_presets_one_preset() {
    string xml = """
        <presets>
            <preset id="1" createdOn="1524700000" updatedOn="1618000000">
                <ContentItem source="LOCAL_INTERNET_RADIO" type="stationurl" location="" sourceAccount="" isPresetable="true">
                    <itemName>LocalChannel</itemName>
                    <containerArt>http://amazon.aws.com/picture.png</containerArt>
                </ContentItem>
            </preset>
        </presets>
        """;

    var m = new PresetsMessage(xml);
    assert(m.get_presets().size == 1);
    assert(m.get_presets()[0].item_name == "LocalChannel");
    assert(m.get_presets()[0].item_id == "1");
    assert(m.get_presets()[0].item_image_url == "http://amazon.aws.com/picture.png");
}


public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_presets_read", test_presets_read);
    Test.add_func("/test_presets_one_preset", test_presets_one_preset);
    Test.add_func("/test_presets_empty", test_presets_empty);
    Test.add_func("/test_presets_empty_container_art", test_presets_empty_container_art);
    return Test.run();
}
