#!/usr/bin/env python3

import os
import subprocess

install_prefix = os.environ['MESON_INSTALL_PREFIX']
print(install_prefix)
schemadir = os.path.join(install_prefix, 'share/glib-2.0/schemas')
print(schemadir)
if not os.environ.get('DESTDIR'):
    print('Compiling the gsettings schemas...')
    subprocess.call(['glib-compile-schemas', schemadir])
