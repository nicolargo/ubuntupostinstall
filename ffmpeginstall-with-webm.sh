#!/bin/bash
# Mon script d'installation FFMpeg + X264 + WebM
#
# Attention, comme le codec Webm (VP8) est encore en beta, il faut
# patcher la version SVN 23210 avec le patch mplayer-vp8-encdec-support-r3.tar.bz2 
#
# Nicolargo - 05/2010
#
# Based on: 
# - http://ubuntuforums.org/showthread.php?t=786095
# - http://lardbucket.org/blog/archives/2010/05/19/vp8-webm-and-ffmpeg/
# !!! Attention gestion des accents dans grep Révision !!!
#
# Revert change: sudo apt-get remove x264 ffmpeg build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev
#
# Syntaxe: # ./ffmpeginstall-with-webm.sh
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
VERSION="0.2"

mkdir ~/src
mkdir ~/src/ffmpeg-with-webm

sudo apt-get remove ffmpeg x264 libx264-dev libvpx0 libvpx-dev

sudo apt-get update
sudo apt-get install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev

cd ~/src/ffmpeg-with-webm
git clone git://git.videolan.org/x264.git
cd x264
./configure
make
sudo checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default

cd ~/src/ffmpeg-with-webm
git clone git://review.webmproject.org/libvpx.git
cd libvpx
./configure
make
sudo cp vp8/*.h /usr/include/
sudo cp vpx_codec/*.h /usr/include/
sudo cp vpx_ports/*.h /usr/include/
sudo cp libvpx.a /usr/lib/
sudo checkinstall --pkgname=libvpx0 --pkgversion "`./build/make/version.sh | grep VERSION_STRING_NOSP | sed -e "s/.*\"\(.*\)\"/\1/"`" --backup=no --default

cd ~/src/ffmpeg-with-webm
svn checkout -r 23210 svn://svn.ffmpeg.org/ffmpeg/trunk/ ffmpeg
wget http://webm.googlecode.com/files/mplayer-vp8-encdec-support-r3.tar.bz2
tar jxvf mplayer-vp8-encdec-support-r3.tar.bz2
cd ffmpeg
patch -p0 < ../ffmpeg@23210_libvpx@6cd4a10-VP8__WebM.diff
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libfaad --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab --enable-libvpx
make
sudo checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep vision | awk '{ print $NF }'`" --backup=no --default
hash x264 ffmpeg 
