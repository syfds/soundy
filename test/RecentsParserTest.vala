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

public void test() {
    string xml = """
        <recents>
            <recent deviceID="689E1991C463" utcTime="1632515725" id="2349594630">
                <contentItem source="AMAZON" type="tracklist" location="catalog/playlists/recent/../B08831JDP2/#playable" sourceAccount="test@web.de" isPresetable="true">
                <itemName>Beats zur Motivation</itemName>
            </contentItem>
            </recent>
            <recent deviceID="689E1991C463" utcTime="1632515110" id="2388413506">
                <contentItem source="TUNEIN" type="stationurl" location="/v1/playback/station/s299243" sourceAccount="" isPresetable="true">
                <itemName>RDS Relax</itemName>
            </contentItem>
            </recent>
        </recents>    
        """;

    RecentsMessage m = new RecentsMessage(xml);
    assert(m.get_recents().size == 2);
    assert(m.get_recents().get(0).source == "AMAZON");
    assert(m.get_recents().get(0).source_account == "test@web.de");
    assert(m.get_recents().get(1).source == "TUNEIN");
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test", test);
    return Test.run();
}
