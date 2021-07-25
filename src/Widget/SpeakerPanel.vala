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

    private SpeakerModel speaker_model;
    private Gtk.Button toggle_button;
    private Gtk.Revealer speaker_item_revealer;
    private AvahiBrowser browser;
    private Gtk.Box speaker_item_panel;
    private Gtk.Box toggle_button_panel;

    public SpeakerPanel(Controller controller, Model model) {
        orientation = Gtk.Orientation.VERTICAL;
        speaker_item_panel = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        speaker_item_panel.halign = Gtk.Align.CENTER;

        toggle_button_panel = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        toggle_button_panel.halign = Gtk.Align.START;
        toggle_button_panel.valign = Gtk.Align.START;

        speaker_model = new SpeakerModel();

        model.zone_changed.connect(() => {
            Soundy.Util.execute_in_new_thread("", () => {
                var speaker_list = speaker_model.get_all_speaker();

                speaker_list.foreach(s => {
                    this.update_speaker_info(s);
                    return true;
                });

                Idle.add(() => {
                    this.update_top_button_panel(speaker_list);
                    this.update_expanded_button_panel(speaker_list, controller);

                    show_all();
                    return false;
                });
                return null;
            });
        });


        speaker_model.model_changed.connect(() => {
            Idle.add(() => {
                var speaker_list = speaker_model.get_all_speaker();

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
            speaker_model.toggle_view();

        });

        toggle_button_panel.pack_start(toggle_button);

        pack_start(toggle_button_panel);

        speaker_item_revealer = new Gtk.Revealer();
        speaker_item_revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN);
        speaker_item_revealer.show_all();
        speaker_item_revealer.add(speaker_item_panel);

        init_speaker_search();
    }

    public void init_speaker_search() {
        new Thread<void*>("searching speaker", () => {
            browser = new AvahiBrowser();
            browser.on_found_speaker.connect((name, type, domain, hostname, port, txt) => {
                var speaker = new Speaker(name);
                speaker.hostname = hostname;
                this.update_speaker_info(speaker);

                Idle.add(() => {
                    message("new speaker " + name + " added");

                    speaker_model.add_speaker(speaker);
                    return false;
                });
            });
            browser.on_removed_speaker.connect((name) => {
                Idle.add(() => {
                    speaker_model.remove_speaker(name);
                    message("speaker " + name + " removed");
                    return false;
                });
            });
            browser.search();
            return null;
        });
    }

    public void update_top_button_panel(Gee.Set<Speaker> speaker_list) {
        speaker_item_revealer.set_reveal_child(speaker_model.is_view_expanded);
        toggle_button.set_image(Soundy.Util.create_icon(speaker_model.is_view_expanded ? "pane-hide-symbolic" : "pane-show-symbolic", 16));
        toggle_button.tooltip_text = _(speaker_model.is_view_expanded ? _("Hide") : _("List your SoundTouch speaker"));

        foreach (Gtk.Widget child in toggle_button_panel.get_children()){
            if (child is Gtk.Label) {
                toggle_button_panel.remove(child);
            }
        }

        if (!speaker_list.is_empty && !speaker_model.is_view_expanded) {
            toggle_button_panel.add(Soundy.Util.create_label(speaker_list.size.to_string() + _(" SoundTouch speaker available")));
        } else if (speaker_list.is_empty && !speaker_model.is_view_expanded) {
            toggle_button_panel.add(Soundy.Util.create_label(_("Cannot find any SoundTouch speaker")));
        }
    }

    public void update_expanded_button_panel(Gee.Set<Speaker> speaker_list, Controller controller) {


        foreach (Gtk.Widget child in speaker_item_panel.get_children()){
            if (child is SpeakerItemView || child is Gtk.Label) {
                speaker_item_panel.remove(child);
            }
        }

        if (speaker_list.is_empty && speaker_model.is_view_expanded) {
            var no_speaker_label = Soundy.Util.create_label(_("Cannot find any SoundTouch speaker"));
            no_speaker_label.halign = Gtk.Align.CENTER;
            speaker_item_panel.add(no_speaker_label);
        } else if (speaker_model.is_view_expanded) {
            new Thread<void*>("init speaker items", () => {
                Gee.ArrayList<SpeakerItemView> speaker_items = this.build_speaker_items(controller, speaker_list);
                Idle.add(() => {
                    foreach (Gtk.Widget child in speaker_item_panel.get_children()){
                        if (child is SpeakerItemView) {
                            speaker_item_panel.remove(child);
                        }
                    }

                    foreach(var speaker_item in speaker_items){
                        speaker_item_panel.pack_start(speaker_item);
                    }
                    speaker_item_panel.show_all();
                    return false;
                });
                return null;
            });
        }

        if (speaker_model.is_view_expanded) {
            pack_end(speaker_item_revealer);
        } else {
            remove(speaker_item_revealer);
        }
    }

    public void remove_from_zone(Controller controller, SpeakerModel speaker_model, Speaker slave) {
        Gee.Set<Speaker> all_speaker = speaker_model.get_all_speaker();

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

    public Gee.ArrayList<SpeakerItemView> build_speaker_items(Controller controller, Gee.Set<Speaker> speaker_list) {
        Gee.ArrayList<SpeakerItemView> speaker_items = new Gee.ArrayList<SpeakerItemView>();
        return this.create_speaker_items(speaker_list, controller);
    }

    public void add_to_zone(Controller controller, Speaker master, Speaker speaker_to_add) {
        Gee.ArrayList<ZoneMember> zone_member = new Gee.ArrayList<ZoneMember>();
        ZoneMember item = new ZoneMember();
        item.mac_address = speaker_to_add.device_id;
        item.ip_address = speaker_to_add.ip_address;
        zone_member.add(item);

        if (master.is_master && master.is_in_zone) {
            controller.add_to_zone(master.device_id, zone_member);
        } else {
            controller.set_zone(master.device_id, zone_member);
        }
    }

    public Gee.ArrayList<SpeakerItemView> create_speaker_items(Gee.Set<Speaker> speaker_list, Controller controller) {

        Gee.ArrayList<Speaker> available_speaker = new Gee.ArrayList<Speaker>();

        foreach(var speaker in speaker_list){
            if (!speaker.is_in_zone) {
                available_speaker.add(speaker);
            }
        }

        Gee.ArrayList<SpeakerItemView> speaker_items = new Gee.ArrayList<SpeakerItemView>();
        foreach(var speaker in speaker_list){
            var without_current_speaker = available_speaker.filter((s) => {
                return s.hostname != speaker.hostname;
            });

            uint count_connected_slaves = 0;
            if (speaker.is_master) {
                speaker_list.foreach(s => {
                    if (s.hostname != speaker.hostname && s.is_in_zone && s.master_device_id == speaker.device_id) {
                        count_connected_slaves++;
                    }
                    return true;
                });
            }

            var speaker_item = new SpeakerItemView(speaker, without_current_speaker, count_connected_slaves);
            speaker_item.halign = Gtk.Align.CENTER;
            speaker_item.connect_clicked.connect((speaker) => {
                Soundy.Util.execute_in_new_thread("connect to speaker", () => {
                    string updated_host = speaker.hostname;
                    Soundy.Settings.get_instance().set_speaker_host(updated_host);

                    var connection = new Soundy.WebsocketConnection(updated_host, "8080");
                    var client = new Soundy.API(connection, updated_host);
                    controller.update_client(client);
                    controller.init();
                    return null;
                });
            });

            speaker_item.remove_from_zone_clicked.connect((speaker) => {
                Soundy.Util.execute_in_new_thread("remove from zone", () => {
                    this.remove_from_zone(controller, speaker_model, speaker);
                    return null;
                });
            });

            speaker_item.add_to_zone_clicked.connect((master, speaker) => {

                Soundy.Util.execute_in_new_thread("add to zone", () => {
                    this.add_to_zone(controller, master, speaker);
                    return null;
                });
            });

            speaker_items.add(speaker_item);
        }

        return speaker_items;
    }

    private void update_speaker_info(Speaker speaker) {
        Soundy.API api_for_current_speaker = new Soundy.API.from_host(speaker.hostname);
        var speaker_info = new GetInfoMessage.from_rest_api(api_for_current_speaker.get_info());
        var zone_info = new GetZoneMessage.from_rest_api(api_for_current_speaker.get_zone());

        speaker.is_master = zone_info.master_mac_address == speaker_info.device_id;
        speaker.device_id = speaker_info.device_id;
        speaker.ip_address = speaker_info.ip_address;
        speaker.is_in_zone = zone_info.is_in_zone();
        speaker.master_device_id = zone_info.master_mac_address;
    }
}


public class SpeakerItemView: Gtk.Box {
    public signal void connect_clicked(Speaker speaker);
    public signal void remove_from_zone_clicked(Speaker speaker);
    public signal void add_to_zone_clicked(Speaker master, Speaker speaker_to_add);

    public Speaker speaker {get;construct;}

    public SpeakerItemView(Speaker speaker, Gee.Iterator<Speaker> available_speaker, uint count_connected_slaves) {
        Object(
                speaker: speaker
        );

        orientation = Gtk.Orientation.VERTICAL;
        margin_top = 10;
        margin_left = 10;
        margin_bottom = 10;

        var speaker_panel = new Gtk.Grid();
        speaker_panel.orientation = Gtk.Orientation.HORIZONTAL;
        speaker_panel.halign = Gtk.Align.CENTER;
        speaker_panel.valign = Gtk.Align.FILL;

        var speaker_icon = Soundy.Util.create_icon("audio-subwoofer", 48);
        speaker_icon.halign = Gtk.Align.CENTER;
        speaker_icon.valign = Gtk.Align.CENTER;
        speaker_icon.tooltip_text = _("Host " + speaker.hostname);

        pack_start(Soundy.Util.create_label(speaker.speaker_name, "h5"));

        Gtk.Button connect_to_speaker = Soundy.Util.create_button("network-transmit-receive-symbolic", 16);
        connect_to_speaker.halign = Gtk.Align.CENTER;
        connect_to_speaker.tooltip_text = _("Connect");
        connect_to_speaker.clicked.connect(() => {
            connect_clicked(speaker);
        });

        speaker_panel.attach(speaker_icon, 0, 0, 1, 2);
        speaker_panel.attach(connect_to_speaker, 1, 0, 1, 1);


        if (speaker.is_in_zone) {
            if (speaker.is_master) {
                var master_speaker_in_zone = Soundy.Util.create_icon("user-available", 16);
                master_speaker_in_zone.halign = Gtk.Align.CENTER;
                master_speaker_in_zone.valign = Gtk.Align.CENTER;
                speaker_panel.attach(Soundy.Util.create_label("+" + count_connected_slaves.to_string()), 1, 1, 1, 1);
            } else {
                var remove_from_zone_button = Soundy.Util.create_button("list-remove-symbolic", 16);
                remove_from_zone_button.tooltip_text = _("Remove from zone");
                remove_from_zone_button.clicked.connect(() => {
                    remove_from_zone_clicked(speaker);
                });
                speaker_panel.attach(remove_from_zone_button, 1, 1, 1, 1);
            }
        }


        bool should_display_available_speaker = speaker.is_in_zone && speaker.is_master || !speaker.is_in_zone;
        if (should_display_available_speaker && available_speaker.has_next()) {

            var button_list = this.create_button_list(speaker, available_speaker);
            button_list.foreach((button) => {
                pack_end(button, false, false, 5);
                return true;
            });
        }

        pack_end(speaker_panel);
        show_all();
    }

    public Gee.ArrayList<Gtk.Widget> create_button_list(Speaker master, Gee.Iterator<Speaker> available_speaker) {
        var list = new Gee.ArrayList<Gtk.Button>();

        available_speaker.foreach(speaker => {
            var button = new Gtk.Button.with_label("+ " + Soundy.Util.cut_label_if_necessary(speaker.speaker_name, 20));
            button.clicked.connect(() => {
                add_to_zone_clicked(master, speaker);
            });

            return list.add(button);
        });

        return list;
    }
}

public class SpeakerModel : Object {
    public signal void model_changed();
    public Gee.Set<Speaker> speaker_list = new Gee.HashSet<Speaker>((speaker) => speaker.speaker_name.hash(), (speaker1, speaker2) => speaker1.speaker_name == speaker2.speaker_name);
    public bool is_view_expanded {get;set;default=false;}

    public void add_speaker(Speaker speaker) {
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
    public string device_id {get;set;}
    public string ip_address {get;set;}
    public string master_device_id {get;set; default="";}
    public bool is_master {get;set;default=false;}
    public bool is_in_zone {get;set;default=false;}

    public Speaker(string speaker_name) {
        Object(speaker_name: speaker_name);
    }
}
