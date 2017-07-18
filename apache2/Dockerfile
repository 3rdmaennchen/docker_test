############################################################################
# UNDER CONSTRUCTION:
# apache2 (ReverseProxy/FTP)
#############################################################################

# Image und Version
# Debian --> debian:jessie
# RPi    --> resin/rpi-raspbian:latest
# Ubuntu --> ubuntu:latest
FROM debian:jessie

MAINTAINER Erdmaennchen <ich@welt.com>

############################################################################
# Info
#############################################################################

# Ports:
#  apache
#    HTTP   80
#    HTSP   443

############################################################################
# ToDo
#############################################################################

# apache mit Proxy mod installieren (ReverseProxy/FTP/fail2ban)
# letsencrypt installieren (SSL)
# fail2ban installieren
# FTP Server installieren (proftpd)
# SSL Zertifikat erstellen (einmal manuel?)
# automatische Erneuerung des SSL Zertifikates jeden Monat (crontab)
# AuthUserFile mit htpasswd erstellen
# Site-Config in site-available erstellen (Verwalten der einzelnen Seiten)
# Site-Config von site-available in sites-enabled über SymLink verknüpfen (a2ensite <Domain>)
# Site-Config testen (apachectl configtest)
# apache proxy mod starten und apache neu starten

# fail2ban einrichten

# proftpd einrichten
# Verschiedene FTP User anlegen (z.B. IP-Kamera usw.)
# Ordner im FTP-Ordner erstellen und Eigentümer der FTP-User zuweisen (facl-Rechte)

# Erkennung neue Datei in Ordner abgelegt
# eigene fhem WEB mit api und User anlegen
# in fhem webcmd für Geräte vergeben
# Tool zum erkennen von neuen Dateien installieren (inotify-tools)
# Script zum Überwachen eines Ordners erstellen und ausführbar machen
# Erstellten Überwachungs-Script als daemon bekannt machen (update-rc.d)
# Passwort und Rechte für den erstellten fhem User in /etc/passwd anpassen
# Symlink von Kamera Verzeichnis z.B. /upload/camera/ in FTP-Ordner erstellen und Rechte vergeben

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
# Update/Install/Zeitzone
############################################################################

# Standart Pakete installieren
ARG PACKAGE="nano wget git-core curl apt-transport-https usbutils net-tools tar"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# Develepor Commands
ARG _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ARG _apt_clean="eval apt-get clean && $_clean"
ARG _update="eval apt-get update && apt-get upgrade -y --force-yes"
ARG _install="eval apt-get install -y --force-yes"

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

# apache2 mit Reverse Proxy und FTP installieren
# fail2ban und inotify installieren (neue Datei erkannt)
RUN $_install \
apache2 \
libapache2-mod-proxy-html \
cron \
proftpd \
fail2ban \
inotify-tools

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

RUN htpasswd -cbs /etc/htpasswd admin admin && \
    htpasswd -bs /etc/htpasswd user user

############################################################################
# letsencrypt einrichten (SSL)
############################################################################

# /opt/letsencrypt/letsencrypt-auto --help

# Erstes Mal apache starten und letsencrypt ausführen um Config Datei zu erhalten
# Autorisierung von letsencrypt erfordert einen laufenden Webserver min. auf Port 80 (http)

# Autorisierung bei letsencrypt und erstellen von SSL-Zertifikaten
# /opt/letsencrypt/letsencrypt-auto certonly --apache --rsa-key-size 4096 -d <Domain> -m <E-Mail> --agree-tos
# SSL-Zertifikate werden in /etc/letsencrypt/live/<Domain>/ für die Domain ertsellt

# config & Zertifikate von letsencrypt kopieren
COPY /data/config/ssl/ /etc/letsencrypt/
RUN ln -s /etc/letsencrypt/archive/<Domain>/cert1.pem /etc/letsencrypt/live/<Domain>/cert.pem && \
    ln -s /etc/letsencrypt/archive/<Domain>/chain1.pem /etc/letsencrypt/live/<Domain>/chain.pem && \
    ln -s /etc/letsencrypt/archive/<Domain>/fullchain1.pem /etc/letsencrypt/live/<Domain>/fullchain.pem && \
    ln -s /etc/letsencrypt/archive/<Domain>/privkey1.pem /etc/letsencrypt/live/<Domain>/privkey.pem

# letsencrypt für SSL installieren und Version ausgeben
RUN /opt/letsencrypt/letsencrypt-auto --version

# SSL-Zertifikate erneuern (Noch nicht getestet)
RUN echo"0 23    * * *   root    service apache2 stop && /opt/letsencrypt/letsencrypt-auto renew && service apache2 start" >> /etc/crontab

############################################################################
# fail2ban einrichten
############################################################################

# fail2ban Einstellungen kopieren und anpassen (jail.conf)
# cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# nano /etc/fail2ban/jail.local

# fail2ban Pfade wegen docker anpassen
# cp /etc/fail2ban/paths-debian.conf /etc/fail2ban/paths-overrides.local
# nano /etc/fail2ban/paths-overrides.local

# fail2ban Config Datei für apache erstellen (apache.conf)
# nano etc/fail2ban/jail.d/apache.conf

# Feintuning in der apache.conf:
# maximalen Fehlversuche auf 3 bis zum Ban & 1 Stunde Banzeit

############################################################################
# ReverseProxy einrichten
############################################################################

# Alle Site-Config-Dateien liegen in site-available
# Bei Bedarf aktiviert man die Config-Datein über a2ensite <site.config>
# Mit a2dissite <site.config> deaktiviert man die Config

# Nach dem erstellen einer eigenen Config kann man diese Testen und mit Neustart aktivieren
# apachectl configtest
# service apache2 reload

# Bestehende Site-Config in site-available kopieren
COPY /data/config/proxy/sites-available/<Domain>.conf /etc/apache2/sites-available/<Domain>.conf

# Kopierte Config aktivieren
RUN a2ensite <Domain>.conf

############################################################################
# Apache Mods aktivieren
############################################################################

# apache2 Proxy- und SSL-Mod aktivieren
RUN a2enmod proxy proxy_http ssl

############################################################################
# FTP-Server einrichten
############################################################################

# proftpd Config anpassen
# nano /etc/proftpd/proftpd.conf
# UseIPv6                         off
# ServerName                  "FHEM"

# proftpd Custom Config anpassen
# nano /etc/proftpd/conf.d/proftp-custom.conf

# Ftp user doesn't need a valid shell
# <Global>
#     RequireValidShell off
# </Global>

# Default directory is ftpusers home
# DefaultRoot ~ ftpuser

# Limit login to the ftpuser group
# <Limit LOGIN>
#     DenyGroup !ftpuser
# </Limit>

# FTP User und Ordner anlegen
# Verschiedene FTP User je nach Funktion erstellen (ohne Shell)
# Home verzeichnis sinnvoll vergeben und auf Schreib/Lese-Rechte achten

# z.B. für Kamera
# adduser <ftpuser> --shell /bin/false --home /var/www/upload
# Password 2x eingeben

# camera Ordner erstellen und <ftpuser> als Eigentümer zuweisen
# cd /var/www/upload/
# mkdir camera
# chown <ftpuser>:ftpuser camera/

# Erweiterte facl-Rechte für <ftpuser> vergeben (weil man nicht schreiben kann?)
# setfacl -dm g:pi:rwx /var/www/upload/camera/
# setfacl -dm u:fhem:rwx /var/www/upload/camera/
# setfacl -Rm g:pi:rwx /var/www/upload/camera/
# setfacl -Rm u:fhem:rwx /var/www/upload/camera/
# getfacl .

# per FTP nur auf das eigene Home- Vereichnis zugeifen
# nano /etc/proftpd/proftpd.conf
# DefaultRoot ~

############################################################################
# Daemon zur Erkennung neuer Dateien einrichen
############################################################################

# Dummy Neue Datei erstellen
# define OUT.Bewegung dummy
# attr OUT.Bewegung event-on-change-reading current_file

# Befehl über fhem-api testen
# curl http://localhost:8083/fhem?cmd=setreading%20OUT.Bewegung%20current_file%20test

# camerawatch.sh Script anlegen bzw. kopieren
# cd /opt/fhem/
# nano camerawatch.sh

# Verzeichnis auswählen & Rechte des Scriptes anpassen
# chown fhem:dialout camerawatch.sh

# Script zum Testen ausführen
# sh camerawatch.sh

# Script als Daemon anlegen bzw. kopieren
# cd /etc/init.d/
# nano camerawatch

# Rechte des Daemon-Scriptes anpassen
# chmod 755 /etc/init.d/camerawatch

# Daemon mit update-rc.d bekannt machen
# update-rc.d camerawatch defaults

# Daemon zum Testen starten
# service camerawatch start

# Passwort und Rechte des fhem-Benutzers vergeben
# nano /etc/passwd
# --> fhem:x:999:20::/opt/fhem:/bin/bash

# Einfache PushOver bei neuer Datei
# define n_Bewegung notify OUT.Bewegung set Pushover_Client msg 'Bewegung vor der Tür' '$EVENT'

# Kritische PushOver mit Sirene, Erinnerung und ftp-Link bei neuer Datei
# define n_Bewegung notify OUT.Bewegung set Pushover_Client msg 'Bewegung bemerkt' 'Es bewegt sich etwas draußen' '' 2 'siren' 30 3600 'Jetzt ansehen' 'http://192.168.178.21/camera/$EVTPART1'

# SymLink und Rechte einrichten
# Wenn die Kamera ihre Bilder in einen anderen Ordner schreibt
# cd /var/www/html
# sudo ln -s ../upload/camera/ camera
# sudo chown -h www-data:www-data camera

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Verzeichnisse Mounten
############################################################################

# SSL Zertifikate:
# /etc/letsencrypt/live/<Domain>/fullchain.pem
# /etc/letsencrypt/live/<Domain>/privkey.pem

# Log Dateien:
# ErrorLog ${APACHE_LOG_DIR}/<Domain>.error.log
# CustomLog ${APACHE_LOG_DIR}/<Domain>.access.log combined

# SSL Config:
# /etc/letsencrypt/options-ssl-apache.conf

# FTP:
# /var/www/upload/
# /etc/proftpd/proftpd.conf
# /etc/proftpd/conf.d/proftp-custom.conf

# apache2 security Config
# nano /etc/apache2/conf.d/security
# ServerTokens Prod
# ServerSignature Off
# TraceEnable Off
# Options -Indexes

############################################################################
# Portfreigabe
############################################################################

EXPOSE 80 443

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh