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
        private string port_number = "8090";
        public bool ws_connected { public get; private set; }

        public WebsocketConnection(string ip_address, string port_number) {
            this.ip_address = ip_address;
            this.port_number = port_number;
            this.ws_connected = false;
        }

        public void set_connection_address(string ip_address, string port_number) {
            this.ip_address = ip_address;
            this.port_number = port_number;
        }
        public Soup.WebsocketConnection get_web_socket() {
            return websocket_connection;
        }

        public void init_ws() {
            if (!ws_connected) {
                MainLoop loop = new MainLoop();
                var socket_client = new Soup.Session();
                string url = "ws://%s:%s/".printf(ip_address, port_number);
                message(@"connect to $url");
                var websocket_message = new Soup.Message("POST", url);
                socket_client.websocket_connect_async.begin(websocket_message, null, new string[]{"gabbo"}, null, (obj, res) => {
                    try {
                        websocket_connection = socket_client.websocket_connect_async.end(res);
                        message("Connected!\n");
                        ws_connected = true;
                        connection_succeeded();
                        if (websocket_connection != null) {
                            websocket_connection.message.connect((type, m_message) => {
                                ws_message(type, decode_bytes(m_message, m_message.length));
                            });
                            websocket_connection.closed.connect(() => {
                                print("Connection closed\n");
                                connection_disengaged();
                                ws_connected = false;
                            });
                        }
                    } catch (Error e) {
                        message("Remote error");
                        connection_failed();
                        loop.quit();
                    }
                    loop.quit();
                    connection_established();
                });
                loop.run();
            }
        }

        private static string decode_bytes(Bytes byt, int n) {
            return (string)byt.get_data();
        }
    }
}
