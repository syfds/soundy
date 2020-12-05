using Gtk;

public class MainPanel : Gtk.Box {


    private Controller controller;

    private Grid title_panel;
    private Gtk.Label soundtouch_name;
    private Gtk.Button power_on_off;

    private Grid currently_playing_panel;
    private Gtk.Label currently_playing_track;

    private Grid buttons;
    private Gtk.Button middle_btn_placeholder;
    private Gtk.Button play_btn;
    private Gtk.Button pause_btn;
    private Gtk.Button next_btn;
    private Gtk.Button prev_btn;

    public MainPanel(Controller controller, Model model) {

        this.controller = controller;

        model.model_changed.connect((model) => {
            this.update_gui(model.is_playing, model.soundtouch_speaker_name, model.track);
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

        this.prev_btn = new Gtk.Button.from_icon_name(
                "media-skip-backward-symbolic",
                Gtk.IconSize.LARGE_TOOLBAR
        );
        prev_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        prev_btn.can_focus = false;

        this.play_btn = new Gtk.Button.from_icon_name(
                "media-playback-start-symbolic",
                Gtk.IconSize.LARGE_TOOLBAR
        );

        play_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        play_btn.can_focus = false;

        play_btn.clicked.connect((event) => {
            this.controller.play_clicked();
        });


        this.pause_btn = new Gtk.Button.from_icon_name(
                "media-playback-pause-symbolic",
                Gtk.IconSize.LARGE_TOOLBAR
        );
        pause_btn.can_focus = false;

        pause_btn.clicked.connect((event) => {
            this.controller.pause_clicked();
        });

        this.next_btn = new Gtk.Button.from_icon_name(
                "media-skip-forward-symbolic",
                Gtk.IconSize.LARGE_TOOLBAR
        );
        next_btn.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        next_btn.can_focus = false;

        title_panel = new Grid();
        title_panel.set_orientation(Orientation.HORIZONTAL);
        title_panel.set_halign(Align.CENTER);

        soundtouch_name = new Gtk.Label("test");
        power_on_off = new Gtk.Button.from_icon_name(
                "system-shutdown-symbolic",
                Gtk.IconSize.LARGE_TOOLBAR
        );
        power_on_off.can_focus = false;
        power_on_off.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        power_on_off.clicked.connect((event) => {
            this.controller.power_on_clicked();
        });


        title_panel.attach(soundtouch_name, 0, 0);
        title_panel.attach(power_on_off, 2, 0);
        title_panel.show_all();


        currently_playing_panel = new Grid();
        currently_playing_panel.set_orientation(Orientation.HORIZONTAL);
        currently_playing_panel.set_halign(Align.CENTER);

        currently_playing_track = new Gtk.Label("no track available");
        currently_playing_panel.attach(currently_playing_track, 0, 0);

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
    }

    public void update_gui(bool is_playing, string speaker_name, string track) {
        message(@"will update the gui: $is_playing, $speaker_name, $track");
        if (is_playing) {
            buttons.remove(play_btn);
            buttons.attach(pause_btn, 1, 0);
        } else {
            buttons.remove(pause_btn);
            buttons.attach(play_btn, 1, 0);
        }

        this.soundtouch_name.set_text(speaker_name);
        this.currently_playing_track.set_text(track);

        buttons.show_all();
        this.show_all();
    }

    private void attach(Gtk.Widget w, int left, int top) {
        this.pack_start(w, false, false, 10);
    }

}
