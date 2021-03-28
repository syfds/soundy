/* Copyright 2021 Sergej Dobryak <sergej.dobryak@gmail.com>
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*/

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
