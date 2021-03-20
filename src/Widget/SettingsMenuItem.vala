public class SettingsMenuItem : Gtk.Button {

    public SettingsMenuItem(string text, string icon_name) {
        halign = Gtk.Align.FILL;

        image = create_icon(icon_name);
        image_position = Gtk.PositionType.LEFT;
        label = text;

        can_focus = false;
        always_show_image = true;

        get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
    }

    public Gtk.Image create_icon(string icon_name) {
        var icon = new Gtk.Image();
        icon.gicon = new ThemedIcon(icon_name);
        icon.pixel_size = 16;
        icon.halign = Gtk.Align.START;
        return icon;
    }
}
