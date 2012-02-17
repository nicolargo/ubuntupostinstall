#!/bin/bash
# Mon script de "post installation" de GNU/Linux Mint Lisa (Mint version 12)
#
# Nicolargo - 02/2012
# GPL
#
# Syntaxe: # sudo ./min-12-postinstall.sh
#
# Release notes:
# 1.12.0: Premiere version du script
#
VERSION="1.12.3"

#=============================================================================
# Liste des applications à installer: A adapter a vos besoins
#
LISTE=""
# Developpement
LISTE=$LISTE" build-essential vim subversion git git-core rabbitvcs-nautilus anjuta geany geany-plugins"
# Multimedia
LISTE=$LISTE" vlc x264 ffmpeg2theora oggvideotools istanbul shotwell mplayer hugin nautilus-image-converter pavucontrol ogmrip transmageddon guvcview wavpack mppenc faac flac vorbis-tools faad lame nautilus-script-audio-convert cheese sound-juicer picard arista nautilus-arista mypaint"
# Network
LISTE=$LISTE" iperf ifstat wireshark tshark arp-scan htop netspeed nmap netpipe-tcp"
# Systeme
LISTE=$LISTE" preload lm-sensors hardinfo fortune-mod libnotify-bin terminator conky-all"
# Web
LISTE=$LISTE" googleearth-package lsb-core ttf-mscorefonts-installer mint-flashplugin"

#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

# Ajout des depots
#-----------------

MINTVERSION=`lsb_release -cs`
echo "Ajout des depots pour Ubuntu $MINTVERSION"

# Spotify
egrep '^deb\ .*spotify' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
	echo "## 'Spotify' repository"
	echo -e "deb http://repository.spotify.com stable non-free\n" >> /etc/apt/sources.list
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4E9CFF4E
fi
LISTE=$LISTE" spotify-client-qt"

# WebUpd8 (lots of fresh software)
add-apt-repository -y ppa:nilarimogard/webupd8
LISTE=$LISTE" dropbox-share"

# Jupiter (only for Laptop)
add-apt-repository -y ppa:webupd8team/jupiter
LISTE=$LISTE" jupiter"

# Mise a jour 
#------------

echo "Mise a jour de la liste des depots"
apt-get -y update

echo "Mise a jour du systeme"
apt-get -y upgrade

# Installations additionnelles
#-----------------------------

echo "Installation des logiciels suivants: $LISTE"

apt-get -y install $LISTE

# Gnome Shell
#############

THEME_SHELL=Faience
THEME_ICONES=Faience-Dark

# Gnome Shell Install icons: Faenza, Faience
apt-get install faenza-icon-theme faenza-icons-mono
wget http://www.deviantart.com/download/255099649/faience_icon_theme_by_tiheum-d47vo5d.zip
mkdir $HOME/.icons
unzip faience_icon_theme_by_tiheum-d47vo5d.zip
mv Faience* $HOME/.icons/
rm -rf faience_icon_theme_by_tiheum-*.zip
chown -R $USERNAME:$USERNAME $HOME/.icons

# Gnome Shell themes: Faience, Nord
mkdir $HOME/.themes
# -- Faience
wget http://www.deviantart.com/download/255097456/gnome_shell___faience_by_tiheum-d47vmgg.zip
unzip gnome_shell___faience_by_tiheum-d47vmgg.zip
mv Faience $HOME/.themes
rm -rf gnome_shell___faience_by_tiheum-*.zip
# -- Nord
wget http://www.deviantart.com/download/214295138/gnome_shell__nord_by_0rax0-d3jl36q.zip
unzip gnome_shell__nord_by_0rax0-d3jl36q.zip
mv Nord ~/.themes
rm -rf nord_by_0rax0-*.zip
# Set perm for all the themes
chown -R $USERNAME:$USERNAME $HOME/.themes

# Set the theme shell and icons 
# gsettings set org.gnome.shell.extensions.user-theme name $THEME_SHELL
# gsettings set org.gnome.desktop.interface icon-theme $THEME_ICONES

# Others
########

# Conky theme
wget -O $HOME/.conkyrc https://raw.github.com/nicolargo/ubuntupostinstall/master/conkyrc

# GoogleEarth (need packet generation > installation)
make-googleearth-package --force
dpkg -i GoogleEarth*.deb
rm -f GoogleEarth*.deb GoogleEarthLinux.bin

# Need to read DVD
sh /usr/share/doc/libdvdread4/install-css.sh

# Vimrc
wget -O - https://raw.github.com/vgod/vimrc/master/auto-install.sh | sh

# Terminator
mkdir -p ~/.config/terminator
wget -O ~/.config/terminator/config https://raw.github.com/nicolargo/ubuntupostinstall/master/config.terminator
chown -R $USERNAME:$USERNAME ~/.config/terminator

# Custom .bashrc
cat >> $HOME/.bashrc << EOF
alias la='ls -alF'
alias ll='ls -lF'
alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
EOF
source $HOME/.bashrc

echo "========================================================================"
echo
echo "Liste des logiciels installés: $LISTE"
echo
echo "========================================================================"
echo
echo "Le script doit relancer votre session pour finaliser l'installation."
echo "Assurez-vous d’avoir fermé tous vos travaux en cours avant de continuer."
echo "Appuyer sur ENTER pour relancer votre session (ou CTRL-C pour annuler)"
read ANSWER
service lightdm restart

# Fin du script
#---------------
