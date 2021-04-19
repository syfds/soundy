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

public class FavouriteMenuItem : Gtk.Button {

    private const int ICON_SIZE = 60;

    private Controller controller;
    private string image_url;
    private string item_id;

    public FavouriteMenuItem(Preset preset, string image_url, Controller controller) {
        this.set_tooltip_text(preset.item_name);

        this.image_url = image_url;
        this.can_focus = false;
        this.always_show_image = true;
        this.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        this.get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);


        this.item_id = preset.item_id;
        this.controller = controller;

        this.clicked.connect(() => {
            this.on_click();
        });

        this.load_image_asynchronously();
    }

    private void load_image_asynchronously() {
        if (this.image_url != "") {
            new Thread<void*>("loading favourite image", () => {
                var image = this.create_image_from_url(this.image_url);
                this.set_image(image);
                this.show_all();
                return null;
            });
        } else {
            var menu_icon = new Gtk.Image();
            menu_icon.gicon = new ThemedIcon("multimedia-audio-player");
            menu_icon.pixel_size = ICON_SIZE;
            this.set_image(menu_icon);
            this.show_all();
        }
    }

    public Gtk.Image create_image_from_url(string image_url) {
        Soup.Message msg = new Soup.Message("GET", image_url);
        Soup.Session session = new Soup.Session();

        var input_stream = session.send(msg);

        var image = new Gtk.Image();
        Gdk.Pixbuf image_pixbuf = new Gdk.Pixbuf.from_stream_at_scale(input_stream, ICON_SIZE, ICON_SIZE, true);
        image.set_from_pixbuf(image_pixbuf);
        return image;
    }

    public void on_click() {
        this.controller.play_preset(this.item_id);
    }
}
