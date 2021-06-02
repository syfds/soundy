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

public class APIMethods : GLib.Object {
    public static Soundy.APIMethod play(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.PLAY, state);
    }

    public static Soundy.APIMethod power(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.POWER, state);
    }

    public static Soundy.APIMethod pause(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.PAUSE, state);
    }

    public static Soundy.APIMethod next(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.NEXT_TRACK, state);
    }

    public static Soundy.APIMethod previous(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.PREV_TRACK, state);
    }

    public static Soundy.APIMethod update_volume(uint8 actual_volume) {
        return new UpdateVolume(actual_volume);
    }

    public static Soundy.APIMethod get_now_playing() {
        return new GetNowPlaying();
    }

    public static Soundy.APIMethod get_volume() {
        return new GetMethod("/volume");
    }

    public static Soundy.APIMethod get_info() {
        return new GetMethod("/info");
    }

    public static Soundy.APIMethod get_zone() {
        return new GetZone();
    }
    public static Soundy.APIMethod set_zone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        return new SetZone(master_device_id_mac_address, zone_member_list);
    }
    public static Soundy.APIMethod add_to_zone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        return new AddToZone(master_device_id_mac_address, zone_member_list);
    }
    public static Soundy.APIMethod remove_zone_slave(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        return new RemoveZone(master_device_id_mac_address, zone_member_list);
    }

    public static Soundy.APIMethod play_preset(string item_id, KeyState state) {
        KeyAction preset;
        if (item_id == "1") {
            preset = KeyAction.PRESET_1;
        } else if (item_id == "2") {
            preset = KeyAction.PRESET_2;
        } else if (item_id == "3") {
            preset = KeyAction.PRESET_3;
        } else if (item_id == "4") {
            preset = KeyAction.PRESET_4;
        } else if (item_id == "5") {
            preset = KeyAction.PRESET_5;
        } else if (item_id == "6") {
            preset = KeyAction.PRESET_6;
        } else {
            assert_not_reached();
        }

        return new KeyMethod(preset, state);
    }
}

internal class GetMethod : Soundy.APIMethod, GLib.Object {
    private string path {set; get;}

    public GetMethod(string path) {
        this.path = path;
    }

    public string get_method() {return "GET";}
    public string get_body() {return ""; }
    public string get_path() {return path;}
}


internal class UpdateVolume : Soundy.APIMethod, GLib.Object {
    public uint8 actual_volume {set construct; get;}

    public UpdateVolume(uint8 actual_volume) {
        this.actual_volume = actual_volume;
    }

    public string get_path() {return "/volume";}
    public string get_method() {return "POST";}
    public string get_body() {
        return @"<volume>$actual_volume</volume>";
    }
}

internal class SetZone : Soundy.APIMethod, GLib.Object {
    public string master_device_id_mac_address {set construct; get;}
    public Gee.ArrayList<ZoneMember> zone_member_list {set construct; get;}

    public SetZone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        this.master_device_id_mac_address = master_device_id_mac_address;
        this.zone_member_list = zone_member_list;
    }

    public string get_path() {return "/setZone";}
    public string get_method() {return "POST";}
    public string get_body() {
        string start_tag = @"<zone master=\"$master_device_id_mac_address\">";
        string members = "";
        foreach(var member in zone_member_list){
            string mac_address = member.mac_address;
            string ip_address = member.ip_address;
            members += @"<member ipaddress=\"$ip_address\">$mac_address</member>";
        }
        string end_tag = "</zone>";

        return start_tag + members + end_tag;
    }
}

internal class RemoveZone : Soundy.APIMethod, GLib.Object {
    public string get_path() {return "/removeZoneSlave";}
    public string master_device_id_mac_address {set construct; get;}
    public Gee.ArrayList<ZoneMember> zone_member_list {set construct; get;}

    public RemoveZone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        this.master_device_id_mac_address = master_device_id_mac_address;
        this.zone_member_list = zone_member_list;
    }

    public string get_method() {return "POST";}
    public string get_body() {
        string start_tag = @"<zone master=\"$master_device_id_mac_address\">";
        string members = "";
        foreach(var member in zone_member_list){
            string mac_address = member.mac_address;
            string ip_address = member.ip_address;
            members += @"<member ipaddress=\"$ip_address\">$mac_address</member>";
        }
        string end_tag = "</zone>";

        return start_tag + members + end_tag;
    }
}
internal class AddToZone : Soundy.APIMethod, GLib.Object {
    public string get_path() {return "/addZoneSlave";}
    public string master_device_id_mac_address {set construct; get;}
    public Gee.ArrayList<ZoneMember> zone_member_list {set construct; get;}

    public AddToZone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        this.master_device_id_mac_address = master_device_id_mac_address;
        this.zone_member_list = zone_member_list;
    }

    public string get_method() {return "POST";}
    public string get_body() {
        string start_tag = @"<zone master=\"$master_device_id_mac_address\">";
        string members = "";
        foreach(var member in zone_member_list){
            string mac_address = member.mac_address;
            string ip_address = member.ip_address;
            members += @"<member ipaddress=\"$ip_address\">$mac_address</member>";
        }
        string end_tag = "</zone>";

        return start_tag + members + end_tag;
    }
}

internal class GetZone : GetMethod {
    public GetZone() {
        base("/getZone");
    }
}

internal class GetNowPlaying : GetMethod {
    public GetNowPlaying() {
        base("/now_playing");
    }
}

internal class KeyMethod : Soundy.APIMethod, GLib.Object {
    public KeyAction action {set construct; get;}
    public KeyState state {set construct; get;}

    internal KeyMethod(KeyAction action, KeyState state) {
        this.action = action;
        this.state = state;
    }
    public string get_path() {return "/key";}
    public string get_method() {return "POST";}
    public string get_body() {
        string action_as_string = action.to_string();
        string state_as_string = state.to_string();
        return @"<key state=\"$state_as_string\" sender=\"Gabbo\">$action_as_string</key>";
    }
}

public enum KeyState {
    RELEASE, PRESS;

    public string to_string() {
        switch (this){
            case PRESS : return "press";
            case RELEASE : return "release";
            default: assert_not_reached();
        }
    }
}

private enum KeyAction {
    PLAY,
    PAUSE,
    STOP,
    PREV_TRACK,
    NEXT_TRACK,
    THUMBS_UP,
    THUMBS_DOWN,
    BOOKMARK,
    POWER,
    MUTE,
    VOLUME_UP,
    VOLUME_DOWN,
    PRESET_1,
    PRESET_2,
    PRESET_3,
    PRESET_4,
    PRESET_5,
    PRESET_6,
    AUX_INPUT,
    SHUFFLE_OFF,
    SHUFFLE_ON,
    REPEAT_OFF,
    REPEAT_ONE,
    REPEAT_ALL,
    PLAY_PAUSE,
    ADD_FAVORITE,
    REMOVE_FAVORITE,
    INVALID_KEY;

    public string to_string() {
        switch (this){
            case PLAY : return "PLAY";
            case PAUSE : return "PAUSE";
            case STOP : return "STOP";
            case PREV_TRACK : return "PREV_TRACK";
            case NEXT_TRACK : return "NEXT_TRACK";
            case THUMBS_UP : return "THUMBS_UP";
            case THUMBS_DOWN : return "THUMBS_DOWN";
            case BOOKMARK : return "BOOKMARK";
            case POWER : return "POWER";
            case MUTE : return "MUTE";
            case VOLUME_UP : return "VOLUME_UP";
            case VOLUME_DOWN : return "VOLUME_DOWN";
            case PRESET_1 : return "PRESET_1";
            case PRESET_2 : return "PRESET_2";
            case PRESET_3 : return "PRESET_3";
            case PRESET_4 : return "PRESET_4";
            case PRESET_5 : return "PRESET_5";
            case PRESET_6 : return "PRESET_6";
            case AUX_INPUT : return "AUX_INPUT";
            case SHUFFLE_OFF : return "SHUFFLE_OFF";
            case SHUFFLE_ON : return "SHUFFLE_ON";
            case REPEAT_OFF : return "REPEAT_OFF";
            case REPEAT_ONE : return "REPEAT_ONE";
            case REPEAT_ALL : return "REPEAT_ALL";
            case PLAY_PAUSE : return "PLAY_PAUSE";
            case ADD_FAVORITE : return "ADD_FAVORITE";
            case REMOVE_FAVORITE : return "REMOVE_FAVORITE";
            case INVALID_KEY : return "INVALID_KEY";
            default: assert_not_reached();
        }
    }
}

public class ZoneMember {
    public string ip_address {get;set;}
    public string mac_address {get;set;}
}
