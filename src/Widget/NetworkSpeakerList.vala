public class NetworkSpeakerList : Gtk.Box {
    public signal void on_speaker_changed(string hostname);

    public NetworkSpeakerList() {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 5;

        var network_speaker_label = new Gtk.Label("Network speaker");
        network_speaker_label.get_style_context().add_class(Granite.STYLE_CLASS_H4_LABEL);
        network_speaker_label.halign = Gtk.Align.START;

        pack_start(network_speaker_label);
        pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
        //        pack_end(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
    }

    public void add_speaker(string speaker_name, string hostname) {
        NetworkSpeakerRow new_row = new NetworkSpeakerRow(speaker_name, hostname);
        new_row.clicked.connect((hostname) => {
            this.on_speaker_changed(hostname);
        });

        add(new_row);
    }
}

public class NetworkSpeakerRow : Gtk.Box {

    public signal void clicked(string hostname);

    private Gtk.Label speaker_name_label;
    private Gtk.Button connect_button;

    public NetworkSpeakerRow(string speaker_name, string hostname) {
        this.init_gui(speaker_name, hostname);
    }

    public void init_gui(string speaker_name, string hostname) {
        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 10;

        speaker_name_label = new Gtk.Label(speaker_name);
        connect_button = new Gtk.Button.with_label("Connect");
        connect_button.clicked.connect(() => {
            clicked(hostname);
        });
        connect_button.halign = Gtk.Align.END;
        connect_button.valign = Gtk.Align.CENTER;

        add(speaker_name_label);
        add(new Gtk.Label(hostname));
        pack_end(connect_button);
    }
}
