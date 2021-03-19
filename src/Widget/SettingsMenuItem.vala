public class SettingsMenuItem : Gtk.Button {

    public SettingsMenuItem(string text, string icon_name) {
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        image = create_icon(icon_name);
        label = text;

        can_focus = false;
        always_show_image = true;

        get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);

        clicked.connect(() => {
            var dialog = new ConnectionDialog(Soundy.Settings.get_instance());
            dialog.run();
        });
    }

    public Gtk.Image create_icon(string icon_name) {
        var icon = new Gtk.Image();
        icon.gicon = new ThemedIcon(icon_name);
        icon.pixel_size = 16;
        return icon;
    }

    public Gtk.Button create_button(string label) {
        var speaker_host_button = new Gtk.Button.with_label(label);
        speaker_host_button.can_focus = false;

        speaker_host_button.get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        speaker_host_button.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);

        speaker_host_button.clicked.connect(() => {
            var dialog = new ConnectionDialog(Soundy.Settings.get_instance());
            dialog.run();
        });

        return speaker_host_button;
    }
}
