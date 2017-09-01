#############################################################################
# apache2 (ReverseProxy)
#############################################################################

# Image und Version
# Debian --> debian:jessie
# RPi    --> resin/rpi-raspbian:latest
# Ubuntu --> ubuntu:latest
FROM debian:jessie

MAINTAINER Erdmaennchen <ich@welt.com>

############################################################################
# Benutzdefinierte Parameter
############################################################################

# Timezone
ENV TZ="Europe/Berlin"

# apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

############################################################################
# Portfreigabe
############################################################################

# Ports:
#  apache
#    HTTP   80
#    HTSP   443

EXPOSE 80 443

############################################################################
# Laufwerke (docker volume) erstellen
############################################################################

# Dockerfile             Docker volume erstellen
# docker-compose (yml)   Docker volume in container mounten

# SSl-Zertifikate
VOLUME /etc/letsencrypt

############################################################################
# Update/Install/Zeitzone
############################################################################

# Standart Pakete installieren
ARG PACKAGE="nano wget git-core curl apt-transport-https usbutils net-tools tar xz-utils"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# Develepor Commands
ARG _clean="cd / && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG _update="eval apt-get update && apt-get upgrade -y --force-yes"
ARG _install="eval apt-get install -y --force-yes"
ARG _deinstall="eval apt-get purge -qq"

# Develepor Parameter
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Updates & Dist-Upgrades installieren
RUN $_update && \
apt-get install -y --force-yes --no-install-recommends apt-utils && \
apt-get dist-upgrade -y --force-yes

# Standart Pakete installieren
RUN $_install $PACKAGE

# Zeitzone einstellen
RUN echo ${TZ} > /etc/timezone && dpkg-reconfigure tzdata

############################################################################
# Pakete installieren
############################################################################

# apache2 mit Reverse Proxy und fail2ban installieren
RUN $_install \
apache2 \
libapache2-mod-proxy-html \
cron \
fail2ban \
proxytunnel

# letsencrypt für SSL downloaden
RUN git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt/

############################################################################
# html Seite kopieren
############################################################################

COPY /data/html/ /var/www/html/

############################################################################
# AuthUserFile mit htpasswd erstellen
############################################################################

# Auth Datei für Reverse Proxy- und FTP-Benutzer erstellen

# htpasswd -cbs passwordfile username password
# -c    create
# -b    use cmd password
# -s    SHA encrypt

RUN htpasswd -cbs /etc/alexa-htpasswd fhemalexa fhemalexa && \
    htpasswd -cbs /etc/fhemapi-htpasswd fhemapi fhemapi && \
#    htpasswd -cbs /etc/fhemapi-htpasswd fhemifttt fhemifttt && \
    htpasswd -cbs /etc/user-htpasswd user1 pwd1 && \
    htpasswd -bs /etc/user-htpasswd user2 pwd2

# vorhandene Auth-Datei kopieren, nachdem sie mit o.g. Befehlen generiert wurde?

############################################################################
# letsencrypt einrichten (SSL)
############################################################################

# letsencrypt Help
# /opt/letsencrypt/letsencrypt-auto --help

# Erstes Mal apache2 starten und letsencrypt ausführen um Config Datei zu erhalten
# Autorisierung von letsencrypt erfordert einen laufenden Webserver min. auf Port 80 (http)

# Autorisierung bei letsencrypt und erstellen von SSL-Zertifikaten
# /opt/letsencrypt/letsencrypt-auto certonly --apache --rsa-key-size 4096 -d <website> -m <e-mail> --agree-tos

# SSL-Zertifikate werden in /etc/letsencrypt/archive/<website>/ ertsellt und
# in /etc/letsencrypt/live/<website>/ aktiviert

# config & Zertifikate von letsencrypt kopieren
COPY /data/config/ssl/ /etc/letsencrypt/


# Archivierte Zertifikate mit SymLink aktivieren (/etc/letsencrypt/live/<website>/)
RUN ln -s /etc/letsencrypt/archive/<website>/cert1.pem /etc/letsencrypt/live/<website>/cert.pem && \
    ln -s /etc/letsencrypt/archive/<website>/chain1.pem /etc/letsencrypt/live/<website>/chain.pem && \
    ln -s /etc/letsencrypt/archive/<website>/fullchain1.pem /etc/letsencrypt/live/<website>/fullchain.pem && \
    ln -s /etc/letsencrypt/archive/<website>/privkey1.pem /etc/letsencrypt/live/<website>/privkey.pem

# letsencrypt installieren und archivierte Zertifikate erneuern
RUN /opt/letsencrypt/letsencrypt-auto --version && \
    /opt/letsencrypt/letsencrypt-auto renew

# SSL-Zertifikate jeden Tag um 3 Uhr über crontab prüfen, ob die Zertifikate erneuert werden müssen
RUN echo " 0 3    * * *   root    /opt/letsencrypt/letsencrypt-auto renew && service apache2 reload" >> /etc/crontab

############################################################################
# ReverseProxy einrichten
############################################################################

# Alle Site-Config-Dateien liegen in site-available
# Bei Bedarf aktiviert man die Config-Datein über a2ensite <site.config>
# Mit a2dissite <site.config> deaktiviert man die Config

# Nach dem erstellen einer eigenen Config kann man diese Testen und aktivieren
# apachectl configtest
# service apache2 reload

# apache2 Proxy- und SSL-Mod aktivieren &
# apache erstmalig starten, damit /etc/apache2/ erstellt wird
RUN a2enmod proxy proxy_http ssl && \
    service apache2 start
#    usr/sbin/apache2ctl -k start

# Site-Config für <website> in site-available kopieren
COPY data/config/proxy/<website>.conf /etc/apache2/sites-available/<website>.conf

# Kopierte Config Testen & aktivieren
RUN apachectl configtest && \
    a2ensite <website>.conf

############################################################################
# fail2ban einrichten
############################################################################

# fail2ban Standart-Einstellungen kopieren
# cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Eigene fail2ban Einstellungen anpassen
# nano /etc/fail2ban/jail.d/apache2.local
# max. Fehlversuche = 3x innerhalb 10 min
# Banzeit           = 3600 (1h)

# fail2ban neu starten (neue Config Dateien werden geladen)
# service fail2ban restart

# Status von fail2ban ausgeben (Eigene fail2ban Einstellungen überprüfen)
# fail2ban-client status

# Status von fail2ban ausgeben z.B. apache oder ssh
# fail2ban-client status apache
# fail2ban-client status ssh

# Eigene fail2ban Einstellungen kopieren
COPY data/config/fail2ban/apache2.local /etc/fail2ban/jail.d/apache2.local

# Eigene Ban-Aktion erstellen
# Bestehende Ban-Aktion als Vorlage kopieren z.b. iptables-multiport.conf
# cp /etc/fail2ban/action.d/iptables-multiport.conf /etc/fail2ban/action.d/<Name>.conf
# nano /etc/fail2ban/action.d/<Name>.conf
# Aktion bzw. Zeile unter der "actionban =" Zeile hinzufügen
# ggf. Variable unter "[Init]" hinzufügen

# Eigene Ban-Aktion hinzufügen
# COPY data/config/fail2ban/action.d/<Name>.conf /etc/fail2ban/action.d/<Name>.conf

# Ban-Aktion: Alle Verbindungen in docker blocken (docker-ban.conf)
# nano /etc/fail2ban/action.d/docker-ban.conf
COPY data/config/fail2ban/action.d/docker-ban.conf /etc/fail2ban/action.d/docker-ban.conf

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Start-Script
############################################################################

COPY entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh