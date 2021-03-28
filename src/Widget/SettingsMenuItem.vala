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

public class SettingsMenuItem : Gtk.Button {

    public SettingsMenuItem(string text, string icon_name) {
        halign = Gtk.Align.FILL;

        image = create_icon(icon_name);
        image_position = Gtk.PositionType.LEFT;
        label = text;

        can_focus = false;
        always_show_image = true;

        get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
    }

    public Gtk.Image create_icon(string icon_name) {
        var icon = new Gtk.Image();
        icon.gicon = new ThemedIcon(icon_name);
        icon.pixel_size = 16;
        icon.halign = Gtk.Align.START;
        return icon;
    }
}
