public class HeaderBar : Gtk.HeaderBar {

    private Gtk.Label title;
    private Gtk.Button power_on_off;
    private Gtk.Button favourites;
    private Gtk.Button settings;

    public HeaderBar(Controller controller) {
        set_show_close_button(true);
        title = new Gtk.Label("No title");

        power_on_off = create_button("system-shutdown-symbolic", 16);
        power_on_off.clicked.connect((event) => {
            controller.power_on_clicked();
        });

        favourites = create_button("non-starred-symbolic", 16);
        settings = create_button("preferences-system-symbolic", 16);

        var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
        main_box.halign = Gtk.Align.CENTER;

        main_box.pack_start(title);
        main_box.pack_start(power_on_off);

        pack_end(settings);
        pack_end(favourites);

        custom_title = main_box;
    }

    public void update_title(string soundtouch_speaker_name) {
        title.set_text(soundtouch_speaker_name);
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
