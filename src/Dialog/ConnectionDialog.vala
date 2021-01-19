public class ConnectionDialog : Gtk.Dialog {

    private Soundy.Settings settings;

    private Gtk.Label connection_state_label;
    private Gtk.Box connection_state_container;
    private Gtk.Image connection_state_icon;
    private Gtk.Entry host_input;


    public ConnectionDialog(Soundy.Settings settings) {
        Object(
                border_width: 5,
                resizable: false,
                deletable: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );

        this.settings = settings;
        this.show_dialog();
        this.try_connection();
    }

    public void show_dialog() {

        var main_panel = new Gtk.Grid();
        main_panel.margin = 10;
        main_panel.column_spacing = 6;
        main_panel.row_spacing = 6;

        host_input = new Gtk.Entry();

        var host = this.settings.get_speaker_host();
        host_input.set_text(host);
        host_input.changed.connect(() => this.try_connection());

        var test_connection_button = new Gtk.Button.with_label("Test connection");

        test_connection_button.clicked.connect(() => {
            this.try_connection();
        });

        var ok_button = new Gtk.Button.with_label("OK");
        ok_button.has_focus = true;
        ok_button.clicked.connect((event) => {
            var entered_host = host_input.get_text();

            this.settings.set_speaker_host(entered_host);

            this.destroy();
        });


        connection_state_label = new Gtk.Label("");
        connection_state_label.halign = Gtk.Align.START;
        connection_state_label.valign = Gtk.Align.CENTER;

        var host_label = new Gtk.Label("Soundtouch host:");

        main_panel.attach(host_label, 0, 0);
        main_panel.attach(host_input, 1, 0);
        main_panel.attach(test_connection_button, 2, 0);
        main_panel.attach(connection_state_label, 0, 1, 2, 1);
        main_panel.attach(ok_button, 2, 2);

        get_content_area().add(main_panel);
        show_all();
    }

    private void try_connection() {
        var changed_host = host_input.get_text();

        connection_state_label.set_text("Trying to connect to " + changed_host);

        var connection = new Soundy.WebsocketConnection(changed_host, "8080");

        connection.connection_failed.connect(() => {
            message("Connection failed");
            connection_state_label.set_text("Connection failed");
        });

        connection.connection_succeeded.connect(() => {
            message("Connection succeeded!");
            connection_state_label.set_text("Connection succeeded!");
        });

        connection.init_ws();
    }
}
