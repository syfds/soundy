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

public class LoadableImagePanel : Gtk.Grid {
    private Gtk.Spinner loading_spinner;
    private Gtk.Overlay overlay;
    private Gtk.Widget image_container;
    private int width;
    private int height;

    private Gdk.Pixbuf image_pixbuf;

    public LoadableImagePanel(string image_url, int width, int height) {
        this.width = width;
        this.height = height;

        this.init_gui();
        this.create_image_from_url(image_url, width, height);
    }

    private void init_gui() {
        this.set_orientation(Gtk.Orientation.HORIZONTAL);
        this.set_halign(Gtk.Align.CENTER);
        this.set_valign(Gtk.Align.CENTER);

        loading_spinner = new Gtk.Spinner();
        loading_spinner.halign = Gtk.Align.CENTER;
        loading_spinner.valign = Gtk.Align.CENTER;
        loading_spinner.expand = true;
        loading_spinner.active = true;
    }

    public void start_loading_spinner() {
        loading_spinner.start();
        this.clear_panel();
        overlay = new Gtk.Overlay();
        overlay.add_overlay(loading_spinner);
        overlay.add(this.create_image_widget(0.1));

        this.attach(this.overlay, 0, 0);
    }

    public void stop_loading_spinner() {
        loading_spinner.stop();
        this.clear_panel();

        image_container = create_image_widget(1.0);

        attach(image_container, 0, 0);
    }

    public void create_image_from_url(string image_url, int width, int height) {
        Soup.Message msg = new Soup.Message("GET", image_url);
        Soup.Session session = new Soup.Session();

        var input_stream = session.send(msg);

        this.image_pixbuf = new Gdk.Pixbuf.from_stream_at_scale(input_stream, width, height, true);
    }


    public Gtk.Widget create_image_widget(double alpha) {
        return new LoadableImage.from(this.image_pixbuf, this.width, this.height, alpha);
    }

    public void clear_panel() {
        if (overlay != null) {
            this.remove(overlay);
        }

        if (image_container != null) {
            this.remove(image_container);
        }

    }
}
