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

    private Soundy.API client;

    public Model model {get; set;}

    public Controller(Soundy.API client) {
        this.update_client(client);
    }

    private void update_speaker_name() {
        string response = this.client.get_info();
        var info_message = new GetInfoMessage.from_rest_api(response);

        this.model.soundtouch_speaker_name = info_message.speaker_name;
        this.model.fire_changed();
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
            this.model.is_buffering_in_progress = m.play_state == PlayState.BUFFERING_STATE;
            this.model.track = m.track;
            this.model.artist = m.artist;
            this.model.image_url = m.image_url;
            this.model.is_radio_streaming = m.is_radio_streaming;
        }
        this.model.fire_changed();
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

    public void play_preset(string item_id) {
        this.client.play_preset(item_id);
    }

    public async void init() {
        this.client.init_ws_connection();
    }

    public void update_client(Soundy.API client) {
        this.client = client;
        this.client.event_from_soundtouch_received.connect((type, xml) => {
            message("got: " + xml);
            var m = new SoundtouchMessageParser().read(xml);
            if (m is NowPlayingChangeMessage) {
                NowPlayingChangeMessage nowPlaying = (NowPlayingChangeMessage)m;

                this.model.is_standby = nowPlaying.standby;
                this.model.is_playing = nowPlaying.play_state == PlayState.PLAY_STATE;
                this.model.is_buffering_in_progress = nowPlaying.play_state == PlayState.BUFFERING_STATE;
                this.model.track = nowPlaying.track;
                this.model.artist = nowPlaying.artist;
                this.model.image_url = nowPlaying.image_url;
                this.model.is_radio_streaming = nowPlaying.is_radio_streaming;
                this.model.fire_changed();
            } else if (m is VolumeUpdatedMessage) {
                this.model.is_standby = false;
                this.model.actual_volume = ((VolumeUpdatedMessage)m).actual_volume;
                this.model.target_volume = ((VolumeUpdatedMessage)m).target_volume;
                this.model.mute_enabled = ((VolumeUpdatedMessage)m).mute_enabled;
                this.model.fire_changed();
            } else if (m is NowSelectionChangeMessage) {
                this.model.is_standby = false;
                this.model.is_buffering_in_progress = true;
                this.model.track = ((NowSelectionChangeMessage)m).track;
                this.model.image_url = ((NowSelectionChangeMessage)m).image_url;
                this.model.fire_changed();
            }

        });

        this.client.connection_to_soundtouch_succeeded.connect(() => {
            this.model.connection_established = true;
            this.update_speaker_name();
            this.update_currently_playing_track();
            this.update_actual_volume();
        });
        this.client.connection_to_soundtouch_failed.connect(() => {
            this.model.connection_established = false;
            this.model.fire_changed();
        });
    }

    public void update_volume(uint8 actual_volume) {
        this.client.update_volume(actual_volume);
    }

    private void update_actual_volume() {
        var response = this.client.get_volume();
        var volume_message = new VolumeUpdatedMessage.from_rest_api(response);
        this.model.actual_volume = volume_message.actual_volume;
        this.model.target_volume = volume_message.target_volume;
        this.model.fire_changed();
    }

    public double get_volume() {
        var response = this.client.get_volume();
        var volume_message = new VolumeUpdatedMessage.from_rest_api(response);
        return volume_message.actual_volume;
    }
}
