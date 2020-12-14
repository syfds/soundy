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
        main_window.default_height = 500;
        main_window.default_width = 500;
        main_window.window_position = WindowPosition.CENTER;



        this.check_connection();
        string soundtouch_host = SoundtouchFinder.find("192.168.1.0", "192.168.1.254");

        string host = "soundtouch-speaker";
        var connection = new Connection(host, "8080");
        connection.init_ws();

        var controller = new Controller(new SoundtouchClient(connection, host));
        var header_bar = new HeaderBar(controller);

        main_window.set_titlebar(header_bar);


        Model model = new Model();

        model.model_changed.connect((model) => {
            header_bar.update_title(model.soundtouch_speaker_name);
        });

        main_window.add(new MainPanel(controller, model));

        main_window.show_all();
    }

    public static int main(string[] args) {
        var app = new SoundyApp();
        return app.run(args);
    }


    public void check_connection() {
        var settings = new GLib.Settings(APP_ID);
        var speaker_host = settings.get_string("soundtouch-host");
        var client = new SoundtouchClient.from_host(speaker_host);
        var info = client.get_info();
        if (info == null || info.size() == 0) {
            var dialog = new ConnectionDialog();
            dialog.run();
        }
    }
}
