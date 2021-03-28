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

public class MainPanel : Gtk.Grid {
    private Soundy.Settings settings;
    private Controller controller;

    private WelcomePanel welcome_panel;

    private Grid title_panel;
    private Grid currently_playing_panel;
    private Gtk.Label currently_playing_track;
    private Gtk.Label currently_playing_artist;
    private LoadableImagePanel image_container;

    private Grid buttons_panel;
    private Gtk.Button play_btn;
    private Gtk.Button pause_btn;
    private Gtk.Button next_btn;
    private Gtk.Button prev_btn;

    public MainPanel(Controller controller, Model model, Soundy.Settings settings) {
        this.settings = settings;
        this.controller = controller;

        model.model_changed.connect((model) => {
            this.update_gui(model);
        });

        this.controller.model = model;

        this.create_gui();
        this.show_all();
    }

    public void create_gui() {
        set_orientation(Orientation.VERTICAL);
        this.set_halign(Gtk.Align.CENTER);
        this.set_valign(Gtk.Align.CENTER);

        this.prev_btn = create_button("media-skip-backward-symbolic", 32);
        this.prev_btn.clicked.connect((event) => {
            this.controller.prev_clicked();
        });
        this.play_btn = create_button("media-playback-start-symbolic", 48);

        play_btn.clicked.connect((event) => {
            this.controller.play_clicked();
        });

        this.pause_btn = create_button("media-playback-pause-symbolic", 48);

        pause_btn.clicked.connect((event) => {
            this.controller.pause_clicked();
        });

        this.next_btn = create_button("media-skip-forward-symbolic", 32);
        this.next_btn.clicked.connect((event) => {
            this.controller.next_clicked();
        });

        title_panel = new Grid();
        title_panel.set_orientation(Orientation.HORIZONTAL);
        title_panel.set_halign(Align.CENTER);

        title_panel.show_all();

        currently_playing_panel = new Gtk.Grid();
        currently_playing_panel.set_orientation(Orientation.HORIZONTAL);
        currently_playing_panel.set_halign(Align.CENTER);

        currently_playing_track = create_label("", Granite.STYLE_CLASS_H1_LABEL);
        currently_playing_artist = create_label("", Granite.STYLE_CLASS_H2_LABEL);

        currently_playing_panel.attach(currently_playing_track, 0, 0);
        currently_playing_panel.attach(currently_playing_artist, 0, 1);
        currently_playing_panel.show_all();

        buttons_panel = new Grid();
        buttons_panel.set_orientation(Orientation.HORIZONTAL);
        buttons_panel.set_halign(Align.CENTER);
        buttons_panel.attach(prev_btn, 0, 0);
        buttons_panel.attach(play_btn, 1, 0);
        buttons_panel.attach(next_btn, 2, 0);

        buttons_panel.show_all();

        welcome_panel = new WelcomePanel();
        welcome_panel.toggle_power.connect((event) => {
            controller.power_on_clicked();
        });

        this.show_all();
    }

    public void update_gui(Model model) {
        message("connection established: " + model.connection_established.to_string());
        message("standby: " + model.is_standby.to_string());
        message("playing: " + model.is_playing.to_string());
        message("radio streaming: " + model.is_radio_streaming.to_string());

        message("track: " + model.track);
        message("artist: " + model.artist);

        message("image_url: " + model.image_url);

        this.remove(currently_playing_panel);
        this.remove(title_panel);
        this.remove(buttons_panel);
        this.remove(welcome_panel);

        if (model.is_standby && !model.is_playing) {
            this.attach(welcome_panel, 0, 0, 1, 2);
        } else {
            this.attach(title_panel, 0, 0);
            this.attach(currently_playing_panel, 0, 1);
            this.attach(buttons_panel, 0, 2);

            if (model.image_url != "") {

                if (image_container != null) {
                    currently_playing_panel.remove(image_container);
                }

                image_container = new LoadableImagePanel(model.image_url, 250, 250);

                if (model.is_buffering_in_progress) {
                    image_container.start_loading_spinner();
                } else {
                    image_container.stop_loading_spinner();
                }

                currently_playing_panel.attach(image_container, 0, 2);
            }

            buttons_panel.remove(play_btn);
            buttons_panel.remove(pause_btn);

            if (model.is_playing) {
                buttons_panel.attach(pause_btn, 1, 0);
            } else {
                buttons_panel.attach(play_btn, 1, 0);
            }

            if (model.is_radio_streaming) {
                buttons_panel.remove(next_btn);
                buttons_panel.remove(prev_btn);
            } else {
                buttons_panel.remove(next_btn);
                buttons_panel.attach(next_btn, 2, 0);

                buttons_panel.remove(prev_btn);
                buttons_panel.attach(prev_btn, 0, 0);
            }

            if (model.track != "") {
                this.currently_playing_track.set_text(model.track);
            }

            if (model.artist != "") {
                this.currently_playing_artist.set_text(model.artist);
            }

            if (!model.connection_established && !model.connection_dialog_tried) {
                model.connection_dialog_tried = true;
                var dialog = new ConnectionDialog(this.settings);
                dialog.run();

                string updated_host = this.settings.get_speaker_host();

                var connection = new Soundy.WebsocketConnection(updated_host, "8080");
                var client = new Soundy.API(connection, updated_host);

                this.controller.update_client(client);
                this.controller.init();
            }

            buttons_panel.show_all();
        }

        this.show_all();
    }

    private Gtk.Button create_button(string icon, int size) {
        var button = new Gtk.Button();

        var menu_icon = new Gtk.Image();
        menu_icon.gicon = new ThemedIcon(icon);
        menu_icon.pixel_size = size;

        button.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        button.image = menu_icon;
        button.can_focus = false;
        return button;
    }

    private Gtk.Label create_label(string text, string style_class) {
        var label = new Gtk.Label(text);
        label.margin_top = 5;
        label.margin_bottom = 5;
        label.get_style_context().add_class(style_class);

        return label;
    }
}
