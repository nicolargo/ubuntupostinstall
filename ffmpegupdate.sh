#!/bin/bash
# Mon script de mise à jour FFMpeg + X264 
#
# Nicolargo - 04/2010
#
# Based on: http://ubuntuforums.org/showthread.php?t=786095
# !!! Attention gestion des accents dans grep Révision !!!
# Revert change: sudo apt-get remove x264 ffmpeg build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev
#
# Syntaxe: # ./ffmpegupdate.sh
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


sudo apt-get remove ffmpeg x264 libx264-dev

cd ~/src/x264
make distclean
git pull
./configure
make
sudo checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default

cd ~/src/ffmpeg
make distclean
svn update
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab
make
sudo checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep vision | awk '{ print $NF }'`" --backup=no --default
hash x264 ffmpeg
