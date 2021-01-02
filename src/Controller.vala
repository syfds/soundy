public class Controller : GLib.Object {

    private SoundtouchClient client;

    public Model model {get; set;}

    public Controller(SoundtouchClient client) {
        this.update_client(client);
    }

    public void update_speaker_name() {
        string name = this.client.get_info();
        this.model.soundtouch_speaker_name = name;
        this.model.fire_changed();
    }

    public void power_on_clicked() {
        this.client.power_on_clicked();
        this.model.is_playing = true;
    }
    public void play_clicked() {
        this.client.play_clicked();
    }

    public void pause_clicked() {
        this.client.pause_clicked();
    }

    public void update_currently_playing_track() {
        var xml = this.client.get_now_playing();
        var m = new NowPlayingChangeMessage.from_rest_api(xml);

        message("NOW_PLAYING " + xml);

        if (m.standby) {
            this.model.is_playing = false;
        } else {
            this.model.is_playing = m.play_state == PlayState.PLAY_STATE;
            this.model.track = m.track;
            this.model.artist = m.artist;
            this.model.image_url = m.image_url;
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
        message("get presets");
        string xml = this.client.get_presets();
        return new PresetsMessage(xml);
    }

    public void play_preset(string item_id) {
        this.client.play_preset(item_id);
    }

    public async void init() {
        this.client.init_ws_connection();
    }

    public void update_client(SoundtouchClient client) {
        this.client = client;
        this.client.event_from_soundtouch_received.connect((type, xml) => {
            var m = new SoundtouchMessageParser().read(xml);
            message("received message parsed!");
            if (m is NowPlayingChangeMessage) {
                NowPlayingChangeMessage nowPlaying = (NowPlayingChangeMessage)m;

                this.model.is_playing = nowPlaying.play_state == PlayState.PLAY_STATE;
                this.model.track = nowPlaying.track;
                this.model.artist = nowPlaying.artist;
                this.model.image_url = nowPlaying.image_url;
                this.model.fire_changed();
            } else if (m is VolumeUpdatedMessage) {
                this.model.actual_volume = ((VolumeUpdatedMessage)m).actual_volume;
                this.model.target_volume = ((VolumeUpdatedMessage)m).target_volume;
                this.model.mute_enabled = ((VolumeUpdatedMessage)m).mute_enabled;
                this.model.fire_changed();
            }

        });

        this.client.connection_to_soundtouch_succeeded.connect(() => {
            this.model.connection_established = true;
            this.update_speaker_name();
            this.update_currently_playing_track();
        });
        this.client.connection_to_soundtouch_failed.connect(() => {
            this.model.connection_established = false;
            this.model.fire_changed();
        });
    }

    public void update_volume(uint8 double) {
        this.client.update_volume(double);
    }
}
