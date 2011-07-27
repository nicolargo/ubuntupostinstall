#!/bin/bash
#
# Mon script d'installation automatique de NGinx (depuis les sources)
# Pour Ubuntu Desktop et Ubuntu Server
#
# Nicolargo - 02/2011
# GPL
#
# Syntaxe: # sudo ./nginxautoinstall.sh
VERSION="1.1"

##############################
# Debut de l'installation

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

# Ajout dépot NGinx
add-apt-repository ppa:nginx/stable

# Ajout dépot PHP5-FPM
add-apt-repository ppa:brianmercer/php

# MaJ des depots
aptitude update

# Installation
aptitude install nginx
aptitude install php5-cli php5-common php5-mysql php5-suhosin php5-fpm php5-cgi php-pear php5-xcache php5-gd php5-curl 
aptitude install libcache-memcached-perl php5-memcache memcached

# Download the default configuration file
# Nginx + default site
wget --no-check-certificate https://raw.github.com/nicolargo/debianpostinstall/master/default-site
mv default-site /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/default-site /etc/nginx/sites-enabled/default-site 

# Start PHP5-FPM and NGinx
/etc/init.d/php5-fpm start
/etc/init.d/nginx start

# Summary
echo ""
echo "--------------------------------------"
echo "NGinx + PHP5-FPM installation finished"
echo "--------------------------------------"
echo "NGinx configuration folder:       /etc/nginx"
echo "NGinx default site configuration: /etc/nginx/sites-enabled/default-site"
echo "NGinx default HTML root:          /var/www"
echo ""
echo "If you use IpTables add the following rules:"
echo "iptables -A INPUT -i lo -s localhost -d localhost -j ACCEPT"
echo "iptables -A OUTPUT -o lo -s localhost -d localhost -j ACCEPT"
echo "iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"
echo "iptables -A INPUT  -p tcp --dport http -j ACCEPT"
echo "--------------------------------------"
echo ""

# Fin du script
