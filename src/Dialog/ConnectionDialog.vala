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

public class ConnectionDialog : Gtk.Dialog {

    private Soundy.Settings settings;

    private Gtk.Label connection_state_label;
    private Gtk.Box connection_state_container;
    private Gtk.Image connection_state_icon;
    private Gtk.Entry host_input;
    private Gtk.Image status_icon;
    private Gtk.Button help_button;
    private Gtk.Button ok_button;

    public ConnectionDialog(Soundy.Settings settings) {
        Object(
                border_width: 5,
                resizable: false,
                deletable: true,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );

        this.set_destroy_with_parent(true);
        this.set_modal(true);
        response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                this.hide_on_delete();
            }
        });

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

        help_button = new Gtk.Button.from_icon_name("dialog-question");
        help_button.has_focus = true;
        help_button.halign = Gtk.Align.END;
        help_button.clicked.connect((event) => {
            AppInfo.launch_default_for_uri("https://github.com/syfds/soundy#how-to", null);
        });

        ok_button = new Gtk.Button.with_label("OK");
        ok_button.has_focus = true;
        ok_button.clicked.connect((event) => {
            var entered_host = host_input.get_text();

            this.settings.set_speaker_host(entered_host);

            this.destroy();
        });


        status_icon = new Gtk.Image();
        status_icon.gicon = new ThemedIcon("process-completed-symbolic");
        status_icon.pixel_size = 16;
        status_icon.halign = Gtk.Align.END;

        connection_state_label = new Gtk.Label("");
        connection_state_label.halign = Gtk.Align.START;
        connection_state_label.valign = Gtk.Align.CENTER;

        var host_label = new Gtk.Label("Soundtouch host:");

        main_panel.attach(host_label, 0, 0);
        main_panel.attach(host_input, 1, 0);
        main_panel.attach(test_connection_button, 2, 0);
        main_panel.attach(status_icon, 0, 1);
        main_panel.attach(connection_state_label, 1, 1, 2, 1);
        main_panel.attach(help_button, 1, 2);
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
            status_icon.gicon = new ThemedIcon("dialog-warning");
            connection_state_label.set_text(_("Connection failed"));
            ok_button.set_sensitive(false);
        });

        connection.connection_succeeded.connect(() => {
            message("Connection succeeded!");
            status_icon.gicon = new ThemedIcon("process-completed-symbolic");
            connection_state_label.set_text(_("Connection succeeded!"));
            ok_button.set_sensitive(true);
        });

        connection.init_ws();
    }
}
