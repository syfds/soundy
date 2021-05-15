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

public class SpeakerPanel : Gtk.Box {

    private SpeakerModel model;
    private Gtk.Button toggle_button;
    private AvahiBrowser browser;
    private Gtk.Box speaker_item_panel;

    public SpeakerPanel(Controller controller) {
        orientation = Gtk.Orientation.VERTICAL;
        speaker_item_panel = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        speaker_item_panel.halign = Gtk.Align.CENTER;
        model = new SpeakerModel();

        model.model_changed.connect(() => {
            Idle.add(() => {

                toggle_button.set_image(Soundy.Util.create_icon(model.is_view_expanded ? "view-restore-symbolic" : "view-fullscreen-symbolic", 16));
                toggle_button.tooltip_text = _(model.is_view_expanded ? _("Hide") : _("List your SoundTouch speaker"));

                foreach (Gtk.Widget child in speaker_item_panel.get_children()){
                    if (child is SpeakerItemView || child is Gtk.Separator || child is Gtk.Label) {
                        speaker_item_panel.remove(child);
                    }
                }

                var speaker_list = model.get_all_speaker();

                if (speaker_list.is_empty && model.is_view_expanded) {
                    var no_speaker_label = Soundy.Util.create_label(_("Cannot find any SoundTouch speaker."));
                    no_speaker_label.halign = Gtk.Align.CENTER;
                    speaker_item_panel.add(no_speaker_label);
                } else if (model.is_view_expanded) {
                    foreach (var speaker in speaker_list) {

                        var speaker_item = new SpeakerItemView(speaker);
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

                        speaker_item_panel.pack_start(speaker_item);
                    }
                }

                speaker_item_panel.show_all();
                show_all();
                return false;
            });
        });


        toggle_button = Soundy.Util.create_button("view-restore-symbolic", 16);
        toggle_button.halign = Gtk.Align.START;
        toggle_button.valign = Gtk.Align.START;
        toggle_button.clicked.connect(() => {
            model.toggle_view();
        });

        pack_start(toggle_button);
        pack_end(speaker_item_panel);

        init_speaker_search();
    }

    public void init_speaker_search() {
        new Thread<void*>("searching speaker", () => {
            browser = new AvahiBrowser();
            browser.on_found_speaker.connect((name, type, domain, hostname, port, txt) => {
                Idle.add(() => {
                    message("new speaker " + name + " added");
                    model.add_speaker(name, hostname);
                    return false;
                });
            });
            browser.on_removed_speaker.connect((name) => {
                Idle.add(() => {
                    model.remove_speaker(name);
                    message("speaker " + name + " removed");
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
    public Gee.Set<Speaker> speaker_list = new Gee.HashSet<Speaker>((speaker) => speaker.speaker_name.hash(), (speaker1, speaker2) => speaker1.speaker_name == speaker2.speaker_name);
    public bool is_view_expanded {get;set;default=false;}

    public void add_speaker(string name, string host) {
        var speaker = new Speaker(name);
        speaker.hostname = host;
        speaker_list.add(speaker);
        model_changed();
    }

    public void remove_speaker(string name) {
        speaker_list.remove(new Speaker(name));
        model_changed();
    }

    public Gee.Set<Speaker> get_all_speaker() {
        return speaker_list;
    }

    public void toggle_view() {
        this.is_view_expanded = !this.is_view_expanded;
        model_changed();
    }
}
public class Speaker : Object {
    public string speaker_name {get;construct;}
    public string hostname {get;set;}

    public Speaker(string speaker_name) {
        Object(speaker_name: speaker_name);
    }
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
        speaker_icon.tooltip_text = _("Host " + speaker.hostname);
        pack_start(Soundy.Util.create_label(speaker.speaker_name, "h5"));
        Gtk.Button select_speaker = Soundy.Util.create_button("network-transmit-receive-symbolic", 16);
        select_speaker.tooltip_text = _("Connect");
        select_speaker.clicked.connect(() => {
            clicked(speaker);
        });
        pack_start(select_speaker);
        pack_end(speaker_icon);
    }
}
