using Xml;
using Soup;

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

    public class API : GLib.Object {

        private WebsocketConnection connection;

        private string host;
        private HttpClient client;

        public signal void event_from_soundtouch_received(int type, string message);
        public signal void connection_to_soundtouch_established();
        public signal void connection_to_soundtouch_succeeded();
        public signal void connection_to_soundtouch_failed();


        public API.from_host(string host) {
            this.host = host;
            this.client = new HttpClient(host, "8090");
        }

        public API(WebsocketConnection connection, string host) {
            this.connection = connection;
            this.host = host;
            this.client = new HttpClient(host, "8090");
        }

        public void init_ws_connection() {
            this.connection.ws_message.connect((type, mes) => {
                debug(@"received $mes");
                this.event_from_soundtouch_received(type, mes);
            });

            this.connection.connection_succeeded.connect(() => {
                message("connection succeeded");
                this.connection_to_soundtouch_succeeded();
            });

            this.connection.connection_failed.connect(() => {
                message("connection failed");
                this.connection_to_soundtouch_failed();
            });

            this.connection.connection_disengaged.connect(() => {
                message("connection disengaged");
            });

            this.connection.connection_established.connect(() => {
                this.connection_to_soundtouch_established();
            });

            this.connection.init_ws();
        }

        public void power_on_clicked() {
            this.client.invoke(APIMethods.power());
        }

        public void play_clicked() {
            this.client.invoke(APIMethods.play());
        }

        public void pause_clicked() {
            this.client.invoke(APIMethods.pause());
        }

        public void next_clicked() {
            this.client.invoke(APIMethods.next());
        }

        public void prev_clicked() {
            this.client.invoke(APIMethods.previous());
        }

        public string get_volume() {
            return this.client.invoke(APIMethods.get_volume());
        }

        public void update_volume(uint8 actual_volume) {
            this.client.invoke(APIMethods.update_volume(actual_volume));
        }

        public string get_info() {
            return this.client.invoke(APIMethods.get_info());
        }

        public string get_now_playing() {
            return this.client.invoke(APIMethods.get_now_playing());
        }

        public string get_presets() {
            return this.client.invoke(new GetMethod("/presets"));
        }

        public void play_preset(string item_id) {
            this.client.invoke(APIMethods.play_preset(item_id, KeyState.PRESS));
            this.client.invoke(APIMethods.play_preset(item_id, KeyState.RELEASE));
        }
    }
}
