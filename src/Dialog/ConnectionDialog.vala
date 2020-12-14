public class ConnectionDialog : Gtk.Dialog {
    public ConnectionDialog() {
        this.show_dialog();
    }



    public void show_dialog() {
        var main_panel = new Gtk.Grid();
        main_panel.margin = 10;
        main_panel.column_spacing = 6;

        var host_input = new Gtk.Entry();
        host_input.set_text("192.168.0.1");

        var username_input = new Gtk.Entry();

        var ok_button = new Gtk.Button.with_label("OK");
        ok_button.clicked.connect((event) => {

            this.destroy();
        });


        var username_label = new Gtk.Label("Username:");
        var host_label = new Gtk.Label("Server:");

        main_panel.attach(host_label, 0, 0);
        main_panel.attach(host_input, 1, 0);
        main_panel.attach(ok_button, 2, 1);

        get_content_area().add(main_panel);
        show_all();
    }
}
