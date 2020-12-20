public class FavouriteMenuItem : Gtk.Button {

    private Controller controller;
    private string image_url;
    private string item_id;

    public FavouriteMenuItem(Preset preset, string image_url, Controller controller) {
        this.set_tooltip_text(preset.item_name);

        this.image_url = image_url;
        this.can_focus = false;
        this.always_show_image = true;

        this.item_id = preset.item_id;
        this.controller = controller;

        this.clicked.connect(() => {
            this.on_click();
        });

        this.load_image_asynchronously();
    }

    private void load_image_asynchronously() {
        new Thread<void>("loading favourite image", () => {
            var image = this.create_image_from_url(this.image_url);
            this.set_image(image);
            this.show_all();
        });

    }

    public Gtk.Image create_image_from_url(string image_url) {
        Soup.Message msg = new Soup.Message("GET", image_url);
        Soup.Session session = new Soup.Session();

        var input_stream = session.send(msg);

        var image = new Gtk.Image();
        Gdk.Pixbuf image_pixbuf = new Gdk.Pixbuf.from_stream_at_scale(input_stream, 60, 60, true);
        image.set_from_pixbuf(image_pixbuf);
        return image;
    }

    public void on_click() {
        this.controller.play_preset(this.item_id);
    }
}
