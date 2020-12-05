public class Controller : GLib.Object {


    private SoundtouchClient client;


    public Model model {get; set;}


    public Controller(SoundtouchClient client) {
        this.client = client;
        this.client.event_from_soundtouch_received.connect((type, xml) => {
            var m = new SoundtouchMessageParser().read(xml);
            if (m is NowPlayingChangeMessage) {
                NowPlayingChangeMessage nowPlaying = (NowPlayingChangeMessage)m;
                if (nowPlaying.play_state == PlayState.PLAY_STATE) {
                    message("playing!!!");
                    this.model.is_playing = true;
                } else {
                    message("paused!!!");
                    this.model.is_playing = false;
                }

                this.model.track = nowPlaying.track;
                this.model.artist = nowPlaying.artist;
            }

        });
    }

    public void update_speaker_name() {
        string name = this.client.get_speaker_name();
        this.model.soundtouch_speaker_name = name;

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
        if (this.model.is_playing) {
            var xml = this.client.get_currently_playing_track();
            var message = new NowPlayingChangeMessage.from_rest_api(xml);

            this.model.track = message.track;
            this.model.artist = message.artist;
        }
    }
}
