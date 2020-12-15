using Gtk;

public class SoundyApp : Gtk.Application {


    public const string APP_ID = "com.github.sergejdobryak.soundy";
    public static GLib.Settings settings = new GLib.Settings(APP_ID);


    public SoundyApp() {
        Object(
                application_id: APP_ID,
                flags : ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {

        var main_window = new Gtk.ApplicationWindow(this);
        main_window.resizable = true;
        main_window.default_height = 500;
        main_window.default_width = 500;
        main_window.window_position = WindowPosition.CENTER;




        //        string soundtouch_host = SoundtouchFinder.find("192.168.1.0", "192.168.1.254");

        var speaker_host = settings.get_string("soundtouch-host");
        message(@"trying to connecto to $speaker_host");

        string host = speaker_host;
        var connection = new Connection(host, "8080");

        var client = new SoundtouchClient(connection, host);
        var controller = new Controller(client);
        var header_bar = new HeaderBar(controller);

        main_window.set_titlebar(header_bar);


        Model model = new Model();

        model.model_changed.connect((model) => {
            if (!model.connection_established) {
                header_bar.update_title("No connection possible");
            } else {
                header_bar.update_title(model.soundtouch_speaker_name);
            }
        });

        main_window.add(new MainPanel(controller, model));

        main_window.show_all();
    }

    public static int main(string[] args) {
        var app = new SoundyApp();
        return app.run(args);
    }
}
