public class APIMethods : GLib.Object {
    public static Soundy.APIMethod play(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.PLAY, state);
    }

    public static Soundy.APIMethod power(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.POWER, state);
    }

    public static Soundy.APIMethod pause(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.PAUSE, KeyState.PRESS);
    }

    public static Soundy.APIMethod next(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.NEXT_TRACK, KeyState.PRESS);
    }

    public static Soundy.APIMethod previous(KeyState state = KeyState.PRESS) {
        return new KeyMethod(KeyAction.PREV_TRACK, KeyState.PRESS);
    }

    public static Soundy.APIMethod update_volume(uint8 actual_volume) {
        return new UpdateVolume(actual_volume);
    }

    public static Soundy.APIMethod get_now_playing() {
        return new GetNowPlaying();
    }
}

internal class GetMethod : Soundy.APIMethod, GLib.Object {
    private string path {set; get;}

    public GetMethod(string path) {
        this.path = path;
    }

    public override string get_method() {return "GET";}
    public override string get_body() {return ""; }
    public override string get_path() {return path;}
}

internal class GetVolume : GetMethod {
    public GetVolume() {
        base("/volume");
    }
}

internal class UpdateVolume : Soundy.APIMethod, GLib.Object {
    public uint8 actual_volume {set construct; get;}

    public UpdateVolume(uint8 actual_volume) {
        this.actual_volume = actual_volume;
    }

    public override string get_path() {return "/volume";}
    public override string get_method() {return "POST";}
    public override string get_body() {
        return @"<volume>$actual_volume</volume>";
    }
}

internal class GetNowPlaying : GetMethod {
    public GetNowPlaying() {
        base("/now_playing");
    }
}

internal class KeyMethod : Soundy.APIMethod, GLib.Object {
    public KeyAction action {set construct; get;}
    public KeyState state {set construct; get;}

    internal KeyMethod(KeyAction action, KeyState state) {
        this.action = action;
        this.state = state;
    }
    public override string get_path() {return "/key";}
    public override string get_method() {return "POST";}
    public string get_body() {
        string action_as_string = action.to_string();
        string state_as_string = state.to_string();
        return @"<key state=\"$state_as_string\" sender=\"Gabbo\">$action_as_string</key>";
    }
}

public enum KeyState {
    RELEASE, PRESS;

    public string to_string() {
        switch (this){
            case PRESS : return "press";
            case RELEASE : return "release";
            default: assert_not_reached();
        }
    }
}

private enum KeyAction {
    PLAY,
    PAUSE,
    STOP,
    PREV_TRACK,
    NEXT_TRACK,
    THUMBS_UP,
    THUMBS_DOWN,
    BOOKMARK,
    POWER,
    MUTE,
    VOLUME_UP,
    VOLUME_DOWN,
    PRESET_1,
    PRESET_2,
    PRESET_3,
    PRESET_4,
    PRESET_5,
    PRESET_6,
    AUX_INPUT,
    SHUFFLE_OFF,
    SHUFFLE_ON,
    REPEAT_OFF,
    REPEAT_ONE,
    REPEAT_ALL,
    PLAY_PAUSE,
    ADD_FAVORITE,
    REMOVE_FAVORITE,
    INVALID_KEY;

    public string to_string() {
        switch (this){
            case PLAY : return "PLAY";
            case PAUSE : return "PAUSE";
            case STOP : return "STOP";
            case PREV_TRACK : return "PREV_TRACK";
            case NEXT_TRACK : return "NEXT_TRACK";
            case THUMBS_UP : return "THUMBS_UP";
            case THUMBS_DOWN : return "THUMBS_DOWN";
            case BOOKMARK : return "BOOKMARK";
            case POWER : return "POWER";
            case MUTE : return "MUTE";
            case VOLUME_UP : return "VOLUME_UP";
            case VOLUME_DOWN : return "VOLUME_DOWN";
            case PRESET_1 : return "PRESET_1";
            case PRESET_2 : return "PRESET_2";
            case PRESET_3 : return "PRESET_3";
            case PRESET_4 : return "PRESET_4";
            case PRESET_5 : return "PRESET_5";
            case PRESET_6 : return "PRESET_6";
            case AUX_INPUT : return "AUX_INPUT";
            case SHUFFLE_OFF : return "SHUFFLE_OFF";
            case SHUFFLE_ON : return "SHUFFLE_ON";
            case REPEAT_OFF : return "REPEAT_OFF";
            case REPEAT_ONE : return "REPEAT_ONE";
            case REPEAT_ALL : return "REPEAT_ALL";
            case PLAY_PAUSE : return "PLAY_PAUSE";
            case ADD_FAVORITE : return "ADD_FAVORITE";
            case REMOVE_FAVORITE : return "REMOVE_FAVORITE";
            case INVALID_KEY : return "INVALID_KEY";
            default: assert_not_reached();
        }
    }
}
