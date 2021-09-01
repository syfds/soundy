public class GlobalGrid : Gtk.Grid{

    private Gtk.Grid container;

    private MainPanel main_panel;
    private Gtk.ApplicationWindow main_window;

    public GlobalGrid(Controller controller, Model model, Soundy.Settings settings, Gtk.ApplicationWindow main_window){

        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.FILL;

        container = new Gtk.Grid();
        container.margin = 10;
        container.row_spacing = 10;
        container.column_spacing = 10;
        container.orientation = Gtk.Orientation.VERTICAL;
        container.valign = Gtk.Align.FILL;
        

        main_panel = new MainPanel(controller, model, settings);
        this.main_window = main_window;

        container.attach(main_panel, 0, 0, 1, 1);

        controller.speaker_panel_toggled.connect((show) => {
            
            foreach (Gtk.Widget child in this.container.get_children()){
                    this.container.remove(child);
            }

            container.attach(main_panel, 0, 0, 1, 1);
            
            if(show) {
                container.attach(new SpeakerPanel(controller, model), 0, 1, 2, 1);
            }

            this.container.show_all();
            this.show_all();
        });

        add(container);

        this.show_all();
    }
}