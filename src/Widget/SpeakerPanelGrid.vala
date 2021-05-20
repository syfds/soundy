public class SpeakerPanelGrid : Gtk.Grid {
    
    construct {
        var toggle_button = new Gtk.Button.from_icon_name ("go-up", Gtk.IconSize.SMALL_TOOLBAR);
        
        var settings = Soundy.Settings.get_instance();
        var speaker_host = settings.get_speaker_host();
        
        string host = speaker_host;
        var connection = new Soundy.WebsocketConnection(host, "8080");
        
        var client = new Soundy.API(connection, host);
        var controller = new Controller(client);
        
        var model = new Model();
        
        var stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN
        };
        stack.add (new SpeakerPanel (controller));
        
        add (stack);
        
        toggle_button.clicked.connect (() => {
            stack.visible_child = new SpeakerPanel(controller);
        });
    }
}
