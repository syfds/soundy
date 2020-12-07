using Gtk;

public class MainPanel : Gtk.Box {


    private Controller controller;

    private Grid title_panel;
    private Grid currently_playing_panel;
    private Gtk.Label currently_playing_track;
    private Gtk.Label currently_playing_artist;

    private Grid buttons;
    private Gtk.Button middle_btn_placeholder;
    private Gtk.Button play_btn;
    private Gtk.Button pause_btn;
    private Gtk.Button next_btn;
    private Gtk.Button prev_btn;

    public MainPanel(Controller controller, Model model) {

        this.controller = controller;

        model.model_changed.connect((model) => {
            this.update_gui(model);
        });

        this.controller.model = model;

        this.create_gui();
        this.show_all();

        this.controller.update_speaker_name();
        this.controller.update_currently_playing_track();
    }

    public void create_gui() {
        set_orientation(Orientation.VERTICAL);
        set_baseline_position(BaselinePosition.CENTER);

        this.prev_btn = create_button("media-skip-backward-symbolic", 32);
        this.play_btn = create_button("media-playback-start-symbolic", 48);

        play_btn.clicked.connect((event) => {
            this.controller.play_clicked();
        });

        this.pause_btn = create_button("media-playback-pause-symbolic", 48);

        pause_btn.clicked.connect((event) => {
            this.controller.pause_clicked();
        });

        this.next_btn = create_button("media-skip-forward-symbolic", 32);

        title_panel = new Grid();
        title_panel.set_orientation(Orientation.HORIZONTAL);
        title_panel.set_halign(Align.CENTER);

        title_panel.show_all();

        //        string str = "socss me text";
//        string format = "<span style=\"italic\">%s</span>";
//        var markup = Markup.printf_escaped (format, str);

        currently_playing_panel = new Gtk.Grid();
        currently_playing_panel.set_orientation(Orientation.HORIZONTAL);
        currently_playing_panel.set_halign(Align.CENTER);

        currently_playing_track = new Gtk.Label("no track available");
        //        currently_playing_track.set_markup(markup);
        currently_playing_artist = new Gtk.Label("no artist available");

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
        if (model.is_playing) {
            buttons.remove(play_btn);
            buttons.attach(pause_btn, 1, 0);
        } else {
            buttons.remove(pause_btn);
            buttons.attach(play_btn, 1, 0);
        }

        if (model.track != "") {
            this.currently_playing_track.set_text(model.track);
        }

        if (model.artist != "") {
            this.currently_playing_artist.set_text(model.artist);
        }
        if (model.image_url != "") {

            Soup.Message msg = new Soup.Message("GET", model.image_url);
            Soup.Session session = new Soup.Session();

            var input_stream = session.send(msg);

            var image = new Gtk.Image();
            image.set_from_pixbuf(new Gdk.Pixbuf.from_stream(input_stream));
            currently_playing_panel.attach(image, 0, 2);
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

}
