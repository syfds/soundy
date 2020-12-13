dependencies = [
    glib, 
    gobject, 
    gtk, 
    granite,
    soup,
    xml
]

src_files = files(['SoundtouchClient.vala', 'Connection.vala', 'Controller.vala', 'Model.vala', 'SoundtouchMessageParser.vala', 'MainPanel.vala', 'HeaderBar.vala', 'FavouriteMenuItem.vala', 'SoundtouchFinder.vala'])
src_files_with_main = src_files + files(['Application.vala'])

executable(
    meson.project_name(),
    sources: src_files_with_main,
    dependencies: dependencies,
    install: true
)
