public class LoadableImage : Gtk.DrawingArea {

    private Gdk.Pixbuf image_pixel;
    private double alpha;

    public LoadableImage.from(Gdk.Pixbuf image_pixel, int width, int height, double alpha) {
        this.image_pixel = image_pixel;
        this.alpha = alpha;

        this.set_size_request(width, height);
    }

    public override bool draw(Cairo.Context context) {
        var surface = Gdk.cairo_surface_create_from_pixbuf(this.image_pixel, 1, null);
        context.set_source_surface(surface, 0.0, 0.0);
        context.paint_with_alpha(alpha);
        return true;
    }
}
