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

public class Controller : GLib.Object {
    public signal void speaker_panel_toggled(bool show);

    private Soundy.API client;

    public Model model {get; set;}

    public Controller(Model model, Soundy.API api_client) {
        this.model = model;
        this.client = api_client;
    }


    public void toggle_speaker_panel(bool show){
        this.speaker_panel_toggled(show);
    }

    private void update_speaker_name() {
        string response = this.client.get_info();
        var info_message = new GetInfoMessage.from_rest_api(response);

        this.model.soundtouch_speaker_name = info_message.speaker_name;
    }

    public void power_on_clicked() {
        this.client.power_on_clicked();
    }

    public void play_clicked() {
        this.client.play_clicked();
    }

    public void pause_clicked() {
        this.client.pause_clicked();
    }

    private void update_currently_playing_track() {

        var xml = this.client.get_now_playing();
        var m = new NowPlayingChangeMessage.from_rest_api(xml);

        if (m.standby) {
            this.model.is_standby = true;
            this.model.is_playing = false;
        } else {
            this.model.is_standby = false;
            this.model.is_playing = m.play_state == PlayState.PLAY_STATE;
            this.model.is_buffering_in_progress = m.play_state == PlayState.BUFFERING_STATE || m.connection_status == ConnectionStatus.CONNECTING;
            this.model.track = m.track;
            this.model.artist = m.artist;
            this.model.image_url = m.image_url;
            this.model.is_radio_streaming = m.is_radio_streaming;
            this.model.source = m.source;
            this.model.station_name = m.station_name;
            this.model.item_name = m.item_name;
            this.model.image_present = m.image_present;
        }
    }

    public void next_clicked() {
        this.client.next_clicked();
    }

    public void prev_clicked() {
        this.client.prev_clicked();
    }

    public PresetsMessage get_presets() {
        string xml = this.client.get_presets();
        return new PresetsMessage(xml);
    }

    public RecentsMessage get_recents() {
        string xml = this.client.get_recents();
        return new RecentsMessage(xml);
    }

    public void play_preset(string item_id) {
        this.client.play_preset(item_id);
    }

    public void set_zone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        this.client.set_zone(master_device_id_mac_address, zone_member_list);
    }

    public void remove_from_zone(string master_device_id_mac_address, Gee.ArrayList<ZoneMember> zone_member_list) {
        this.client.remove_zone_slave(master_device_id_mac_address, zone_member_list);
    }

    public void init() {
        this.client.event_from_soundtouch_received.connect((type, xml) => {
            message("Event update: " + xml);
            var m = new SoundtouchMessageParser().read(xml);
            if (m is NowPlayingChangeMessage) {
                NowPlayingChangeMessage nowPlaying = (NowPlayingChangeMessage)m;

                this.model.is_standby = nowPlaying.standby;
                this.model.is_playing = nowPlaying.play_state == PlayState.PLAY_STATE;
                this.model.is_buffering_in_progress = nowPlaying.play_state == PlayState.BUFFERING_STATE || nowPlaying.connection_status == ConnectionStatus.CONNECTING;
                this.model.track = nowPlaying.track;
                this.model.artist = nowPlaying.artist;
                this.model.image_url = nowPlaying.image_url;
                this.model.is_radio_streaming = nowPlaying.is_radio_streaming;
                this.model.source = nowPlaying.source;
                this.model.station_name = nowPlaying.station_name;
                this.model.item_name = nowPlaying.item_name;
                this.model.image_present = nowPlaying.image_present;
                this.model.fire_changed();
            } else if (m is VolumeUpdatedMessage) {
                this.model.is_standby = false;
                this.model.actual_volume = ((VolumeUpdatedMessage)m).actual_volume;
                this.model.target_volume = ((VolumeUpdatedMessage)m).target_volume;
                this.model.mute_enabled = ((VolumeUpdatedMessage)m).mute_enabled;
                this.model.fire_header_model_changed();
            } else if (m is NowSelectionChangeMessage) {
                this.model.is_standby = false;
                this.model.is_buffering_in_progress = true;
                this.model.track = ((NowSelectionChangeMessage)m).track;
                this.model.image_url = ((NowSelectionChangeMessage)m).image_url;
                this.model.fire_changed();
            } else if (m is ZoneChangeMessage) {
                this.model.fire_zone_changed();
            }
        });

        this.client.connection_to_soundtouch_succeeded.connect(() => {
            message("controller got connection succeeded");
            this.model.connection_established = true;
            this.update_speaker_name();
            this.update_currently_playing_track();
            this.update_actual_volume();
            this.model.fire_changed();
            this.model.fire_header_model_changed();
        });
        this.client.connection_to_soundtouch_failed.connect(() => {
            this.model.connection_established = false;
            this.model.fire_changed();
            this.model.fire_header_model_changed();
        });

        this.client.init_ws_connection();
    }

    public void update_host(string new_host) {
        this.client.set_host(new_host);
    }

    public void update_volume(uint8 actual_volume) {
        this.client.update_volume(actual_volume);
    }

    private void update_actual_volume() {
        var response = this.client.get_volume();
        var volume_message = new VolumeUpdatedMessage.from_rest_api(response);
        this.model.actual_volume = volume_message.actual_volume;
        this.model.target_volume = volume_message.target_volume;
    }

    public double get_volume() {
        var response = this.client.get_volume();
        var volume_message = new VolumeUpdatedMessage.from_rest_api(response);
        return volume_message.actual_volume;
    }

    public void add_to_zone(string device_id, Gee.ArrayList<ZoneMember> zone_member) {
        this.client.add_to_zone(device_id, zone_member);
    }
    public void select_source(string source, string source_account, string item_type, string location, string item_name) {
        this.client.select_source(source, source_account, item_type, location, item_name);
    }
}
