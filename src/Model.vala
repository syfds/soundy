public class Model : GLib.Object {

    public signal void model_changed(bool is_playing, string speaker_name);


    bool _is_playing;
    public bool is_playing {
        get {
            return _is_playing;
        }
        set {
            _is_playing = value;
            model_changed(value, soundtouch_speaker_name);
        }
    }

    string _soundtouch_speaker_name;
    public string soundtouch_speaker_name {
        get {
            return _soundtouch_speaker_name;
        }
        set {
            _soundtouch_speaker_name = value;
            model_changed(is_playing, value);
        }
    }

}
