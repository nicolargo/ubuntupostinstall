#!/bin/sh
# Script de post install pour QoSBox
#
# Syntaxe: # sudo ./qosboxpostinstall.sh
VERSION="0.13"

LISTE="build-essential ssh traceroute wireshark tshark bmon ifstat vnstat ntop netperf iperf nfdump perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl libmd5-perl netpipe-tcp libnet-telnet-cisco-perli nuttcp netspeed gnuplot xinetd tftpd tftp"

# Ajout des depots
#-----------------

UBUNTUVERSION=`lsb_release -c | awk '{print$2}'`
MSGPASSWORD="Password"
MSG="Ajout des depots"

# Mon depot PPA a moi (sjitter)
add-apt-repository ppa:nicolargo
LISTE=$LISTE" sjitter"

# NGINX / PHP5-FPM
add-apt-repository ppa:nginx/stable
add-apt-repository ppa:brianmercer/php
LISTE=$LISTE" nginx php5-fpm"

# Mise a jour de la liste des depots
#-----------------------------------

aptitude update

# Installation des logiciels
#---------------------------

aptitude -y install $LISTE

# Configuration du PC en mode routeur
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Installation de Webmin
cd /tmp
wget http://www.webmin.com/download/deb/webmin-current.deb -O webmin-current.deb
dpkg -i webmin-current.deb
cd -

# Post configuration de Ntop
/etc/init.d/ntop stop
chmod -R 777 /var/lib/ntop
echo "Saisir le mot de passe admin pour Ntop: "
read PASSWORD
ntop -A $PASSWORD
cat sed 's/eth0/eth1/g' /var/lib/ntop/init.cfg > /var/lib/ntop/init.cfg
/etc/init.d/ntop start

# VNStat
(crontab -l; echo "*/5 * * * * root if [ -x /usr/bin/vnstat ] && [ `ls -l /var/lib/vnstat/ | wc -l` -ge 1 ]; then /usr/bin/vnstat -u; fi") | crontab -
vnstat -u -i eth0 --nick "LAN"
vnstat -u -i eth1 --nick "WAN"
crontab -l

# PepSAL
cd /tmp
aptitude install libnetfilter-queue-dev
PEPSAL_VERSION="2.0.1"
wget -O pepsal-$PEPSAL_VERSION.tar.gz http://downloads.sourceforge.net/project/pepsal/pepsal/pepsal-$PEPSAL_VERSION/pepsal-$PEPSAL_VERSION.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpepsal%2Ffiles%2F&ts=1288704950&use_mirror=ovh
tar zxvf pepsal-$PEPSAL_VERSION.tar.gz
cd pepsal-$PEPSAL_VERSION
./configure
make
make install
cd -

# Module CPAN pour les scripts
cpan Net::IPv4Addr
cpan XML::Simple
cpan Net::Telnet::Cisco
cpan Net::Ping

# Module Perl pour NGinx
perl -MCPAN -e 'install FCGI'
wget -O /usr/bin/fastcgi-wrapper.pl http://lindev.fr/public/nginx/fastcgi-wrapper.pl
chmod 755 /usr/bin/fastcgi-wrapper.pl
wget -O /etc/init.d/perl-fastcgi http://svn.nicolargo.com/ubuntupostinstall/trunk/perl-fastcgi
chmod 755 /etc/init.d/perl-fastcgi
update-rc.d perl-fastcgi defaults
service perl-fastcgi start

# Nginx
wget http://svn.nicolargo.com/ubuntupostinstall/trunk/nginxautoinstall.sh
chmod a+x nginxautoinstall.sh
./nginxautoinstall.sh
rm -f ./nginxautoinstall.sh
wget -O /etc/nginx/sites-available/default-site-perl http://svn.nicolargo.com/ubuntupostinstall/trunk/default-site-perl
rm -f /etc/nginx/sites-enabled/default-site
ln -s /etc/nginx/sites-available/default-site-perl /etc/nginx/sites-enabled/default-site-perl 
service nginx reload

# Serveur SSH
echo "UseDNS no" >> /etc/ssh/sshd_config
service ssh restart

# Fin du script
#---------------

HOSTNAME=`hostname`
echo "Fin de l'installation"

