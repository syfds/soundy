public class SpeakerPanel : Gtk.Box {

    private SpeakerModel model;
    private Gtk.Button toggle_button;
    private AvahiBrowser browser;

    public SpeakerPanel(Controller controller) {
        spacing = 10;

        model = new SpeakerModel();
        model.model_changed.connect(() => {
            Idle.add(() => {

                toggle_button.set_image(Soundy.Util.create_icon(model.is_view_expanded ? "view-restore-symbolic" : "view-fullscreen-symbolic", 16));

                foreach (Gtk.Widget child in get_children()){
                    if (child is SpeakerItemView || child is Gtk.Separator) {
                        remove(child);
                    }
                }

                var speaker_list = model.get_all_speaker();

                if (speaker_list.is_empty) {
                    add(Soundy.Util.create_label(_("Cannot find any SoundTouch speaker")));
                } else if (model.is_view_expanded) {
                    for (var i=0;i < speaker_list.size; i++) {

                        var speaker_item = new SpeakerItemView(speaker_list[i]);
                        speaker_item.halign = Gtk.Align.CENTER;
                        speaker_item.clicked.connect((speaker) => {
                            new Thread<void*>(null, () => {
                                string updated_host = speaker.hostname;
                                Soundy.Settings.get_instance().set_speaker_host(updated_host);

                                var connection = new Soundy.WebsocketConnection(updated_host, "8080");
                                var client = new Soundy.API(connection, updated_host);
                                controller.update_client(client);
                                controller.init();
                                return null;
                            });
                        });

                        pack_start(speaker_item);
                        if (i != speaker_list.size - 1) {
                            pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL), false, true);
                        }
                    }
                }

                show_all();
                return false;
            });
        });


        toggle_button = Soundy.Util.create_button("view-restore-symbolic", 48);
        toggle_button.halign = Gtk.Align.START;
        toggle_button.valign = Gtk.Align.START;
        toggle_button.clicked.connect(() => {
            model.toggle_view();
        });
        pack_start(toggle_button);

        init_speaker_search();
    }

    public void init_speaker_search() {
        new Thread<void*>("searching speaker", () => {
            browser = new AvahiBrowser();
            browser.on_found_speaker.connect((name, type, domain, hostname, port, txt) => {
                Idle.add(() => {
                    model.add_speaker(name, hostname);
                    message("new speaker " + name + " added");
                    return false;
                });
            });
            browser.search();
            return null;
        });
    }
}

public class SpeakerModel : Object {
    public signal void model_changed();
    public Gee.ArrayList<Speaker> speaker_list = new Gee.ArrayList<Speaker>();
    public bool is_view_expanded {get;set;default=false;}

    public void add_speaker(string name, string host) {
        var speaker = new Speaker();
        speaker.speaker_name = name;
        speaker.hostname = host;
        speaker_list.add(speaker);
        model_changed();
    }

    public Gee.ArrayList<Speaker> get_all_speaker() {
        return speaker_list;
    }

    public void toggle_view() {
        this.is_view_expanded = !this.is_view_expanded;
        model_changed();
    }
}
public class Speaker : Object {
    public string speaker_name {get;set;}
    public string hostname {get;set;}
}

public class SpeakerItemView: Gtk.Box {
    public signal void clicked(Speaker speaker);

    public Speaker speaker {get;construct;}

    public SpeakerItemView(Speaker speaker) {
        Object(
                speaker: speaker
        );

        orientation = Gtk.Orientation.VERTICAL;
        margin_top = 10;
        margin_bottom = 10;

        var speaker_icon = Soundy.Util.create_icon("audio-subwoofer", 48);
        speaker_icon.halign = Gtk.Align.CENTER;
        speaker_icon.valign = Gtk.Align.CENTER;
        pack_start(Soundy.Util.create_label(speaker.speaker_name, "h5"));
        Gtk.Button select_speaker = Soundy.Util.create_button("network-transmit-receive-symbolic", 16);

        select_speaker.clicked.connect(() => {
            clicked(speaker);
        });
        pack_start(select_speaker);
        pack_end(speaker_icon);
    }
}
