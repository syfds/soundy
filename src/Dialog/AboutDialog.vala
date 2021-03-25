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

        response.connect((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                this.hide_on_delete();
            }
        });
    }
}
