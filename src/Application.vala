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
            main_window.default_width = 300;
            main_window.default_height = 500;
            main_window.window_position = WindowPosition.CENTER;
            main_window.get_style_context().add_class(Granite.STYLE_CLASS_ROUNDED);
            
            var settings = Soundy.Settings.get_instance();
            var speaker_host = settings.get_speaker_host();
            
            var granite_settings = Granite.Settings.get_default ();
            var gtk_settings = Gtk.Settings.get_default ();
            
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
            
            granite_settings.notify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme = (
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
                );
            });

            message(@"trying to connecto to $speaker_host");
            
            string host = speaker_host;
            var connection = new Soundy.WebsocketConnection(host, "8080");
            
            var client = new Soundy.API(connection, host);
            var controller = new Controller(client);
            
            var model = new Model();
            
            var header_bar = new Soundy.HeaderBar(controller, model, settings);
            main_window.set_titlebar(header_bar);
            
            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            
            var main_area = new Gtk.Grid();
            main_area.attach(new MainPanel(controller, model, settings), 0, 0, 1, 1/*, true, false)*/);
            main_area.attach (separator, 0, 1, 1, 1);
            main_area.attach(new SpeakerPanelGrid(), 0, 2, 1, 1/*, true, false)*/);
            // main_area.pack2(new SpeakerPanel(controller), false, false);
            
            var main_grid = new Gtk.Grid ();
            main_grid.attach (main_area, 0, 0, 1, 1);
            
            main_window.add(main_grid);
            
            controller.init();
            
            main_window.show_all();
        }

        public static int main(string[] args) {
            var app = new SoundyApp();
            return app.run(args);
        }
    }
}
