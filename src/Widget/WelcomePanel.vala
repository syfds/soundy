public class WelcomePanel : Gtk.Grid {

    private Gtk.Label title;
    private Gtk.Label sub_title;
    private Gtk.Button power_button;


    public WelcomePanel() {

        this.set_orientation(Gtk.Orientation.VERTICAL);
        this.set_halign(Gtk.Align.CENTER);
        this.set_valign(Gtk.Align.CENTER);

        title = new Gtk.Label("Welcome to Soundy");


        sub_title = new Gtk.Label("Enjoy your soundtouch speaker");

        power_button = create_button("system-shutdown-symbolic", 32);
        power_button.clicked.connect(() => {
            toggle_power();
        });

        attach(title, 0, 0);
        attach(sub_title, 0, 1);
        attach(power_button, 0, 2);
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

    //    construct {
//        append("applications-system-symbolic", "Power ON!", "Activates your connected soundtouch speaker");
//
//        activated.connect((i) => {
//            if (i == 0) {
//                this.toggle_power();
//            }
//        });
//
//        set_opacity(0);
//
//
//    }

    public signal void toggle_power();

}
