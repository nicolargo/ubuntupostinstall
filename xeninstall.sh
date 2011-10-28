#!/bin/bash
# Mon script d'installation Xen 4.0.1
#
# Nicolargo - 11/2010
#
# Based on: http://blog.nicolargo.com/?p=3999
#
# Syntaxe: # sudo ./ffmpeginstall.sh
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

# Are you r00t ?
if [ $EUID -ne 0 ]; then
  echo "Script should be run as root: # sudo $0" 1>&2
  exit 1
fi

# Fonctions
#----------

function execdisplay {
	echo -n "$2: Please wait..."
	'$1' > /dev/null 2>&1
	echo -e "\r$2: Done (return code $?)"
}

function execshowdisplay {
	echo "$2: Please wait..."
	$1
	echo "$2: Done (return code $?)"
}

# Main program
#-------------

# Warning
echo "This script install Xen 4.0.1 on Ubuntu 10.04 LTS"
echo ">> Press ENTER to begin or CTRL-C to abord..."
read answer

# Installation
execdisplay "aptitude -f update" "System update"
execdisplay "aptitude -f safe-upgrade" "System upgrade"
execdisplay "aptitude -f install bcc bin86 gawk bridge-utils iproute libcurl3 libcurl4-openssl-dev bzip2 module-init-tools transfig tgif texinfo texlive-latex-base texlive-latex-recommended texlive-fonts-extra texlive-fonts-recommended libpci-dev mercurial build-essential make gcc libc6-dev zlib1g-dev python python-dev python-twisted libncurses5-dev patch libvncserver-dev libsdl-dev libjpeg62-dev iasl libbz2-dev e2fslibs-dev git-core uuid-dev ocaml libx11-dev xz-utils" "Install pre-requisites"
if [[ `getconf LONG_BIT` == 64 ]]
then
	execdisplay "aptitude install gcc-multilib" "64 bits pre-requisites"
fi
execdisplay "cd /usr/src ; wget http://bits.xensource.com/oss-xen/release/4.0.1/xen-4.0.1.tar.gz ; tar zxvf xen-4.0.1.tar.gz ; rm xen-4.0.1.tar.gz ; cd xen-4.0.1" "Download Xen 4.0.1"
execdisplay "make xen ; make tools ; make stubdom" "Compile Xen 4.0.1"
execdisplay "make install-xen ; make install-tools ; make install-stubdom" "Install Xen 4.0.1"
execshowdisplay "make world" "Build Linux Kernel for Xen"


exit 0
