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
        var connection = new Connection("192.168.1.100", "8080");
        connection.init_ws();
        var controller = new Controller(new SoundtouchClient(connection));
        main_window.add(new MainPanel(controller));
        main_window.show_all();
    }

    public static int main(string[] args) {
        var app = new MyApp();
        return app.run(args);
    }

}
