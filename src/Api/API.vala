using Xml;
using Soup;

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

        public void power_on_clicked() {
            send_key_action_to_speaker(KeyAction.POWER, false);
        }

        public void play_clicked() {
            send_key_action_to_speaker(KeyAction.PLAY, false);
        }

        public void pause_clicked() {
            send_key_action_to_speaker(KeyAction.PAUSE, false);
        }

        public void next_clicked() {
            send_key_action_to_speaker(KeyAction.NEXT_TRACK, false);
        }

        public void prev_clicked() {
            send_key_action_to_speaker(KeyAction.PREV_TRACK, false);
        }

        public string get_volume() {
            var response = this.client.invoke(new GetVolume());
            return response;
        }

        public void update_volume(uint8 actual_volume) {
            try {
                Soup.Session session = new Soup.Session();

                string uri = "http://" + host + ":8090/volume";
                Soup.Message msg = new Soup.Message("POST", uri);
                msg.set_request("text/xml", MemoryUse.COPY,
                        @"<volume>$actual_volume</volume>".data);

                string response_json = communicate_with_server(session, msg);

                message(response_json);
            } catch (GLib.Error error) {
                message("error occured at sending to server " + error.message);
                assert_not_reached();
            }
        }


        public string get_info() {
            string response = this.client.invoke(new GetMethod("/info"));

            Xml.Doc* doc = Xml.Parser.parse_doc(response);
            Xml.XPath.Context cntx = new Xml.XPath.Context(doc);
            Xml.XPath.Object* res = cntx.eval_expression("/info/name");

            string speaker_name = res->nodesetval->item(0)->get_content();
            message("resolved speaker name " + speaker_name);
            return speaker_name;
        }

        public string get_now_playing() {
            var response = this.client.invoke(new GetNowPlaying());
            return response;
        }

        private void send_key_action_to_speaker_with_release(KeyAction action) {
            this.send_key_action_to_speaker(action, true);
        }

        private void send_key_action_to_speaker(KeyAction action, bool with_release) {
            try {
                Soup.Session session = new Soup.Session();

                string uri = "http://" + host + ":8090/key";
                Soup.Message msg = new Soup.Message("POST", uri);

                string response;
                if (with_release) {
                    msg.set_request("text/xml", MemoryUse.COPY,
                            generate_key_message(action, KeyState.RELEASE).data);

                    response = communicate_with_server(session, msg);
                } else {
                    msg.set_request("text/xml", MemoryUse.COPY,
                            generate_key_message(action, KeyState.PRESS).data);

                    response = communicate_with_server(session, msg);

                }

                message(response);

            } catch (GLib.Error error) {
                message("error occured at sending to server " + error.message);
                assert_not_reached();
            }
        }
        private string generate_key_message(KeyAction action, KeyState state) {
            string action_as_string = action.to_string();
            string state_as_string = state.to_string();
            return @"<key state=\"$state_as_string\" sender=\"Gabbo\">$action_as_string</key>";
        }

        private string communicate_with_server(Session session, Message msg) {
            string response_json = "";
            MainLoop loop = new MainLoop();
            TimeoutSource timeout = new TimeoutSource(100);
            timeout.set_callback(() => {
                session.queue_message(msg, (sess, msg) => {
                    response_json = (string) msg.response_body.data;
                    loop.quit();
                });

                return false;
            });

            timeout.attach(loop.get_context());
            loop.run();

            return response_json;
        }

        private enum KeyState {
            RELEASE, PRESS;

            public string to_string() {
                switch (this){
                    case PRESS : return "press";
                    case RELEASE : return "release";
                    default: assert_not_reached();
                }
            }
        }

        private enum KeyAction {
            PLAY,
            PAUSE,
            STOP,
            PREV_TRACK,
            NEXT_TRACK,
            THUMBS_UP,
            THUMBS_DOWN,
            BOOKMARK,
            POWER,
            MUTE,
            VOLUME_UP,
            VOLUME_DOWN,
            PRESET_1,
            PRESET_2,
            PRESET_3,
            PRESET_4,
            PRESET_5,
            PRESET_6,
            AUX_INPUT,
            SHUFFLE_OFF,
            SHUFFLE_ON,
            REPEAT_OFF,
            REPEAT_ONE,
            REPEAT_ALL,
            PLAY_PAUSE,
            ADD_FAVORITE,
            REMOVE_FAVORITE,
            INVALID_KEY;

            public string to_string() {
                switch (this){
                    case PLAY : return "PLAY";
                    case PAUSE : return "PAUSE";
                    case STOP : return "STOP";
                    case PREV_TRACK : return "PREV_TRACK";
                    case NEXT_TRACK : return "NEXT_TRACK";
                    case THUMBS_UP : return "THUMBS_UP";
                    case THUMBS_DOWN : return "THUMBS_DOWN";
                    case BOOKMARK : return "BOOKMARK";
                    case POWER : return "POWER";
                    case MUTE : return "MUTE";
                    case VOLUME_UP : return "VOLUME_UP";
                    case VOLUME_DOWN : return "VOLUME_DOWN";
                    case PRESET_1 : return "PRESET_1";
                    case PRESET_2 : return "PRESET_2";
                    case PRESET_3 : return "PRESET_3";
                    case PRESET_4 : return "PRESET_4";
                    case PRESET_5 : return "PRESET_5";
                    case PRESET_6 : return "PRESET_6";
                    case AUX_INPUT : return "AUX_INPUT";
                    case SHUFFLE_OFF : return "SHUFFLE_OFF";
                    case SHUFFLE_ON : return "SHUFFLE_ON";
                    case REPEAT_OFF : return "REPEAT_OFF";
                    case REPEAT_ONE : return "REPEAT_ONE";
                    case REPEAT_ALL : return "REPEAT_ALL";
                    case PLAY_PAUSE : return "PLAY_PAUSE";
                    case ADD_FAVORITE : return "ADD_FAVORITE";
                    case REMOVE_FAVORITE : return "REMOVE_FAVORITE";
                    case INVALID_KEY : return "INVALID_KEY";
                    default: assert_not_reached();
                }
            }
        }

        public string get_presets() {
            return this.client.invoke(new GetMethod("/presets"));
        }

        public void play_preset(string item_id) {
            if (item_id == "1") {
                send_key_action_to_speaker_with_release(KeyAction.PRESET_1);
            } else if (item_id == "2") {
                send_key_action_to_speaker_with_release(KeyAction.PRESET_2);
            } else if (item_id == "3") {
                send_key_action_to_speaker_with_release(KeyAction.PRESET_3);
            } else if (item_id == "4") {
                send_key_action_to_speaker_with_release(KeyAction.PRESET_4);
            } else if (item_id == "5") {
                send_key_action_to_speaker_with_release(KeyAction.PRESET_5);
            } else if (item_id == "6") {
                send_key_action_to_speaker_with_release(KeyAction.PRESET_6);
            }
        }

        public void init_ws_connection() {
            this.connection.ws_message.connect((type, mes) => {
                message(@"received $mes");
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


    }
}
