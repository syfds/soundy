# Soundy
Soundy is a simple GTK client written in Vala to control a Soundtouch network speaker. 
It is a free and simple alternative to the official client.
The app connects to the speaker over Soundtouch API (https://developer.bose.com/guides/bose-soundtouch-api/bose-soundtouch-api-reference).

## Features
* Power ON/OFF
* Play/Pause the currently selected track
* Playing next or previous track
* Increasing/decreasing volume
* Displaying and playing the favourites

![Soundy Screenshot](https://github.com/syfds/soundy/blob/master/data/screenshot/screenshot-1.png)
![Soundy Screenshot](https://github.com/syfds/soundy/blob/master/data/screenshot/screenshot-2.png)
![Soundy Screenshot](https://github.com/syfds/soundy/blob/master/data/screenshot/screenshot-3.png)

## Building and Installation
You'll need the following dependencies:

* glib-2.0, version: '>=2.40'
* gobject-2.0, version: '>=2.40'
* gtk+-3.0
* granite, version: '>= 0.5.1'
* libsoup-2.4
* libxml-2.0

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

## Installation on Ubuntu (tested on ubuntu 20.04)

install all dependencies
```
sudo add-apt-repository ppa:vala-team
sudo apt-get update
sudo apt-get install vala-0.48-doc valac-0.48-vapi valac build-essential libgtk-3-dev meson libgranite-dev libsoup2.4-dev gettext
```

clone the repository and run locally
```
cd ~
mkdir workspace
cd workspace
git clone https://github.com/syfds/soundy.git
cd soundy
meson build --prefix=/usr
cd build
sudo ninja install
```
after that you can find "Soundy" in all your applications or alternatively run `com.github.sergejdobryak.soundy` from command line

uninstall the app
```
cd ~/workspace/soundy/build
sudo ninja uninstall
```

## How-To
I suggest to assign your soundtouch speaker to a static IP address (address reservation), so the desktop client can quickly find your speaker at startup. Example for TP-Link (can be different for your router):
* Login (something like 192.168.0.1 or similar) and go to `DHCP` -> `DHCP Client List` and copy the MAC-address of your speaker.
* Then create a static assignment in `Address Reservation`, after restarting the speaker the correct assignment can be checked in the `DHCP Client List`.
* Create a hosts entry in `/etc/hosts` where `192.168.1.XXX` is your static IP address
```
192.168.1.XXX   soundtouch-speaker
```
* now you can set `soundtouch-speaker` as host in the app and connect to your soundtouch speaker ;-)
