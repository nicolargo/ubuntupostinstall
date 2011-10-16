#!/bin/bash
# Mon script de post installation Ubuntu
#
# Nicolargo - 06/2011
# GPL
#
# Syntaxe: # sudo ./ubuntupostinstall.sh
VERSION="1.48"

#=============================================================================
# Liste des applications à installer: A adapter a vos besoins
# Voir plus bas les applications necessitant un depot specifique
LISTE=""
# Developpement
LISTE=$LISTE" build-essential vim subversion git rabbitvcs-nautilus anjuta textadept"
# Java: http://doc.ubuntu-fr.org/java
LISTE=$LISTE" sun-java6-jre sun-java6-plugin sun-java6-fonts"
# Multimedia
LISTE=$LISTE" x264 ffmpeg2theora oggvideotools istanbul shotwell mplayer hugin nautilus-image-converter pavucontrol gimp gimp-save-for-web ogmrip transmageddon guvcview wavpack mppenc faac flac vorbis-tools faad lame nautilus-script-audio-convert cheese sound-juicer picard avidemux arista nautilus-arista milkytracker"
# Network
LISTE=$LISTE" iperf ifstat wireshark tshark arp-scan htop netspeed nmap netpipe-tcp"
# Systeme
LISTE=$LISTE" preload gloobus-preview gparted lm-sensors sensors-applet compizconfig-settings-manager drapes hardinfo fortune-mod libnotify-bin compiz-fusion-plugins-extra"
# Web
LISTE=$LISTE" pidgin pidgin-facebookchat pidgin-plugin-pack flashplugin-installer xchat googleearth-package lsb-core ttf-mscorefonts-installer"
#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

HOME_PATH=`grep $USERNAME /etc/passwd | awk -F':' '{ print $6 }'`

# On commence par installer aptitude
#-----------------------------------

apt-get -y install aptitude

# Ajout des depots
#-----------------

#UBUNTUVERSION=`lsb_release -c | awk '{print$2}'`
UBUNTUVERSION=`lsb_release -cs`
echo "Ajout des depots pour Ubuntu $UBUNTUVERSION"

# Mon depot a moi
#add-apt-repository ppa:nicolashennion/ppa
#LISTE=$LISTE" sjitter"

# Spideroak
#add-apt-repository "deb http://apt.spideroak.com/debian/ stable non-free"
#wget -q http://apt.spideroak.com/spideroak-apt-pubkey.asc -O- | apt-key add -
#LISTE=$LISTE" spideroak"

# Restricted extra
# The Ubuntu Restricted Extras will install Adobe Flash Player, Java Runtime Environment (JRE) (sun-java-jre) with Firefox plug-ins (icedtea), a set of Microsoft Fonts (msttcorefonts), multimedia codecs (w32codecs or w64codecs), mp3-compatible encoding (lame), FFMpeg, extra Gstreamer codecs, the package for DVD decoding (libdvdread4, but see below for info on libdvdcss2), the unrar archiver, odbc, and cabextract. It also installs multiple "stripped" codecs and avutils (libavcodec-unstripped-52 and libavutil-unstripped-49).
LISTE=$LISTE" ubuntu-restricted-extras"

# Dropbox + pre-requirement Dropbox scripts
add-apt-repository "deb http://www.getdropbox.com/static/ubuntu $UBUNTUVERSION main"
apt-key adv --keyserver pgp.mit.edu --recv-keys FC918B335044912E
LISTE=$LISTE" nautilus-dropbox xclip zenity"

# PPAsearch
#add-apt-repository ppa:wrinkliez/ppasearch
#LISTE=$LISTE" ppasearch"

# GStreamer, daily build
add-apt-repository ppa:gstreamer-developers
LISTE=$LISTE" "`aptitude -w 2000 search gstreamer | cut -b5-60 | xargs -eol`

# Shutter, outil de capture d'ecran
add-apt-repository ppa:shutter
LISTE=$LISTE" shutter"

# Firefox (Daily build)
#add-apt-repository ppa:mozillateam/firefox-stable
#add-apt-repository ppa:mozillateam/firefox-next
#LISTE=$LISTE" firefox-4.0"

# Chromium, LE navigateur Web (dev-channel PPA)
add-apt-repository ppa:chromium-daily/dev
LISTE=$LISTE" chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra chromium-codecs-ffmpeg-nonfree"

# Wine
add-apt-repository ppa:ubuntu-wine
LISTE=$LISTE" wine"

# X264 / THEORA
add-apt-repository ppa:nilarimogard/webupd8

# VLC
add-apt-repository ppa:ferramroberto/vlc
LISTE=$LISTE" vlc vlc-plugin-pulse"
# VLMC
add-apt-repository ppa:webupd8team/vlmc
LISTE=$LISTE" vlmc"

# Banshee
#add-apt-repository  ppa:banshee-team/banshee-daily
#LISTE=$LISTE" banshee banshee-extension-soundmenu"

# Clementine
#add-apt-repository  ppa:me-davidsansome/clementine-dev
#LISTE=$LISTE" clementine"

# GUVCView
add-apt-repository ppa:pj-assis/ppa

# Ubuntu tweak
add-apt-repository ppa:tualatrix/ppa
LISTE=$LISTE" ubuntu-tweak"

# Darktable
#add-apt-repository ppa:pmjdebruijn/darktable-release
#LISTE=$LISTE" darktable"

# Pino
#add-apt-repository ppa:vala-team/ppa
#add-apt-repository ppa:troorl/pino
#LISTE=$LISTE" pino"

# Hotot
add-apt-repository ppa:hotot-team
LISTE=$LISTE" hotot"

# Equinox Themes and Faenza Icon Theme
add-apt-repository ppa:tiheum/equinox
LISTE=$LISTE" gtk2-engines-equinox equinox-theme faenza-icon-theme faenza-extras faenza-icon-mono"

# Conky
#add-apt-repository ppa:conkyhardcore/ppa
#LISTE=$LISTE" conky-all conkybanshee"

# Terminator
add-apt-repository ppa:gnome-terminator/ppa
LISTE=$LISTE" terminator"

# Kazam screencast
#add-apt-repository ppa:and471/kazam-daily-stable
#LISTE=$LISTE" kazam"

# GMailWatcher (http://www.omgubuntu.co.uk/2010/07/gmailwatcher-another-way-to-get-gmail-alerts-in-the-ubuntu-messaging-menu/)
add-apt-repository ppa:loneowais/ppa
LISTE=$LISTE" gmailwatcher"

# WorkSpaces indicator (http://www.omgubuntu.co.uk/2010/10/indicator-workspaces-adds-options-maverick-ppa-plus-hints-at-future-features/)
#add-apt-repository ppa:geod/ppa-geod
#LISTE=$LISTE" indicator-workspaces"

# GetDeb
grep '^deb\ .*getdeb' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
  #echo -e "\n## GetDeb\ndeb http://archive.getdeb.net/ubuntu $UBUNTUVERSION-getdeb apps\n" >> /etc/apt/sources.list
  #wget -q -O- http://archive.getdeb.net/getdeb-archive.key | apt-key add -
  echo -e "\n## GetDeb\ndeb http://mirrors.dotsrc.org/getdeb/ubuntu lucid-getdeb apps\ndeb-src http://mirrors.dotsrc.org/getdeb/ubuntu lucid-getdeb apps\n" >> /etc/apt/sources.list
  apt-key adv --recv-keys --keyserver pgp.mit.edu 46D7E7CF
fi

# Depot partenaires
egrep '^deb\ .*partner' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
	echo "## 'partner' repository"
	echo -e "deb http://archive.canonical.com/ubuntu $UBUNTUVERSION partner\n" >> /etc/apt/sources.list
	echo -e "deb-src http://archive.canonical.com/ubuntu $UBUNTUVERSION partner\n" >> /etc/apt/sources.list
fi

# WebUpd8 (lots of fresh software)
add-apt-repository ppa:nilarimogard/webupd8

# Nautilus elementary
add-apt-repository ppa:am-monkeyd/nautilus-elementary-ppa

# Elementary art
#add-apt-repository ppa:elementaryart
#LISTE=$LISTE" elementary-theme elementary-icon-theme"

# Spotify
egrep '^deb\ .*spotify' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
	echo "## 'Spotify' repository"
	echo -e "deb http://repository.spotify.com stable non-free\n" >> /etc/apt/sources.list
	gpg --keyserver wwwkeys.de.pgp.net --recv-keys 4E9CFF4E
	gpg --export 4E9CFF4E | apt-key add -
fi
LISTE=$LISTE" spotify-client-qt spotify-client-gnome-support"

# Dropbox Share/UnShare scripts
add-apt-repository ppa:nilarimogard/webupd8
LISTE=$LISTE" dropbox-share"

# Gedit Gmate
apt-add-repository ppa:ubuntu-on-rails/ppa
LISTE=$LISTE" gedit-gmate"

# XBMC
#apt-add-repository ppa:team-xbmc/ppa
#LISTE=$LISTE" xbmc"

# VirtualBox 4.0
egrep '^deb\ .*virtualbox' /etc/apt/sources.list > /dev/null
if [ $? -ne 0 ]
then
	echo "deb http://download.virtualbox.org/virtualbox/debian $UBUNTUVERSION contrib" | tee -a /etc/apt/sources.list
	wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -
fi
LISTE=$LISTE" virtualbox-4.0 dkms"

# LibreOffice
add-apt-repository ppa:libreoffice/ppa
LISTE=$LISTE" libreoffice libreoffice-gnome"

# Handbrake
add-apt-repository ppa:stebbins/handbrake-releases
LISTE=$LISTE" handbrake-gtk"

# Sysmonitor
add-apt-repository ppa:alexeftimie/ppa
LISTE=$LISTE" indicator-sysmonitor dstat"

# Jupiter: Power saver for laptop
add-apt-repository ppa:webupd8team/jupiter
LISTE=$LISTE" jupiter"

# Mise a jour de la liste des depots
#-----------------------------------

echo "Mise a jour de la liste des depots"

# Update
aptitude update 2>&1 | grep NO_PUBKEY | perl -pwe 's#^.+NO_PUBKEY (.+)$#$1#' | xargs apt-key adv --recv-keys --keyserver keyserver.ubuntu.com

# Upgrade
aptitude dist-upgrade

# Installations additionnelles
#-----------------------------

echo "Installation des logiciels suivants: $LISTE"

aptitude -y install $LISTE

# GoogleEarth (besoin de generer package)
make-googleearth-package --force
sudo dpkg -i googleearth*.deb
rm -f googleearth*.deb GoogleEarthLinux.bin

# DVD
sudo sh /usr/share/doc/libdvdread4/install-css.sh

# Fortune
cd /usr/share/games/fortunes/
wget http://www.fortunes-fr.org/data/litterature_francaise
strfile litterature_francaise litterature_francaise.dat
wget http://www.fortunes-fr.org/data/personnalites
strfile personnalites personnalites.dat
wget http://www.fortunes-fr.org/data/proverbes
strfile proverbes proverbes.dat
wget http://www.fortunes-fr.org/data/philosophie
strfile philosophie philosophie.dat
wget http://www.fortunes-fr.org/data/sciences
strfile sciences sciences.dat
cd -

# Custom du systeme
gconftool-2 --type Boolean --set /desktop/gnome/interface/menus_have_icons True
gsettings set com.canonical.Unity.Panel systray-whitelist "['all']"

# Custom .bashrc
cat >> $HOME_PATH/.bashrc << EOF
alias alert_helper='history|tail -n1|sed -e "s/^\s*[0-9]\+\s*//" -e "s/;\s*alert$//"'
alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] $(alert_helper)"'
export MOZ_DISABLE_PANGO=1
EOF
source $HOME_PATH/.bashrc

# Hotot mono tray icon
cd ~
wget http://gnome-look.org/CONTENT/content-files/133268-hotot.zip
unzip 133268-hotot.zip
mv *hotot.png /usr/share/hotot/ui/imgs/
rm 133268-hotot.zip
cd -

# Ajout info system dans le panel


# Sensors detect
sensors-detect

# Restart Nautilus
nautilus -q

echo "========================================================================"
echo
echo "Liste des logiciels installés: $LISTE"
echo
echo "Quelques actions à faire en bonus:"
echo
echo "1) Ajouter le profil audio MP3 HQ: gnome-audio-profiles-properties"
echo ">> audio/x-raw-int,rate=44100,channels=2 ! lamemp3enc name=enc target=1 bitrate=320 cbr=1 ! id3v2mux"
echo
echo "2) Theme Gnome (Système/Préference/Apparence): Equinox Evolution Dawn"
echo
echo "========================================================================"

# Fin du script
#---------------

