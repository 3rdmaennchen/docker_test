############################################################################
# proftpd (FTP/SMB/NFS)
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

############################################################################
# Portfreigabe
############################################################################

# Ports:
#  proftpd
#    FTP   21
#  samba
#

EXPOSE 20 21 137/udp 138/udp 139 445

############################################################################
# Laufwerke erstellen (docker volume)
############################################################################

# Dockerfile             Docker volume erstellen
# docker-compose (yml)   Docker volume in container mounten

# SSL-Zertifikate
# TV-Aufnahmen
# FTP Camera & FHEM

VOLUME /etc/letsencrypt /var/www/ftp/recordings/ /var/www/ftp/camera/ /var/www/ftp/fhem/

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

# proftpd und inotify (neue Datei erkannt) installieren
RUN $_install \
proftpd \
inotify-tools \
samba

############################################################################
# FTP-Server einrichten
############################################################################

# Config testen
# exec proftpd --configtest

# proftpd neu laden
# service proftpd reload

# FTP Config kopieren (proftp-custom.conf)
COPY data/config/ftp/proftp-custom.conf /etc/proftpd/conf.d/proftp-custom.conf

# TLS Config kopieren (tls-custom.conf)
COPY data/config/ftp/tls-custom.conf /etc/proftpd/conf.d/tls-custom.conf

# Virtuelle FTP-User und Ordner anlegen
# Verschiedene FTP User je nach Funktion erstellen (ohne Shell)
# Home verzeichnis der User sinnvoll vergeben und auf Schreib/Lese-Rechte achten

# False Shell hinzufügen
RUN echo "/bin/false">>/etc/shells && \
# FTP-Ordner Eigentümer Gruppen für ftpuser zuordnen (gid=9999)
    chgrp -R 9999 /var/www/ftp/ && \
# FTP-Ordner Schreibrechte für Gruppe vergeben
    chmod 775 -R /var/www/ftp && \
# FTP Gruppe anlegen (gid=9999)
    cd /etc/proftpd/ && \
    ftpasswd --group --name ftpuser -gid 9999 && \
# FTP Admin anlegen
    echo "pwd1\npwd1" | ftpasswd --passwd --stdin --name admin --uid 9999 --gid 9999 --home /var/www/ftp --shell /bin/false && \
# FTP FHEM-User anlegen
    echo "pwd2\npwd2" | ftpasswd --passwd --stdin --name fhem --uid 9999 --gid 9999 --home /var/www/ftp/fhem --shell /bin/false && \
# FTP Camera-User anlegen
    echo "pwd3\npwd3" | ftpasswd --passwd --stdin --name camera --uid 9999 --gid 9999 --home /var/www/ftp/camera --shell /bin/false

############################################################################
# Samba-Server einrichten
############################################################################

# Samba Config kopieren
COPY data/config/smb/smb-custom.conf /etc/samba/smb.conf

# Samba User Gruppe anlegen
RUN groupadd smbuser && \
# "Kodi" System-User erstellen
    adduser kodi --home /var/www/smb/kodi/ --ingroup smbuser --disabled-password --shell /bin/false --gecos "" && \
#    adduser kodi --no-create-home --ingroup smbuser --disabled-login --disabled-password --shell /bin/false --gecos "" && \
    echo "kodi:pwd" | chpasswd && \
    chown -R kodi:smbuser /var/www/smb/kodi/ && \
# "Kodi" Samba-User erstellen
    echo "pwd\npwd" | smbpasswd -s -a kodi

# Kodi Dateien kopieren
COPY data/smb/kodi/ /var/www/smb/kodi/
RUN chown -R kodi:smbuser /var/www/smb/kodi/

# Public User erstellen & Rechte vergeben
# chmod 777 /var/www/smb/public/

############################################################################
# Daemon zur Erkennung neuer Dateien einrichen
############################################################################

# Script zum Erkennen neuer Dateien kopieren (camerawatch.sh)
COPY data/scripte/camerawatch.sh /scripte/camerawatch.sh

# Daemon-Script kopieren (/etc/init.d/camerawatch)
COPY data/scripte/init.d/camerawatch /etc/init.d/camerawatch

# Rechte von kopierten Scripten ändern
RUN chmod 755 /scripte/camerawatch.sh && \
    chmod 755 /etc/init.d/camerawatch && \
# Daemon mit update-rc.d bekannt machen
    update-rc.d camerawatch defaults

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Start-Script
############################################################################

COPY entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh