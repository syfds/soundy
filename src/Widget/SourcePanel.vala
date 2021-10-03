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

public class SourcePanel : Gtk.Box{

    private Controller controller;

    private Gtk.Button source_speaker;
    private Gtk.Button source_bluetooth;
    private Gtk.Button source_aux;

    public SourcePanel(Controller controller){
        orientation = Gtk.Orientation.HORIZONTAL;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.START;

        this.controller = controller;
        
        source_speaker = Soundy.Util.create_button ("audio-subwoofer", 24);
        source_speaker.tooltip_text = _("Select TUNEIN");
        source_speaker.clicked.connect (speaker_clicked);
        
        source_bluetooth = Soundy.Util.create_button ("bluetooth-symbolic", 24);
        source_bluetooth.tooltip_text = _("Select Bluetooth");
        source_bluetooth.clicked.connect (bluetooth_clicked);

        source_aux = new Gtk.Button.with_label ("AUX");
        source_aux.tooltip_text = _("Select AUX");
        source_aux.clicked.connect (aux_clicked);
        source_aux.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        
        pack_start(source_speaker);
        pack_start(source_bluetooth);
        pack_start(source_aux);
    }

    private void speaker_clicked(){
        RecentItem last_heard_source = this.controller.get_recents().get_recents().get(0);
        var type = last_heard_source.item_type;
        if(type == null){
            type = "";
        }
        
        this.controller.select_source(last_heard_source.source, last_heard_source.source_account, type, last_heard_source.location, last_heard_source.item_name);
    }

    private void bluetooth_clicked(){
        this.controller.select_source("BLUETOOTH", "", "", "", "");
    }

    private void aux_clicked(){
        this.controller.select_source("AUX", "AUX", "", "", "");
    }
}