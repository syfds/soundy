public class ConnectionDialog : Gtk.Dialog {
    private GLib.Settings settings;
    private Gtk.Label connection_state_label;


    public ConnectionDialog(GLib.Settings settings) {
        Object(
                border_width: 5,
                deletable: false,
                resizable: false,
                deletable: true
        );

        this.settings = settings;
        this.show_dialog();
    }

    public void show_dialog() {

        var main_panel = new Gtk.Grid();
        main_panel.margin = 10;
        main_panel.column_spacing = 6;

        var host_input = new Gtk.Entry();

        var host = this.settings.get_string("soundtouch-host");

        host_input.set_text(host);

        var username_input = new Gtk.Entry();

        var test_button = new Gtk.Button.with_label("Test");
        test_button.clicked.connect(() => {
            var changed_host = host_input.get_text();

            connection_state_label.set_text("Trying to connect to " + changed_host);

            var connection = new Connection(changed_host, "8080");


            connection.connection_failed.connect(() => {

                message("Connection failed");
                connection_state_label.set_text("Connection failed");
            });

            connection.connection_succeeded.connect(() => {
                message("Connection succeeded!");
                connection_state_label.set_text("Connection succeeded!");
            });

            connection.init_ws();
        });

        var ok_button = new Gtk.Button.with_label("OK");
        ok_button.clicked.connect((event) => {
            var entered_host = host_input.get_text();
            this.settings.set_string("soundtouch-host", entered_host);
            this.destroy();
        });


        connection_state_label = new Gtk.Label("");
        connection_state_label.valign = Gtk.Align.START;

        var host_label = new Gtk.Label("Server:");

        main_panel.attach(host_label, 0, 0);
        main_panel.attach(host_input, 1, 0);
        main_panel.attach(test_button, 2, 0);
        main_panel.attach(connection_state_label, 1, 1, 2, 1);
        main_panel.attach(ok_button, 2, 2);

        get_content_area().add(main_panel);
        show_all();
    }
}
