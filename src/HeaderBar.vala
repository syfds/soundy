public class HeaderBar : Gtk.HeaderBar {

    private Gtk.Label title;
    private Gtk.Button power_on_off;
    private Gtk.MenuButton favourites;
    private Gtk.Button settings;
    private Gtk.Box main_box;

    public HeaderBar(Controller controller, Model model) {
        set_show_close_button(true);
        title = new Gtk.Label("No title");

        model.model_changed.connect(() => {
            if (!model.connection_established) {
                update_title("No connection");
                power_on_off.visible = false;
            } else {
                update_title(model.soundtouch_speaker_name);
                power_on_off.visible = true;
            }
        });

        power_on_off = create_button("system-shutdown-symbolic", 16);
        power_on_off.clicked.connect((event) => {
            controller.power_on_clicked();
        });


        favourites = new Gtk.MenuButton();
        var menu_icon = new Gtk.Image();
        menu_icon.gicon = new ThemedIcon("non-starred-symbolic");
        menu_icon.pixel_size = 16;

        favourites.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        favourites.image = menu_icon;
        favourites.can_focus = false;

        this.create_preset_items(controller);

        settings = create_button("preferences-system-symbolic", 16);

        main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
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

    public void create_preset_items(Controller controller) {

        var menu_grid = new Gtk.Grid();
        menu_grid.margin_top = 6;
        menu_grid.margin_bottom = 6;
        menu_grid.orientation = Gtk.Orientation.VERTICAL;


        PresetsMessage presets = controller.get_presets();
        foreach(Preset p in presets.get_presets()){
            message(p.item_image_url);
            var item = new FavouriteMenuItem(p, p.item_image_url, controller);
            menu_grid.add(item);
        }

        menu_grid.show_all();

        var popover = new Gtk.Popover(null);
        popover.add(menu_grid);
        favourites.popover = popover;
    }
}
