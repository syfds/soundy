dependencies = [
    glib, 
    gobject, 
    gtk, 
    granite,
    soup,
    xml
]

src_files = files([
'SoundtouchClient.vala',
'WebsocketConnection.vala',
'Controller.vala',
'Model.vala',
'SoundtouchMessageParser.vala',
'Widget/MainPanel.vala',
'Widget/HeaderBar.vala',
'Widget/FavouriteMenuItem.vala',
'SoundtouchFinder.vala',
'Dialog/ConnectionDialog.vala'
])

src_files_with_main = src_files + files(['Application.vala'])

executable(
    meson.project_name(),
    sources: src_files_with_main,
    dependencies: dependencies,
    install: true
)
