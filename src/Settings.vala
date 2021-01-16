namespace Soundy {
    public class Settings {
        public const string APP_ID = "com.github.sergejdobryak.soundy";

        private const string HOST_SETTING_NAME = "soundtouch-host";
        private GLib.Settings settings;
        private static Soundy.Settings instance;

        public static Soundy.Settings get_instance() {
            if (instance == null) {
                instance = new Soundy.Settings();
            }

            return instance;
        }

        private Settings() {
            this.settings = new GLib.Settings(APP_ID);
        }

        public string get_speaker_host() {
            return this.settings.get_string(HOST_SETTING_NAME);
        }

        public void set_speaker_host(string new_host) {
            this.settings.set_string(HOST_SETTING_NAME, new_host);
        }
    }
}
