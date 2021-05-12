namespace Soundy {
    public class Util {
        public static Gtk.Label create_label(string text, string style_class=Granite.STYLE_CLASS_H4_LABEL) {
            var label = new Gtk.Label(text);
            label.get_style_context().add_class(style_class);
            return label;
        }

        public static Gtk.Button create_button(string icon, int size=Gtk.IconSize.BUTTON) {
            var button = new Gtk.Button();

            var menu_icon = new Gtk.Image();
            menu_icon.gicon = new ThemedIcon(icon);
            menu_icon.pixel_size = size;

            button.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
            button.image = menu_icon;
            button.can_focus = false;
            return button;
        }

        public static Gtk.Image create_icon(string icon, int size=Gtk.IconSize.BUTTON) {
            var menu_icon = new Gtk.Image();
            menu_icon.gicon = new ThemedIcon(icon);
            menu_icon.pixel_size = size;
            return menu_icon;
        }
    }
}
