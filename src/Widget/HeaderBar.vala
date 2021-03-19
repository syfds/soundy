namespace Soundy {
    public class HeaderBar : Gtk.HeaderBar {

        private Gtk.Label title;
        private Gtk.Button power_on_off;
        private Gtk.VolumeButton volume_button;
        private Gtk.MenuButton favourites;
        private Gtk.MenuButton settings;
        private Gtk.Box main_box;

        public HeaderBar(Controller controller, Model model) {
            set_show_close_button(true);
            title = new Gtk.Label(_("No title"));

            model.model_changed.connect((model) => {
                this.update_gui(model);
            });

            power_on_off = create_button("system-shutdown-symbolic", 16);
            power_on_off.clicked.connect((event) => {
                controller.power_on_clicked();
            });

            volume_button = new Gtk.VolumeButton();

            volume_button.use_symbolic = true;
            volume_button.adjustment = new Gtk.Adjustment(0.0, 0.0, 100.0, 2.0, 2.0, 2.0);
            volume_button.value_changed.connect((value) => {
                message("updates volume to " + value.to_string());
                controller.update_volume((uint8)(value));
            });

            volume_button.value = controller.get_volume();

            favourites = this.create_menu_button("non-starred-symbolic", 16);
            this.create_preset_items(controller);

            settings = this.create_menu_button("preferences-system-symbolic", 16);
            this.create_settings_items();

            main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
            main_box.halign = Gtk.Align.CENTER;

            main_box.pack_start(title);
            main_box.pack_start(power_on_off);

            pack_end(settings);
            pack_end(favourites);
            pack_end(volume_button);

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

        public void update_gui(Model model) {
            if (!model.connection_established) {
                update_title(_("No connection"));
                power_on_off.visible = false;
            } else {
                update_title(model.soundtouch_speaker_name);
                power_on_off.visible = true;
            }


            if (model.mute_enabled) {
                message("mute");
                this.volume_button.set_value(0);
            } else {
                message("current volume set " + model.actual_volume.to_string());
            }
        }


        public Gtk.MenuButton create_menu_button(string icon_name, int pixel_size) {
            var menu_button = new Gtk.MenuButton();
            var menu_icon = new Gtk.Image();
            menu_icon.gicon = new ThemedIcon(icon_name);
            menu_icon.pixel_size = pixel_size;

            menu_button.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
            menu_button.image = menu_icon;
            menu_button.can_focus = false;
            return menu_button;
        }


        public void create_settings_items() {
            var menu_grid = new Gtk.Grid();
            menu_grid.margin_top = 6;
            menu_grid.margin_bottom = 6;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;

            menu_grid.add(new SettingsMenuItem(_("speaker host"), "network-transmit-receive-symbolic"));
            menu_grid.show_all();

            var popover = new Gtk.Popover(null);
            popover.add(menu_grid);
            settings.popover = popover;
        }
    }
}
