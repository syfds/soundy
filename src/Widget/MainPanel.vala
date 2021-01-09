using Gtk;

public class MainPanel : Gtk.Box {
    private Soundy.Settings settings;
    private Controller controller;

    private Gtk.Spinner loading_spinner;
    private Grid title_panel;
    private Grid currently_playing_panel;
    private Gtk.Label currently_playing_track;
    private Gtk.Label currently_playing_artist;
    private Gtk.Image image;


    private Grid buttons;
    private Gtk.Button middle_btn_placeholder;
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
        set_baseline_position(BaselinePosition.CENTER);


        loading_spinner = new Gtk.Spinner();
        loading_spinner.halign = Gtk.Align.FILL;
        loading_spinner.valign = Gtk.Align.FILL;
        loading_spinner.expand = true;
        loading_spinner.active = true;


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

        currently_playing_track = create_label("no track available", Granite.STYLE_CLASS_H1_LABEL);

        currently_playing_artist = create_label("no artist available", Granite.STYLE_CLASS_H2_LABEL);

        currently_playing_panel.attach(currently_playing_track, 0, 0);
        currently_playing_panel.attach(currently_playing_artist, 0, 1);
        currently_playing_panel.show_all();

        buttons = new Grid();
        buttons.set_orientation(Orientation.HORIZONTAL);
        buttons.set_halign(Align.CENTER);
        buttons.attach(prev_btn, 0, 0);
        buttons.attach(play_btn, 1, 0);
        buttons.attach(next_btn, 2, 0);

        buttons.show_all();

        pack_start(title_panel, false, false);
        pack_start(currently_playing_panel, false, false);
        pack_start(buttons, false, false);
        this.show_all();
    }

    public void update_gui(Model model) {
        message("Update GUI");
        message("connection established : " + model.connection_established.to_string());
        message("is playing: " + model.is_playing.to_string());
        message("track: " + model.track);
        message("artist: " + model.artist);
        message("image_url: " + model.image_url);
        message("is_radio_streaming: " + model.is_radio_streaming.to_string());


        if (model.is_playing) {
            buttons.remove(play_btn);
            buttons.attach(pause_btn, 1, 0);
        } else {
            buttons.remove(pause_btn);
            buttons.attach(play_btn, 1, 0);
        }

        if (model.is_radio_streaming) {
            buttons.remove(next_btn);
            buttons.remove(prev_btn);
        } else {
            buttons.remove(next_btn);
            buttons.attach(next_btn, 2, 0);

            buttons.remove(prev_btn);
            buttons.attach(prev_btn, 0, 0);
        }

        if (model.track != "") {
            this.currently_playing_track.set_text(model.track);
        }

        if (model.artist != "") {
            this.currently_playing_artist.set_text(model.artist);
        }
        if (model.image_url != "") {

            if (image != null) {
                currently_playing_panel.remove(image);
            }


            var image = this.create_image_from_url(model.image_url);

            if (model.is_buffering_in_progress) {
                loading_spinner.start();
                var overlay = new Gtk.Overlay();

                overlay.add_overlay(loading_spinner);

                overlay.add(image);

                currently_playing_panel.attach(overlay, 0, 2);
            } else {
                loading_spinner.stop();
                currently_playing_panel.attach(image, 0, 2);
            }
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

        buttons.show_all();
        this.show_all();
    }

    private void attach(Gtk.Widget w, int left, int top) {
        this.pack_start(w, false, false, 10);
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

    public Gtk.Image create_image_from_url(string image_url) {
        Soup.Message msg = new Soup.Message("GET", image_url);
        Soup.Session session = new Soup.Session();

        var input_stream = session.send(msg);

        image = new Gtk.Image();
        Gdk.Pixbuf image_pixbuf = new Gdk.Pixbuf.from_stream_at_scale(input_stream, 250, 250, true);
        image.set_from_pixbuf(image_pixbuf);
        return image;
    }
}
