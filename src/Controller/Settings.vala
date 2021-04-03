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

namespace Soundy {
    public class Settings {
        public const string APP_ID = "com.github.syfds.soundy";
        public const string VERSION = "0.1.0";

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
