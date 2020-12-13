using Gtk;

public class MyApp : Gtk.Application {

    public MyApp() {
        Object(
                application_id: "com.github.sergejdobryak.soundy",
                flags : ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var main_window = new Gtk.ApplicationWindow(this);
        main_window.resizable = true;
        main_window.default_height = 500;
        main_window.default_width = 500;
        main_window.window_position = WindowPosition.CENTER;


        //        string soundtouch_host = SoundtouchFinder.find("192.168.1.0","192.168.1.254");


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
        var app = new MyApp();
        return app.run(args);
    }

}
