namespace Soundy {
    public class Settings {

        private const string HOST_SETTING_NAME = "soundtouch-host";
        private GLib.Settings settings;

        public Settings(string settings_id) {
            this.settings = new GLib.Settings(settings_id);
        }

        public string get_speaker_host() {
            return this.settings.get_string(HOST_SETTING_NAME);
        }

        public void set_speaker_host(string new_host) {
            this.settings.set_string(HOST_SETTING_NAME, new_host);
        }
    }
}
