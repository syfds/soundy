project('com.github.sergejdobryak.soundy', 'vala', 'c')

glib = dependency('glib-2.0', version: '>=2.40')
gobject = dependency('gobject-2.0', version: '>=2.40')
gtk = dependency('gtk+-3.0')
granite = dependency('granite', version: '>= 0.5.1')
soup = dependency('libsoup-2.4')
xml = dependency('libxml-2.0')

subdir('src')
subdir('data')
subdir('test')

executable(
    meson.project_name(),
    sources: src_files_with_main,
    dependencies: dependencies,
    install: true
)

meson.add_install_script('meson/post_install.py')
