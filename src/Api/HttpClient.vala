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
using Soup;

namespace Soundy {
    public class HttpClient : GLib.Object {

        private string api_url {get;set;}

        public HttpClient(string host, string port) {
            this.api_url = "http://" + host + ":" + port;
        }

        public string invoke(APIMethod action) {
            Soup.Session session = new Soup.Session();
            session.timeout = 1;
            session.idle_timeout = 1;

            var uri = api_url + action.get_path();

            message("preparing request for " + uri);

            Soup.Message msg = new Soup.Message(action.get_method(), uri);

            if (action.get_body() != null && action.get_body().length > 0) {
                message("with body " + action.get_body());
            }
            if (action.get_body() != null && action.get_body() != "" && action.get_body().length > 0) {
                msg.set_request("text/xml", MemoryUse.COPY, action.get_body().data);
            }

            string response = communicate_with_server(session, msg);

            message("got from SoundTouch API: " + response);

            return response;
        }

        private string communicate_with_server(Session session, Message msg) {
            string response = "";
            MainLoop loop = new MainLoop();
                session.queue_message(msg, (sess, msg) => {
                    response = (string) msg.response_body.data;
                    loop.quit();
                });

            loop.run();
            return response;
        }
    }

    public interface APIMethod: GLib.Object {
        public abstract string get_path();
        public abstract string get_method();
        public abstract string get_body();
    }
}
