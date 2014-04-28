#!/bin/sh
# Mon script de post installation Firefox
#
# Nicolargo - 04/2010
# GPL
#
# Syntaxe: # ./firefoxpostinstall.sh
VERSION="0.1"

FIREFOX_PATH="$HOME/.mozilla/firefox"
PROFILE_PATH=`grep Path $FIREFOX_PATH/profiles.ini | head -1 | awk -F\= '{ print $2 }'`
EXTENSION_PATH="$FIREFOX_PATH/$PROFILE_PATH/extensions"

echo "Plugins installation on $EXTENSION_PATH"
cd $EXTENSION_PATH
# AddThis
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/4076/addon-4076-latest.xpi
# Better Gmail 2
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/6076/addon-6076-latest.xpi
# Better GReader
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/6424/addon-6424-latest.xpi
# Download Statusbar
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/26/addon-26-latest.xpi
# Fast Dial
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/5721/addon-5721-latest.xpi
# Firebug
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/1843/addon-1843-latest.xpi
# FireFTP
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/684/addon-684-latest.xpi
# Gmail Manager
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/1320/addon-1320-latest.xpi
# PDF Download
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/636/addon-636-latest.xpi
# Pearl Crescent Page Saver Basic
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/10367/addon-10367-latest.xpi
# FireGPG
wget http://fr.getfiregpg.org/stable/firegpg.xpi
# Weave Browser Sync
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/10868/addon-10868-latest.xpi

echo "Theme installation on $EXTENSION_PATH"
# Charamel
wget https://addons.mozilla.org/en-US/firefox/downloads/latest/14313/addon-14313-latest.xpi

cd -

