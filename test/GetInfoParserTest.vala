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


public void test_get_info() {
    string xml = """
            <info deviceID="9884E39B4656">
                <name>2 dobrjachnaja kolonka</name>
                <type>SoundTouch 10</type>
                <margeAccountUUID>4893349</margeAccountUUID>
                <components>
                    <component>
                        <componentCategory>SCM</componentCategory>
                        <softwareVersion>26.0.1.46256.3990103 epdbuild.trunk.hepdswbld04.2020-08-02T22:43:32</softwareVersion>
                        <serialNumber>17066819903739342000120</serialNumber>
                    </component>
                    <component>
                        <componentCategory>PackagedProduct</componentCategory>
                        <softwareVersion>26.0.1.46256.3990103 epdbuild.trunk.hepdswbld04.2020-08-02T22:43:32</softwareVersion>
                        <serialNumber>069236P70730231AE</serialNumber>
                    </component>
                </components>
                <margeURL>https://streaming.bose.com</margeURL>
                <networkInfo type="SCM">
                    <macAddress>9884E39B4656</macAddress>
                    <ipAddress>192.168.1.251</ipAddress>
                </networkInfo>
                <networkInfo type="SMSC">
                    <macAddress>A81B6AAAEDE1</macAddress>
                    <ipAddress>192.168.1.251</ipAddress>
                </networkInfo>
                <moduleType>sm2</moduleType>
                <variant>rhino</variant>
                <variantMode>normal</variantMode>
                <countryCode>GB</countryCode>
                <regionCode>GB</regionCode>
            </info>
    """;
    var m = new GetInfoMessage.from_rest_api(xml);
    assert(m.speaker_name == "2 dobrjachnaja kolonka");
    assert(m.mac_address == "9884E39B4656");
    assert(m.ip_address == "192.168.1.251");
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_get_info", test_get_info);
    return Test.run();
}
