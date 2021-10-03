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

public class Model : GLib.Object {

    public signal void model_changed(Model model);
    public signal void header_model_changed(Model model);
    public signal void zone_changed();

    public bool connection_established {get;set;default=false;}
    public bool connection_dialog_tried {get;set;default=false;}

    public uint8 actual_volume {get;set;}
    public uint8 target_volume {get;set;}
    public bool mute_enabled {get;set;default=false;}

    public bool is_radio_streaming {get;set;default=false;}
    public bool is_buffering_in_progress {get;set;default=false;}

    public bool is_standby {get;set;default=false;}
    public bool image_present {get;set;default=true;}
    public string station_name{get;set;}
    public string item_name{get;set;}
    public StreamingSource source{get;set;}

    bool _is_playing = false;
    public bool is_playing {
        get {
            return _is_playing;
        }
        set {
            _is_playing = value;
        }
    }

    string _soundtouch_speaker_name = "";
    public string soundtouch_speaker_name {
        get {
            return _soundtouch_speaker_name;
        }
        set {
            _soundtouch_speaker_name = value;
        }
    }
    string _track = "";
    public string track {
        get {
            return _track;
        }
        set {
            _track = value;
        }
    }
    string _artist = "";
    public string artist {
        get {
            return _artist;
        }
        set {
            _artist = value;
        }
    }
    string _image_url = "";
    public string image_url {
        get {
            return _image_url;
        }
        set {
            _image_url = value;
        }
    }

    public Model() {
    }

    public void fire_changed() {
        Idle.add(() => {
            message("model fire changed");
            this.model_changed(this);
            return Source.REMOVE;
        });
    }
    public void fire_header_model_changed() {
        Idle.add(() => {
            message("header model fire changed");
            this.header_model_changed(this);
            return Source.REMOVE;
        });
    }
    public void fire_zone_changed() {
        Idle.add(() => {
            this.zone_changed();
            return Source.REMOVE;
        });
    }
}
