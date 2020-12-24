# Soundy
Soundy is a simple GTK client for using a Soundtouch network speaker. It is a free and simple alternative to the official client.

## Building and Installation
You'll need the following dependencies:

* glib-2.0', version: '>=2.40'
* gobject-2.0', version: '>=2.40'
* gtk+-3.0'
* granite', version: '>= 0.5.1'
* libsoup-2.4'
* libxml-2.0'

## Building

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build
```
    meson build --prefix=/usr
    cd build
    ninja
```

To install, use `ninja install`

## Tests

To execute the tests
```
cd build || exit
ninja test
```

or `test.sh`
