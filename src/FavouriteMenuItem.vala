public class FavouriteMenuItem : Gtk.Button {

    public FavouriteMenuItem(string label, Gtk.Image image) {
        this.set_tooltip_text(label);
        this.can_focus = false;
        this.always_show_image = true;
        this.set_image(image);
    }

    public Gtk.Image create_image_from_url(string image_url) {
        Soup.Message msg = new Soup.Message("GET", image_url);
        Soup.Session session = new Soup.Session();

        var input_stream = session.send(msg);

        var image = new Gtk.Image();
        Gdk.Pixbuf image_pixbuf = new Gdk.Pixbuf.from_stream_at_scale(input_stream, 40, 40, true);
        image.set_from_pixbuf(image_pixbuf);
        return image;
    }
}
