namespace Soundy {
    public class Util {
        public static Gtk.Label create_label(string text, string style_class=Granite.STYLE_CLASS_H4_LABEL) {
            var label = new Gtk.Label(text);
            label.get_style_context().add_class(style_class);
            return label;
        }

        public static Gtk.Label create_label_with_max_len(string text, int max_len, string style_class=Granite.STYLE_CLASS_H4_LABEL) {
            var label = new Gtk.Label(Soundy.Util.cut_label_if_necessary(text, max_len));
            label.tooltip_text = text;
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

        public static string cut_label_if_necessary(string? label, uint max_characters) {
            if (label == null) {
                return null;
            }

            if (label.length <= max_characters) {
                return label;
            }

            string suffix = "...";

            return label.substring(0, max_characters - suffix.length) + suffix;
        }
    }
}
