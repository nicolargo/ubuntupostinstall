#!/bin/bash
# Script installation de GStreamer (la totale)
#
# Nicolargo - 05/2010
# GPL
#
# Syntaxe: # sudo ./gstreamerinstall.sh
VERSION="0.1"

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

# Ajout des depots
#-----------------

UBUNTUVERSION=`lsb_release -c | awk '{print$2}'`
echo "Ajout du depots ppa:gstreamer-developers pour $UBUNTUVERSION"

add-apt-repository ppa:gstreamer-developers

# Mise a jour de la liste des depots
#-----------------------------------

echo "Mise a jour de la liste des depots"

aptitude update

# Ajout de toutes les fonctions GStreamer
LISTE=`aptitude -w 2000 search gstreamer | cut -b5-60 | xargs -eol`

# Installations additionnelles
#-----------------------------

echo "Installation des paquets suivants: $LISTE"

aptitude -y install $LISTE

echo "Fin de l'installation"

gst-inspect 2>&1 | tail -1

# Fin du script
#---------------

