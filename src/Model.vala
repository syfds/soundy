public class Model : GLib.Object {

    public signal void model_changed(Model model);

    public bool connection_established {get;set;default=false;}
    public bool connection_dialog_tried {get;set;default=false;}

    public uint8 actual_volume {get;set;}
    public uint8 target_volume {get;set;}
    public bool mute_enabled {get;set;default=false;}

    public bool is_radio_streaming {get;set;default=false;}
    public bool is_buffering_in_progress {get;set;default=false;}

    public bool is_standby {get;set;default=true;}

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

    public void fire_changed() {
        this.model_changed(this);
    }
}
