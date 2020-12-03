public class Connection {
    public signal void ws_message (int type, string message);
    public signal void connection_established ();
    public signal void connection_failed ();
    public signal void connection_disengaged ();
    public signal void check_connection (bool connected);

    private Soup.WebsocketConnection websocket_connection;
    private string ip_address = "0.0.0.0";
    private string port_number = "8090";
    public bool ws_connected { public get; private set; }

    /**
     * Constructs a new {@code Connection} object
     */
    public Connection (string ip_address, string port_number) {
        this.ip_address = ip_address;
        this.port_number = port_number;
        this.ws_connected = false;
    }

    public void set_connection_address (string ip, string port_number) {
        this.ip_address = ip_address;
        this.port_number = port_number;
    }
    /**
     * Get the websocket connection reference
     * @return {@code Soup.WebsocketConnection}
     */
    public Soup.WebsocketConnection get_web_socket () {
        return websocket_connection;
    }

    /**
     * Attempt reconnection with Mycroft.
     */
    public void init_ws_after_starting_mycroft () {
        int count = 0;
        if (!ws_connected) {
            Timeout.add (200, () => {
                init_ws ();
                if (count++ > 25) {
                    connection_failed ();
                }
                return !(ws_connected || (count > 25));
            });
        }
    }

    /**
     * Attempt connection to check if Mycroft is running.
     */
    public void init_ws_before_starting_mycroft () {
        init_ws ();
        Timeout.add (5000, () => {
            check_connection (ws_connected);
            return false;
        });
    }

    /**
     * Starts a web socket connection with Mycroft asynchronously.
     */
    public void init_ws () {
        if (!ws_connected) {
            MainLoop loop = new MainLoop ();
            var socket_client = new Soup.Session ();
//            socket_client.https_aliases = { "wss" };
            string url = "ws://%s:%s/".printf (ip_address, port_number);
            message(@"connect to $url");
            var message = new Soup.Message ("POST", url);
            socket_client.websocket_connect_async.begin (message, null, new string[]{"gabbo"}, null, (obj, res) => {
                try {
                    websocket_connection = socket_client.websocket_connect_async.end (res);
                    print ("Connected!\n");
                    ws_connected = true;
                    if (websocket_connection != null) {
                        websocket_connection.message.connect ((type, m_message) => {
                            ws_message (type, decode_bytes(m_message, m_message.length));
                        });
                        websocket_connection.closed.connect (() => {
                            print ("Connection closed\n");
                            connection_disengaged ();
                            ws_connected = false;
                        });
                    }
                } catch (Error e) {
                    stderr.printf ("Remote error\n");
                    connection_failed ();
                    loop.quit ();
                }
                loop.quit ();
                connection_established ();
            });
            loop.run ();
        }
    }

    /**
     * Converts a stream of bytes to string.
     * @return {@code string}
     */
    private static string decode_bytes (Bytes byt, int n) {
        Intl.setlocale ();

        /* The reason for the for loop is to remove
         * garbage after the main JSON string.
         * Store contents of the byte array in to
         * another array and stop when the expected
         * array length is reached
         */

        uint8[] chars = new uint8 [n];
        uint8[] capdata = byt.get_data ();
        for (int i = 0; i < n; i++) {
            chars[i] = capdata[i];
        }
        string output = """%s""".printf(@"$((string) chars)\n");

        return output;
    }
}
