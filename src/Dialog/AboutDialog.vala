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

public class AboutDialog: Gtk.AboutDialog {

    public AboutDialog() {
        this.set_destroy_with_parent(true);
        this.set_modal(true);

        logo_icon_name = Soundy.Settings.APP_ID;
        documenters = null;
        translator_credits = null;
        copyright = "Copyright © 2021 Soundy";
        license_type = Gtk.License.GPL_3_0;
        wrap_license = true;
        website = "https://github.com/syfds/soundy";
        website_label = "Github";
        version = "v" + Soundy.Settings.VERSION;

        response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                this.hide_on_delete();
            }
        });
    }
}
