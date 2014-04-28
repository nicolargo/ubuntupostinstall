#!/bin/bash
#
# Script de post installation serveur Ratcom
#
# Nicolas Hennion - 05/2010
# GPL
#
# Syntaxe: # sudo ./ratcompostinstall.sh
VERSION="0.1"

LISTE="build-essential subversion unzip sun-java6-jre mysql-server slapd openvpn openvpn-auth-ldap" 

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

# Ajout des depots
#-----------------

UBUNTUVERSION=`lsb_release -c | awk '{print$2}'`
echo "Ajout des depots pour Ubuntu $UBUNTUVERSION"

# Mise a jour de la liste des depots
#-----------------------------------

echo "Mise a jour de la liste des depots"

echo "# Partner depot" >> /etc/apt/sources.list
echo "deb http://archive.canonical.com/ubuntu $UBUNTUVERSION partner" >> /etc/apt/sources.list
echo "deb-src http://archive.canonical.com/ubuntu $UBUNTUVERSION partner" >> /etc/apt/sources.list

aptitude update

# Installations additionnelles
#-----------------------------

echo "Installation des logiciels suivants: $LISTE"

aptitude -y install $LISTE

# Java SUN
update-java-alternatives -s java-6-sun

# Liferay
LIFERAYVERSION="5.2.3"
TOMCATSHORTVERSION="6.0"
TOMCATFULLVERSION="6.0.18"
cd /usr/src
echo "Installation de Liferay $LIFERAYVERSION"
wget http://sourceforge.net/projects/lportal/files/Liferay%20Portal/liferay-portal-tomcat-$TOMCATSHORTVERSION-$LIFERAYVERSION.zip
cd /opt
unzip /usr/src/liferay-portal-tomcat-$TOMCATSHORTVERSION-$LIFERAYVERSION.zip
ln -s liferay-portal-$LIFERAYVERSION liferay
ln -s tomcat-$TOMCATFULLVERSION liferay/tomcat
echo "Automatisation du lancement de Liferay au boot"
mv /etc/rc.local /etc/rc.local.default
sed '$d' /etc/rc.local > /etc/rc.local.new
echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun && PATH=$JAVA_HOME/bin:$PATH && cd /opt/liferay/tomcat/bin && ./startup.sh" >> /etc/rc.local.new
echo "exit 0" >> /etc/rc.local.new
cp /etc/rc.local.new /etc/rc.local
chmod 744 /etc/rc.local

# Fin du script
#---------------
