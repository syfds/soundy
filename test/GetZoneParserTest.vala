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


public void test_get_zone_old_style() {
    string xml = """
        <zone master="689E1991C463" senderIPAddress="192.168.1.252" senderIsMaster="true">
            <member ipaddress="192.168.1.251">9884E39B4656</member>
        </zone>
    """;
    var m = new GetZoneMessage.from_rest_api(xml);
    assert(m.master_mac_address == "689E1991C463");
    assert(m.members.size == 1);
    assert(m.members.get(0).ip_address == "192.168.1.251");
    assert(m.members.get(0).mac_address == "9884E39B4656");
    assert(m.master());
}
public void test_get_zone() {
    string xml = """
        <zone master="abcdef123-master">
          <member ipaddress="192.168.1.251">abcdef123-master</member>
          <member ipaddress="192.168.1.252">abcdef123-slave</member>
        </zone>
    """;
    var m = new GetZoneMessage.from_rest_api(xml);
    assert(m.master_mac_address == "abcdef123-master");
    assert(m.members.size == 2);
    assert(m.members.get(0).ip_address == "192.168.1.251");
    assert(m.members.get(0).mac_address == "abcdef123-master");
    assert(m.members.get(1).ip_address == "192.168.1.252");
    assert(m.members.get(1).mac_address == "abcdef123-slave");
}


public void test_get_empty_zone() {
    string xml = """
        <zone/>
    """;
    var m = new GetZoneMessage.from_rest_api(xml);
    assert(m.members.size == 0);
}

public int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_get_zone", test_get_zone);
    Test.add_func("/test_get_zone_old_style", test_get_zone_old_style);
    Test.add_func("/test_get_empty_zone", test_get_empty_zone);
    return Test.run();
}
