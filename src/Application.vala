using Gtk;

public class SoundyApp : Gtk.Application {

    public const string APP_ID = "com.github.sergejdobryak.soundy";

    public SoundyApp() {
        Object(
                application_id: APP_ID,
                flags : ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {

        var main_window = new Gtk.ApplicationWindow(this);
        main_window.resizable = true;
        main_window.default_height = 300;
        main_window.default_width = 500;
        main_window.window_position = WindowPosition.CENTER;

        var settings = new Soundy.Settings(APP_ID);
        var speaker_host = settings.get_speaker_host();

        message(@"trying to connecto to $speaker_host");

        string host = speaker_host;
        var connection = new Soundy.WebsocketConnection(host, "8080");

        var client = new Soundy.API(connection, host);
        var controller = new Controller(client);
        var model = new Model();

        var header_bar = new Soundy.HeaderBar(controller, model);
        main_window.set_titlebar(header_bar);

        main_window.add(new MainPanel(controller, model, settings));

        controller.init();

        main_window.show_all();
    }

    public static int main(string[] args) {
        var app = new SoundyApp();
        return app.run(args);
    }
}
