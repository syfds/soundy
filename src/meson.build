dependencies = [
    glib, 
    gobject, 
    gtk, 
    granite,
    soup,
    xml
]

src_files = files(['MainPanel.vala'])
src_files_with_main = src_files + files(['Application.vala', 'SoundtouchClient.vala', 'Connection.vala', 'Controller.vala', 'Model.vala'])

executable(
    meson.project_name(),
    sources: src_files_with_main,
    dependencies: dependencies,
    install: true
)
