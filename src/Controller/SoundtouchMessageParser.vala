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

public class SoundtouchMessageParser: GLib.Object {



    public SoundtouchMessage read(string xml) {

        if (xml.contains("nowSelectionUpdated")) {
            return new NowSelectionChangeMessage(xml);
        }
        if (xml.contains("nowPlayingUpdated")) {
            return new NowPlayingChangeMessage.from_websocket(xml);
        }
        if (xml.contains("volumeUpdated")) {
            return new VolumeUpdatedMessage.from_websocket(xml);
        }

        return new SoundtouchMessage();
    }


    public GetInfoMessage read_info(string xml) {
        return new GetInfoMessage.from_rest_api(xml);
    }
}


public class SoundtouchMessage : GLib.Object {

    public string base_xpath {set; get; }

    public SoundtouchMessage.with_base_path(string base_xpath) {
        this.base_xpath = base_xpath;
    }
    public SoundtouchMessage() {
    }

    public Xml.XPath.Context context(string xml) {
        Xml.Doc* doc = Xml.Parser.parse_doc(xml);
        Xml.XPath.Context cntx = new Xml.XPath.Context(doc);
        return cntx;
    }

    public string get_value(Xml.XPath.Context context, string xpath) {
        Xml.XPath.Object* res = context.eval_expression(xpath);
        return res->nodesetval->item(0)->get_content();
    }

    public int get_int_value(Xml.XPath.Context context, string xpath) {
        string value = get_value(context, xpath);
        return int.parse(value);
    }

}
public class VolumeUpdatedMessage : SoundtouchMessage {

    public bool mute_enabled {get;set; default=false;}
    public uint8 target_volume {get;set; }
    public uint8 actual_volume {get;set;}


    public VolumeUpdatedMessage.from_websocket(string xml) {
        this.with_base_path("/updates/volumeUpdated");
        init(xml);
    }

    public VolumeUpdatedMessage.from_rest_api(string xml) {
        this.with_base_path("");
        init(xml);
    }

    public void init(string xml) {
        var ctx = this.context(xml);
        this.read_mute_enabled(ctx);
        this.read_target_volume(ctx);
        this.read_actual_volume(ctx);
    }

    public void read_mute_enabled(Xml.XPath.Context ctx) {
        var mute_enabled_string = get_value(ctx, @"$base_xpath/volume/muteenabled");
        this.mute_enabled = mute_enabled_string == "false" ? false : true;
    }

    public void read_target_volume(Xml.XPath.Context ctx) {
        this.target_volume = (uint8)get_int_value(ctx, @"$base_xpath/volume/targetvolume");
    }

    public void read_actual_volume(Xml.XPath.Context ctx) {
        this.actual_volume = (uint8)get_int_value(ctx, @"$base_xpath/volume/actualvolume");
    }
}

public class GetInfoMessage: SoundtouchMessage {

    public string speaker_name {get; set;}
    public string mac_address {get; set;}
    public string ip_address {get; set;}

    public GetInfoMessage.from_rest_api(string xml) {
        this.with_base_path("");
        init(xml);
    }

    private void init(string xml) {
        var ctx = context(xml);

        speaker_name = get_value(ctx, "/info/name");
        mac_address = get_value(ctx, "/info/networkInfo[1]/macAddress/text()");
        ip_address = get_value(ctx, "/info/networkInfo[1]/ipAddress/text()");
    }
}

public class ZoneChangeMessage: SoundtouchMessage {
    public string mac_address {get; set;}

    public ZoneChangeMessage(string xml) {
        this.with_base_path("");
        init(xml);
    }
    private void init(string xml) {
        var ctx = context(xml);
        this.mac_address = get_value(ctx, "/updates/@deviceID");

    }
}
public class GetZoneMessage: SoundtouchMessage {

    public string master_mac_address {get; set;}
    public bool is_master {get; set;}
    public Gee.ArrayList<ZoneMember> members {get; set;}

    public GetZoneMessage.from_rest_api(string xml) {
        this.with_base_path("");
        init(xml);
    }

    private void init(string xml) {
        var ctx = context(xml);

        this.master_mac_address = get_value(ctx, "/zone/@master");
        this.is_master = get_value(ctx, "/zone/@senderIsMaster") == "true" ? true : false;

        Xml.XPath.Object* result = ctx.eval_expression("count(//member)");
        double count_member = result->floatval;

        this.members = new Gee.ArrayList<ZoneMember>();
        for (var i=0; i < (int) count_member; i++) {
            var member_idx = i + 1;
            var ip_address = get_value(ctx, @"/zone/member[$member_idx]/@ipaddress");
            var mac_address = get_value(ctx, @"/zone/member[$member_idx]");

            var member = new ZoneMember();

            member.ip_address = ip_address;
            member.mac_address = mac_address;
            members.add(member);
        }
    }

    public bool is_in_zone() {
        return !this.members.is_empty;
    }

    public bool master() {
        return this.is_master || !this.members.is_empty && this.master_mac_address == this.members.get(0).mac_address;
    }
}

public class NowSelectionChangeMessage : SoundtouchMessage {
    public string track {get;set; default="";}
    public string image_url {get;set; default="";}

    public NowSelectionChangeMessage(string xml) {
        this.with_base_path("/updates/nowSelectionUpdated");
        this.init(xml);
    }

    public void init(string xml) {
        var ctx = context(xml);

        this.read_image_url(ctx);
        this.read_track(ctx);
    }

    public void read_image_url(Xml.XPath.Context ctx) {
        image_url = get_value(ctx, @"$base_xpath/preset/ContentItem/containerArt");
    }

    public void read_track(Xml.XPath.Context ctx) {
        track = get_value(ctx, @"$base_xpath/preset/ContentItem/itemName");
    }
}

public class NowPlayingChangeMessage : SoundtouchMessage {
    public PlayState play_state {get;set;}
    public bool standby {get;set; default=false;}
    public bool is_radio_streaming {get;set; default=false;}
    public string track {get;set; default="";}
    public string artist {get;set; default="";}
    public string image_url {get;set; default="";}

    public NowPlayingChangeMessage.from_rest_api(string xml) {
        this.with_base_path("");
        init(xml);
    }

    public NowPlayingChangeMessage.from_websocket(string xml) {
        this.with_base_path("/updates/nowPlayingUpdated");
        init(xml);
    }

    private void init(string xml) {
        var ctx = context(xml);

        if (xml.contains("STANDBY")) {
            this.standby = true;
        } else {
            this.read_play_state(ctx);
            this.read_track(ctx);
            this.read_artist(ctx);
            this.read_image_url(ctx);
            this.read_radio_streaming(ctx);
        }
    }

    private void read_play_state(Xml.XPath.Context ctx) {
        string value = get_value(ctx, @"$base_xpath/nowPlaying/playStatus");

        if (value == "PAUSE_STATE" || value == "STOP_STATE") {
            play_state = PlayState.STOP_STATE;
        } else if (value == "BUFFERING_STATE") {
            play_state = PlayState.BUFFERING_STATE;
        } else {
            play_state = PlayState.PLAY_STATE;
        }

    }

    public void read_track(Xml.XPath.Context ctx) {
        track = get_value(ctx, @"$base_xpath/nowPlaying/track");
    }

    public void read_artist(Xml.XPath.Context ctx) {
        artist = get_value(ctx, @"$base_xpath/nowPlaying/artist");
    }

    public void read_image_url(Xml.XPath.Context ctx) {
        image_url = get_value(ctx, @"$base_xpath/nowPlaying/art");
    }

    public void read_radio_streaming(Xml.XPath.Context ctx) {
        string stream_type  = get_value(ctx, @"$base_xpath/nowPlaying/streamType");
        if (stream_type == "RADIO_STREAMING") {
            is_radio_streaming = true;
        } else {
            is_radio_streaming = false;
        }
    }
}

public enum PlayState {
    STOP_STATE,
    BUFFERING_STATE,
    PLAY_STATE
}

public enum NotificationType {
    NOW_PLAYING_CHANGE
}

public class PresetsMessage : SoundtouchMessage {

    private Gee.ArrayList<Preset> presets = new Gee.ArrayList<Preset>();

    public PresetsMessage(string xml) {
        base();
        var ctx = context(xml);
        Xml.XPath.Object* result = ctx.eval_expression("count(//preset)");
        double count_preset = result->floatval;

        for (var i=0; i < (int) count_preset; i++) {
            var preset_id = i + 1;
            var item_id = get_value(ctx, @"/presets/preset[@id='$preset_id']/@id");
            var item_name = get_value(ctx, @"/presets/preset[@id='$preset_id']/ContentItem/itemName");
            var item_image_url = get_value(ctx, @"/presets/preset[@id='$preset_id']/ContentItem/containerArt");
            var preset = new Preset();

            preset.item_id = item_id;
            preset.item_name = item_name;
            preset.item_image_url = item_image_url;
            presets.add(preset);
        }
    }

    public Gee.ArrayList<Preset> get_presets() {
        return this.presets;
    }
}

public class Preset : GLib.Object {
    public string item_id {get;set;}
    public string item_name {get;set;}
    public string item_image_url {get;set;}
}
