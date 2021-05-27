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
    private Gtk.Box toggle_button_panel;

    public SpeakerPanel(Controller controller, Model m) {
        orientation = Gtk.Orientation.VERTICAL;
        speaker_item_panel = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        speaker_item_panel.halign = Gtk.Align.CENTER;

        toggle_button_panel = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        toggle_button_panel.halign = Gtk.Align.START;

        model = new SpeakerModel();

        m.zone_changed.connect(() => {
            var speaker_list = model.get_all_speaker();

            this.update_top_button_panel(speaker_list);
            this.update_expanded_button_panel(speaker_list, controller);
        });


        model.model_changed.connect(() => {
            Idle.add(() => {
                var speaker_list = model.get_all_speaker();

                this.update_top_button_panel(speaker_list);
                this.update_expanded_button_panel(speaker_list, controller);

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

        toggle_button_panel.pack_start(toggle_button);

        pack_start(toggle_button_panel);
        pack_end(speaker_item_panel);

        init_speaker_search();
    }

    private void play_all(Controller controller, SpeakerModel model) {
        Gee.Set<Speaker> all_speaker = model.get_all_speaker();

        string master_device_mac_address = "";
        Gee.ArrayList<ZoneMember> zone_member = new Gee.ArrayList<ZoneMember>();
        foreach(var speaker in all_speaker){
            var api = new Soundy.API.from_host(speaker.hostname);
            var info_xml = api.get_info();
            GetInfoMessage parsed = new SoundtouchMessageParser().read_info(info_xml);

            if (master_device_mac_address == "") {
                master_device_mac_address = parsed.mac_address;
            } else {
                ZoneMember item = new ZoneMember();
                item.mac_address = parsed.mac_address;
                item.ip_address = parsed.ip_address;
                zone_member.add(item);
            }
        }

        controller.set_zone(master_device_mac_address, zone_member);
    }

    private void set_zone_with_master(Controller controller, SpeakerModel model, Speaker master) {
        Gee.Set<Speaker> all_speaker = model.get_all_speaker();

        string master_device_mac_address = "";
        Gee.ArrayList<ZoneMember> zone_member = new Gee.ArrayList<ZoneMember>();
        foreach(var speaker in all_speaker){

            var api = new Soundy.API.from_host(speaker.hostname);
            var info_xml = api.get_info();
            GetInfoMessage parsed = new SoundtouchMessageParser().read_info(info_xml);

            if (master_device_mac_address == "" && master.hostname == speaker.hostname) {
                master_device_mac_address = parsed.mac_address;
            } else {
                ZoneMember item = new ZoneMember();
                item.mac_address = parsed.mac_address;
                item.ip_address = parsed.ip_address;
                zone_member.add(item);
            }
        }

        controller.set_zone(master_device_mac_address, zone_member);
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

    public void update_top_button_panel(Gee.Set<Speaker> speaker_list) {
        toggle_button.set_image(Soundy.Util.create_icon(model.is_view_expanded ? "view-restore-symbolic" : "view-fullscreen-symbolic", 16));
        toggle_button.tooltip_text = _(model.is_view_expanded ? _("Hide") : _("List your SoundTouch speaker"));

        foreach (Gtk.Widget child in toggle_button_panel.get_children()){
            if (child is Gtk.Label) {
                toggle_button_panel.remove(child);
            }
        }

        if (!speaker_list.is_empty && !model.is_view_expanded) {
            toggle_button_panel.add(Soundy.Util.create_label(speaker_list.size.to_string() + _(" SoundTouch speaker available")));
        } else if (speaker_list.is_empty && !model.is_view_expanded) {
            toggle_button_panel.add(Soundy.Util.create_label(_("Cannot find any SoundTouch speaker")));
        }
    }

    public void update_expanded_button_panel(Gee.Set<Speaker> speaker_list, Controller controller) {
        foreach (Gtk.Widget child in speaker_item_panel.get_children()){
            if (child is SpeakerItemView || child is Gtk.Separator || child is Gtk.Label) {
                speaker_item_panel.remove(child);
            }
        }
        if (speaker_list.is_empty && model.is_view_expanded) {
            var no_speaker_label = Soundy.Util.create_label(_("Cannot find any SoundTouch speaker"));
            no_speaker_label.halign = Gtk.Align.CENTER;
            speaker_item_panel.add(no_speaker_label);
        } else if (model.is_view_expanded) {
            Gee.ArrayList<SpeakerItemView> speaker_items = new Gee.ArrayList<SpeakerItemView>();
            foreach (var speaker in speaker_list) {
                Soundy.API api_for_current_speaker = new Soundy.API.from_host(speaker.hostname);
                var now_playing = new NowPlayingChangeMessage.from_rest_api(api_for_current_speaker.get_now_playing());
                var zone_info = new GetZoneMessage.from_rest_api(api_for_current_speaker.get_zone());

                var speaker_item = new SpeakerItemView(speaker, zone_info.master_mac_address == now_playing.device_id, zone_info.is_in_zone());
                speaker_item.halign = Gtk.Align.CENTER;
                speaker_item.connect_clicked.connect((speaker) => {
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
                speaker_item.create_zone_clicked.connect((speaker) => {
                    this.set_zone_with_master(controller, model, speaker);
                });

                speaker_item.remove_from_zone_clicked.connect((speaker) => {
                    this.remove_from_zone(controller, model, speaker);
                });

                speaker_items.add(speaker_item);

            }



            foreach(var speaker_item in speaker_items){
                speaker_item_panel.pack_start(speaker_item);
            }
        }

        speaker_item_panel.show_all();
    }

    public void remove_from_zone(Controller controller, SpeakerModel model, Speaker slave) {
        Gee.Set<Speaker> all_speaker = model.get_all_speaker();

        string master_device_mac_address = "";

        Gee.ArrayList<ZoneMember> zone_member = new Gee.ArrayList<ZoneMember>();
        foreach(var speaker in all_speaker){

            var api = new Soundy.API.from_host(speaker.hostname);
            var info_xml = api.get_info();
            GetInfoMessage speaker_info = new SoundtouchMessageParser().read_info(info_xml);

            var zone_info = new GetZoneMessage.from_rest_api(api.get_zone());

            if (speaker_info.device_id == zone_info.master_mac_address) {
                master_device_mac_address = zone_info.master_mac_address;
            }


            if (slave.hostname == speaker.hostname) {
                ZoneMember item = new ZoneMember();
                item.mac_address = speaker_info.mac_address;
                item.ip_address = speaker_info.ip_address;
                zone_member.add(item);
            }
        }

        controller.remove_from_zone(master_device_mac_address, zone_member);
    }
}


public class SpeakerItemView: Gtk.Box {
    public signal void connect_clicked(Speaker speaker);
    public signal void create_zone_clicked(Speaker speaker);
    public signal void remove_from_zone_clicked(Speaker speaker);

    public Speaker speaker {get;construct;}

    public SpeakerItemView(Speaker speaker, bool is_master_zone, bool is_in_zone) {
        Object(
                speaker: speaker
        );

        orientation = Gtk.Orientation.VERTICAL;
        margin_top = 10;
        margin_bottom = 10;

        var speaker_panel = new Gtk.Grid();
        speaker_panel.orientation = Gtk.Orientation.HORIZONTAL;


        var speaker_icon = Soundy.Util.create_icon("audio-subwoofer", 48);
        speaker_icon.halign = Gtk.Align.CENTER;
        speaker_icon.valign = Gtk.Align.CENTER;
        speaker_icon.tooltip_text = _("Host " + speaker.hostname);


        pack_start(Soundy.Util.create_label(speaker.speaker_name, "h5"));

        Gtk.Button connect_to_speaker = Soundy.Util.create_button("network-transmit-receive-symbolic", 16);
        connect_to_speaker.tooltip_text = _("Connect");
        connect_to_speaker.clicked.connect(() => {
            connect_clicked(speaker);
        });

        speaker_panel.attach(speaker_icon, 0, 0, 1, 2);
        speaker_panel.attach(connect_to_speaker, 1, 0, 1, 1);

        var plus_lbl = Soundy.Util.create_label("+1");
        plus_lbl.halign = Gtk.Align.CENTER;
        plus_lbl.valign = Gtk.Align.CENTER;

        if (is_in_zone) {
            if (is_master_zone) {
                speaker_panel.attach(plus_lbl, 1, 1, 1, 1);
            } else {
                var remove_from_zone_button = Soundy.Util.create_button("list-remove-symbolic", 16);
                remove_from_zone_button.tooltip_text = _("Remove from zone");
                remove_from_zone_button.clicked.connect(() => {
                    remove_from_zone_clicked(speaker);
                });
                speaker_panel.attach(remove_from_zone_button, 1, 1, 1, 1);

            }
        } else {
            var create_zone_button = Soundy.Util.create_button("network-workgroup-symbolic", 16);
            create_zone_button.tooltip_text = _("Create zone");
            create_zone_button.clicked.connect(() => {
                create_zone_clicked(speaker);
            });

            speaker_panel.attach(create_zone_button, 1, 1, 1, 1);
        }

        pack_end(speaker_panel);
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
