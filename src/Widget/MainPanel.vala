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

using Gtk;

public class MainPanel : Gtk.Grid {
    private Soundy.Settings settings;
    private Controller controller;

    private SourcePanel source_panel;
    private WelcomePanel welcome_panel;
    private HelpPanel help_panel;

    private Gtk.Grid title_panel;
    private Gtk.Grid currently_playing_panel;
    private Gtk.Label main_label;
    private Gtk.Label second_label;
    private LoadableImagePanel image_container;

    private Gtk.Grid buttons_panel;
    private Gtk.Button play_btn;
    private Gtk.Button pause_btn;
    private Gtk.Button prev_btn;
    private Gtk.Button next_btn;

    public MainPanel(Controller controller, Model model, Soundy.Settings settings) {
        this.settings = settings;
        this.controller = controller;
        model.model_changed.connect((model) => {
                    this.update_gui(model);
        });

        this.create_gui();
    }

    public void create_gui() {
        set_orientation(Gtk.Orientation.VERTICAL);
        this.set_halign(Gtk.Align.CENTER);
        this.set_valign(Gtk.Align.START);

        margin_top = 15;
        row_spacing = 10;

        this.prev_btn = Soundy.Util.create_button("media-skip-backward-symbolic", 32);
        this.prev_btn.clicked.connect((event) => {
            this.controller.prev_clicked();
        });
        this.play_btn = Soundy.Util.create_button("media-playback-start-symbolic", 48);

        play_btn.clicked.connect((event) => {
            this.controller.play_clicked();
        });

        this.pause_btn = Soundy.Util.create_button("media-playback-pause-symbolic", 48);

        pause_btn.clicked.connect((event) => {
            this.controller.pause_clicked();
        });

        this.next_btn = Soundy.Util.create_button("media-skip-forward-symbolic", 32);
        this.next_btn.clicked.connect((event) => {
            this.controller.next_clicked();
        });

        title_panel = new Gtk.Grid();
        title_panel.set_orientation(Orientation.HORIZONTAL);
        title_panel.set_halign(Align.CENTER);

        main_label = Soundy.Util.create_label_with_max_len("", 20, Granite.STYLE_CLASS_H1_LABEL);
        second_label = Soundy.Util.create_label_with_max_len("", 20, Granite.STYLE_CLASS_H2_LABEL);

        title_panel.attach(main_label, 0, 0);
        title_panel.attach(second_label, 0, 1);
        title_panel.show_all();

        currently_playing_panel = new Gtk.Grid();
        currently_playing_panel.set_orientation(Orientation.HORIZONTAL);
        currently_playing_panel.set_halign(Align.CENTER);


        source_panel = new SourcePanel(this.controller);

        buttons_panel = new Gtk.Grid();
        buttons_panel.set_orientation(Gtk.Orientation.HORIZONTAL);
        buttons_panel.set_halign(Gtk.Align.CENTER);

        buttons_panel.show_all();

        help_panel = new HelpPanel();

        welcome_panel = new WelcomePanel();
        welcome_panel.toggle_power.connect((event) => {
            controller.power_on_clicked();
        });
    }

    public void update_gui(Model model) {
        message("connection established: '" + model.connection_established.to_string() + "'");
        message("standby: '" + model.is_standby.to_string() + "'");
        message("playing: '" + model.is_playing.to_string() + "'");
        message("radio streaming: '" + model.is_radio_streaming.to_string() + "'");
        message("track: '" + model.track + "'");
        message("station name: '" + model.station_name + "'");
        message("item name: '" + model.item_name + "'");
        message("artist: '" + model.artist + "'");
        message("image_url: '" + model.image_url + "'");

        this.remove(title_panel);
        this.remove(currently_playing_panel);
        this.remove(source_panel);
        this.remove(buttons_panel);
        this.remove(welcome_panel);
        this.remove(help_panel);

        if (!model.connection_established) {
            this.attach(help_panel, 0, 0, 1, 2);
        }
        else if (model.is_standby && !model.is_playing) {
            this.attach(welcome_panel, 0, 0, 1, 2);
        } else {
            this.attach(title_panel, 0, 0);
            this.attach(source_panel, 0, 1);
            this.attach(currently_playing_panel, 0, 2);
            this.attach(buttons_panel, 0, 3);

            this.show_container_art(model.image_present, model.image_url, model.is_buffering_in_progress);
            this.prepare_button_panel(model.is_playing, model.is_radio_streaming);

            if (model.track != "") {
                this.main_label.set_text(Soundy.Util.cut_label_if_necessary(model.track, 35));
                this.main_label.set_tooltip_text(model.track);
            }else if (model.station_name != "") {
                this.main_label.set_text(Soundy.Util.cut_label_if_necessary(model.station_name, 35));
                this.main_label.set_tooltip_text(model.station_name);
            }

            var second_label = "";
            if (model.artist != "") {
                second_label = model.artist;
            } else if (model.item_name != ""){
                second_label = model.item_name;
            }

            this.second_label.set_text(Soundy.Util.cut_label_if_necessary(second_label, 45));
            this.second_label.set_tooltip_text(second_label);
        }

        this.show_all();
    }

    private void show_container_art(bool image_present, string image_url, bool is_buffering_in_progress) {

        foreach(Gtk.Widget child in currently_playing_panel.get_children()){
            currently_playing_panel.remove(child);
        }

        if(image_present && image_url != ""){
            image_container = new LoadableImagePanel.from_url(image_url, 250, 250);
        } else {
            image_container = new LoadableImagePanel.from_image(Soundy.Util.create_icon("multimedia-player", 250), 250, 250);
        }
        
        currently_playing_panel.attach(image_container, 0, 2);
        if (is_buffering_in_progress) {
            image_container.start_loading_spinner();
        } else {
            image_container.stop_loading_spinner();
        }
    }

    private void prepare_button_panel(bool is_playing, bool is_radio_streaming) {
        buttons_panel.remove(play_btn);
        buttons_panel.remove(pause_btn);
        buttons_panel.remove(next_btn);
        buttons_panel.remove(prev_btn);

        if (is_playing) {
            buttons_panel.attach(pause_btn, 1, 0);
        } else {
            buttons_panel.attach(play_btn, 1, 0);
        }

        if (!is_radio_streaming) {
            buttons_panel.attach(next_btn, 2, 0);
            buttons_panel.attach(prev_btn, 0, 0);
        }

        buttons_panel.show_all();
    }
}
