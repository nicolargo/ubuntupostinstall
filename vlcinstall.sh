#!/bin/sh
#
# Installation de VLC 1.1 depuis les sources (GIT)
#
# Nicolargo - 05/2010
#
# Syntaxe: # ./vlcinstall.sh
#
# Sources:
# * http://wiki.videolan.org/UnixCompile
#
# GPL
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
VERSION="0.1"

echo "Suppression de la version système de VLC"
sudo aptitude remove vlc
echo "Installation de pré-requis système"
sudo aptitude build-dep vlc
sudo aptitude install autoconf automake gettext pkg-config lua50 libxcb-shm0-dev libxcb-xv0-dev libx11-xcb-dev

echo "Téléchargement depuis GIT"
mdkir ~/src
cd ~/src
git clone git://git.videolan.org/vlc/vlc-1.1.git

cd ~/src/vlc-1.1
echo "Génération des fichiers d'installations"
./bootstrap
echo "Configuration de VLC"
./configure --enable-growl --enable-v4l --enable-vcdx --enable-wma-fixed --enable-merge-ffmpeg --enable-faad --enable-real --enable-realrtsp --enable-lirc
echo "Compilation (La patience est une vertu qui s'acquiert avec de la patience.)"
make
sudo checkinstall



