using Xml;
using Soup;

public class SoundtouchClient : GLib.Object {

    private Connection connection;

    private string host;

    public signal void event_from_soundtouch_received(int type, string message);

    public SoundtouchClient(Connection connection, string host) {
        this.connection = connection;
        this.host = host;

        this.connection.ws_message.connect((type, mes) => {
            message(@"received $mes");
            this.event_from_soundtouch_received(type, mes);
        });
    }

    public void power_on_clicked() {

        message("power on clicked");
        if (connection.ws_connected) {
            try {
                Soup.Session session = new Soup.Session();

                string uri = "http://" + host + ":8090/key";
                Soup.Message msg = new Soup.Message("POST", uri);
                msg.set_request("text/xml", MemoryUse.COPY, "<key state=\"press\" sender=\"Gabbo\">POWER</key>".data);

                string response_json = communicate_with_server(session, msg);
                message(response_json);

                msg.set_request("text/xml", MemoryUse.COPY, "<key state=\"release\" sender=\"Gabbo\">POWER</key>".data);

                response_json = communicate_with_server(session, msg);
                message(response_json);

            } catch (GLib.Error error) {
                message("error occured at sending to server " + error.message);
                assert_not_reached();
            }
        }
    }
    public void play_clicked() {

        message("play clicked");
        if (connection.ws_connected) {
            message("connected");


            try {
                Soup.Session session = new Soup.Session();

                string uri = "http://" + host + ":8090/key";
                Soup.Message msg = new Soup.Message("POST", uri);
                msg.set_request("text/xml", MemoryUse.COPY, "<key state=\"press\" sender=\"Gabbo\">PLAY</key>".data);

                string response_json = communicate_with_server(session, msg);
                message(response_json);

                msg.set_request("text/xml", MemoryUse.COPY, "<key state=\"release\" sender=\"Gabbo\">PLAY</key>".data);

                response_json = communicate_with_server(session, msg);
                message(response_json);

            } catch (GLib.Error error) {
                message("error occured at sending to server " + error.message);
                assert_not_reached();
            }
        }
    }

    private string communicate_with_server(Session session, Message msg) {
        string response_json = "";
        MainLoop loop = new MainLoop();
        TimeoutSource timeout = new TimeoutSource(100);
        timeout.set_callback(() => {
            session.queue_message(msg, (sess, msg) => {
                print("Status Code client " + msg.status_code.to_string());
                print("Message length: " + msg.response_body.length.to_string());
                message("Data: " + (string) msg.response_body.data);
                response_json = (string) msg.response_body.data;
                loop.quit();
            });

            return false;
        });

        timeout.attach(loop.get_context());
        loop.run();

        return response_json;
    }

    public void pause_clicked() {
        try {
            Soup.Session session = new Soup.Session();

            string uri = "http://" + host + ":8090/key";
            Soup.Message msg = new Soup.Message("POST", uri);
            msg.set_request("text/xml", MemoryUse.COPY, "<key state=\"press\" sender=\"Gabbo\">PAUSE</key>".data);

            string response_json = communicate_with_server(session, msg);
            message(response_json);

            msg.set_request("text/xml", MemoryUse.COPY, "<key state=\"release\" sender=\"Gabbo\">PAUSE</key>".data);

            response_json = communicate_with_server(session, msg);
            message(response_json);

        } catch (GLib.Error error) {
            message("error occured at sending to server " + error.message);
            assert_not_reached();
        }
    }


    public string get_speaker_name() {
        Soup.Session session = new Soup.Session();

        string uri = "http://" + host + ":8090/info";
        Soup.Message msg = new Soup.Message("GET", uri);

        string response_xml = communicate_with_server(session, msg);

        Xml.Doc* doc = Xml.Parser.parse_doc(response_xml);
        Xml.XPath.Context cntx = new Xml.XPath.Context(doc);
        Xml.XPath.Object* res = cntx.eval_expression("/info/name");

        string speaker_name = res->nodesetval->item(0)->get_content();
        message("resolved speaker name " + speaker_name );
        return speaker_name;
    }

    public string get_currently_playing_track() {
        Soup.Session session = new Soup.Session();

        string uri = "http://" + host + ":8090/now_playing";
        Soup.Message msg = new Soup.Message("GET", uri);

        string response_xml = communicate_with_server(session, msg);

        Xml.Doc* doc = Xml.Parser.parse_doc(response_xml);
        Xml.XPath.Context cntx = new Xml.XPath.Context(doc);
        Xml.XPath.Object* res = cntx.eval_expression("/nowPlaying/track");

        var track = res->nodesetval->item(0)->get_content();
        return track;
    }
}
