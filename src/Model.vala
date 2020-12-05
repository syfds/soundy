public class Model : GLib.Object {

    public signal void model_changed(Model model);


    bool _is_playing = false;
    public bool is_playing {
        get {
            return _is_playing;
        }
        set {
            _is_playing = value;
            model_changed(this);
        }
    }

    string _soundtouch_speaker_name = "";
    public string soundtouch_speaker_name {
        get {
            return _soundtouch_speaker_name;
        }
        set {
            _soundtouch_speaker_name = value;
            model_changed(this);
        }
    }
    string _track = "";
    public string track {
        get {
            return _track;
        }
        set {
            _track = value;
            model_changed(this);
        }
    }
    string _artist = "";
    public string artist {
        get {
            return _artist;
        }
        set {
            _artist = value;
            model_changed(this);
        }
    }



}
