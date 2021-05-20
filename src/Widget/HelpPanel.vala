public class HelpPanel: Gtk.Grid {

    public HelpPanel() {
        this.set_orientation(Gtk.Orientation.VERTICAL);
        this.set_halign(Gtk.Align.CENTER);
        this.set_valign(Gtk.Align.FILL);
        this.margin_top = 200;
        this.margin_bottom = 250;
        this.margin_left = 15;
        this.margin_right = 15;

        var help_button = new Gtk.Button.from_icon_name("dialog-question");
        help_button.halign = Gtk.Align.START;
        help_button.valign = Gtk.Align.CENTER;
        help_button.has_focus = false;
        help_button.can_focus = false;
        help_button.tooltip_text = _("Do you need help?");
        help_button.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);


        help_button.clicked.connect((event) => {
            AppInfo.launch_default_for_uri("https://github.com/syfds/soundy#how-to", null);
        });

        var warning_icon = new Gtk.Image.from_icon_name("dialog-warning", Gtk.IconSize.DIALOG);
        warning_icon.halign = Gtk.Align.CENTER;

        this.attach(warning_icon, 0, 0, 3, 1);
        this.attach(Soundy.Util.create_label(_("You can try to set the correct IP address in ")), 0, 1);
        this.attach(new Gtk.Image.from_icon_name("preferences-system-symbolic", Gtk.IconSize.MENU), 1, 1);
        this.attach(Soundy.Util.create_label(_(" or seek for help here ")), 2, 1);
        this.attach(help_button, 3, 1);
    }
}
