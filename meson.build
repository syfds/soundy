project('com.github.syfds.soundy', 'vala', 'c')

glib = dependency('glib-2.0', version: '>=2.40')
gobject = dependency('gobject-2.0', version: '>=2.40')
gtk = dependency('gtk+-3.0')
granite = dependency('granite')
soup = dependency('libsoup-2.4')
xml = dependency('libxml-2.0')
avahi = dependency('avahi-gobject')
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('po')
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
