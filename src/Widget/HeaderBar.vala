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
    public class HeaderBar : Gtk.HeaderBar {

        private Soundy.Settings settings;
        private Controller controller;

        private Gtk.Label mytitle;
        private Gtk.Button power_on_off;
        private Gtk.VolumeButton volume_button;
        private Gtk.MenuButton favourites;
        private Gtk.MenuButton settings_button;
        private Gtk.Box main_box;

        public HeaderBar(Controller controller, Model model, Soundy.Settings settings) {
            this.settings = settings;
            this.controller = controller;

            set_show_close_button(true);
            mytitle = new Gtk.Label(_("Cannot connect to your speaker") + " :-/");

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

            favourites = this.create_menu_button("non-starred-symbolic", 16);
            //            volume_button.value = controller.get_volume();

            settings_button = this.create_menu_button("preferences-system-symbolic", 16);
            this.create_settings_items();

            main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
            main_box.halign = Gtk.Align.CENTER;

            main_box.pack_start(mytitle);
            main_box.pack_start(power_on_off);

            pack_end(settings_button);
            pack_end(favourites);
            pack_end(volume_button);

            custom_title = main_box;


            model.header_model_changed.connect((model) => {
                this.update_gui(controller, model);
            });
        }

        public void update_title(string soundtouch_speaker_name) {
            mytitle.set_text(soundtouch_speaker_name);
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

            bool is_not_yet_initialized = favourites.popover == null;
            if (is_not_yet_initialized) {
                var menu_grid = new Gtk.Grid();
                menu_grid.margin_top = 6;
                menu_grid.margin_bottom = 6;
                menu_grid.orientation = Gtk.Orientation.VERTICAL;

                new Thread<void*>("loading presets", () => {
                    PresetsMessage presets = controller.get_presets();
                    message("count presets loaded " + presets.get_presets().size.to_string());

                    Timeout.add(100, () => {
                        foreach(Preset p in presets.get_presets()){
                            message(p.item_image_url);
                            var item = new FavouriteMenuItem(p, p.item_image_url, controller);
                            menu_grid.add(item);
                        }

                        menu_grid.show_all();
                        return false;
                    });
                    return null;
                });

                var popover = new Gtk.Popover(null);
                popover.add(menu_grid);
                favourites.popover = popover;
            }
        }

        public void update_gui(Controller controller, Model model) {
            if (!model.connection_established) {
                power_on_off.sensitive = false;
                volume_button.sensitive = false;

                var popover = new Gtk.Popover(null);
                favourites.popover = popover;
                favourites.sensitive = false;
            } else {
                create_preset_items(controller);
                update_title(model.soundtouch_speaker_name);
                power_on_off.sensitive = true;
                volume_button.sensitive = true;
                favourites.sensitive = true;
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
            menu_grid.halign = Gtk.Align.FILL;

            var about = new SettingsMenuItem(_("About"), "dialog-information-symbolic");
            about.clicked.connect(() => {
                var dialog = new AboutDialog();
                dialog.show_all();
                dialog.present();
            });

            var speaker_host = new SettingsMenuItem(_("Network address"), "network-transmit-receive-symbolic");

            speaker_host.clicked.connect(() => {
                var dialog = new ConnectionDialog(Soundy.Settings.get_instance());
                dialog.run();

                new Thread<void*>(null, () => {
                    string updated_host = this.settings.get_speaker_host();

                    this.controller.update_host(updated_host);
                    return null;
                });
            });

            menu_grid.add(speaker_host);
            menu_grid.add(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
            menu_grid.add(about);
            menu_grid.show_all();

            var popover = new Gtk.Popover(null);
            popover.add(menu_grid);
            settings_button.popover = popover;
        }
    }
}
