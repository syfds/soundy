using Gtk;

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
    public class SoundyApp : Gtk.Application {

        public const string APP_ID = Soundy.Settings.APP_ID;

        public SoundyApp() {
            Object(
                    application_id: APP_ID,
                    flags : ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate() {

            var main_window = new Gtk.ApplicationWindow(this);
            main_window.resizable = true;
            main_window.default_height = 300;
            main_window.default_width = 500;
            main_window.window_position = WindowPosition.CENTER;

            var settings = Soundy.Settings.get_instance();
            var speaker_host = settings.get_speaker_host();

            message(@"trying to connecto to $speaker_host");

            string host = speaker_host;
            var connection = new Soundy.WebsocketConnection(host, "8080");

            var client = new Soundy.API(connection, host);
            var controller = new Controller(client);
            var model = new Model();

            var header_bar = new Soundy.HeaderBar(controller, model);
            main_window.set_titlebar(header_bar);

            main_window.add(new MainPanel(controller, model, settings));

            controller.init();

            main_window.show_all();
        }

        public static int main(string[] args) {
            var app = new SoundyApp();
            return app.run(args);
        }
    }
}
