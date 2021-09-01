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
    public class WebsocketConnection {
        public signal void ws_message(int type, string message);
        public signal void connection_succeeded();
        public signal void connection_established();
        public signal void connection_failed();
        public signal void connection_disengaged();
        public signal void check_connection(bool connected);

        private Soup.WebsocketConnection websocket_connection;
        private string ip_address;
        private string port_number;
        public bool ws_connected { public get; private set; }
        private Soup.Session socket_client;

        public WebsocketConnection(string ip_address, string port_number = "8080") {
            this.ip_address = ip_address;
            this.port_number = port_number;
            this.ws_connected = false;

            socket_client = new Soup.Session();
            socket_client.timeout = 1;
        }

        public async void init_ws() {
            string url = "ws://%s:%s/".printf(ip_address, port_number);
            message(@"connect to $url");
            var websocket_message = new Soup.Message("GET", url);

            try {
                websocket_connection = yield socket_client.websocket_connect_async(websocket_message, null, new string[]{"gabbo"},
                        null);

                websocket_connection.message.connect((type, m_message) => {
                    ws_message(type, decode_bytes(m_message, m_message.length));
                });

                connection_succeeded();
            } catch (Error e) {
                warning("cannot connect: " + e.message);
                connection_failed();
            }
        }

        private static string decode_bytes(Bytes byt, int n) {
            return (string)byt.get_data();
        }

        public void set_host(string new_host) {
            this.ip_address = new_host;
            if (this.websocket_connection != null && this.websocket_connection.get_state() == Soup.WebsocketState.OPEN) {
                message("closing open websocket connection...");
                this.websocket_connection.close(1, "closed manually");
                message("websocket connection closed");
            }

            this.init_ws.begin();
        }
    }
}
