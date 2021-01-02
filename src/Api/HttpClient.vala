using Soup;
namespace Soundy {
    public class HttpClient : GLib.Object {

        private string api_url {get;set;}

        public HttpClient(string host, string port) {
            this.api_url = "http://" + host + ":" + port;
        }

        public string invoke(APIMethod action) {
            Soup.Session session = new Soup.Session();

            var uri = api_url + action.get_path();

            message("preparing request for " + uri);

            Soup.Message msg = new Soup.Message(action.get_method(), uri);

            if (action.with_body()) {
                msg.set_request("text/xml", MemoryUse.COPY, action.get_body());
            }

            string response = communicate_with_server(session, msg);

            message("got from soundtouch API: " + response);

            return response;

        }

        private string communicate_with_server(Session session, Message msg) {
            string response = "";
            MainLoop loop = new MainLoop();
            TimeoutSource timeout = new TimeoutSource(100);
            timeout.set_callback(() => {
                session.queue_message(msg, (sess, msg) => {
                    response = (string) msg.response_body.data;
                    loop.quit();
                });

                return false;
            });

            timeout.attach(loop.get_context());
            loop.run();

            return response;
        }
    }

    public interface APIMethod: GLib.Object {
        public abstract string get_path();
        public abstract string get_method();
        public abstract bool with_body();
        public abstract uint8[] get_body();
    }
}
