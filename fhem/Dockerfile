############################################################################
# FHEM
#############################################################################

# Image und Version
# Debian --> debian:jessie
# RPi    --> resin/rpi-raspbian:latest
# Ubuntu --> ubuntu:latest
FROM debian:jessie

MAINTAINER Stefan Erdmann <ich@welt.com>

############################################################################
# Info
#############################################################################

############################################################################
# ToDo
#############################################################################

############################################################################
# Benutzdefinierte Parameter
############################################################################

# Timezone
ENV TZ="Europe/Berlin"

# FHEM
ENV FHEM_VER 5.8

############################################################################
# Laufwerke (docker volume) erstellen
############################################################################

# Dockerfile             Docker volume erstellen
# docker-compose (yml)   Docker volume in container mounten

# FTP Camera & FHEM
VOLUME /var/www/ftp/camera/ /var/www/ftp/fhem/

############################################################################
# Portfreigabe
############################################################################

# Ports:
#  FHEM
#    http      8083
#    phone     8084    (deleted)
#    tablet    8085    (deleted)
#    WebAPI    8089
#    WebAlexa  8090
#    Telnet    7072

EXPOSE 8083 8089 8090 7072

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

# non-free & contrib Quellen hinzufügen (snmp-mibs-downloader)
RUN sed -i "s/$/ contrib non-free/g" etc/apt/sources.list

# Neue Quellen updaten & Install dependencies
RUN $_update && $_install \
perl \
etherwake \
dfu-programmer \
build-essential \
snmpd \
snmp \
snmp-mibs-downloader \
telnet \
sqlite3 \
samba \
samba-common-bin \
lirc \
avrdude
# geoip-bin

# Install perl packages
RUN $_install \
libavahi-compat-libdnssd-dev \
libalgorithm-merge-perl \
libclass-dbi-mysql-perl \
libclass-isa-perl \
libcommon-sense-perl \
libdatetime-format-strptime-perl \
libdbi-perl \
libdevice-serialport-perl \
libdpkg-perl \
liberror-perl \
libfile-copy-recursive-perl \
libfile-fcntllock-perl \
libio-socket-ip-perl \
libio-socket-ssl-perl \
libjson-perl \
libjson-xs-perl \
libmail-sendmail-perl \
libsocket-perl \
libswitch-perl \
libsys-hostname-long-perl \
libterm-readkey-perl \
libterm-readline-perl-perl \
libwww-perl \
libxml-simple-perl \
libdbd-sqlite3-perl \
libtext-diff-perl \
libsoap-lite-perl \
libxml-parser-lite-perl \
libconvert-base32-perl \
libauthen-oath-perl \
libcrypt-urandom-perl

# Install snmp mibs (NAS Status)
RUN cpan install use Net::SNMP && \
# Install Infrarot Client
    cpan Lirc::Client && \
# FHEM installieren
    wget https://fhem.de/fhem-${FHEM_VER}.deb && dpkg -i fhem-${FHEM_VER}.deb && \
# FHEM-User löschen
    userdel fhem && \
# FTP-Ordner Eigentümer Gruppen für ftpuser zuordnen (gid=9999)
    chgrp -R 9999 /var/www/ftp/ && \
# FTP-Ordner Schreibrechte für Gruppe vergeben
    chmod 775 -R /var/www/ftp

# Verzeichnis wechseln
WORKDIR "/opt/fhem"

# Icon Set herunterladen (leider helle Icons)
# RUN git clone https://github.com/OpenAutomationProject/knx-uf-iconset/ /opt/fhem/www/images/iconset/

# Update Config kopieren
COPY /data/fhem.cfg.update ./fhem.cfg

# Quellen für Update hinzufügen
RUN echo "http://fhem.de/fhemupdate/controls_fhem.txt" >> ./FHEM/controls.txt && \
    echo "https://raw.githubusercontent.com/uniqueck/fhem-abfall/master/controls_fhemabfall.txt" >> ./FHEM/controls.txt && \
    echo "https://raw.githubusercontent.com/knowthelist/fhem-tablet-ui/master/controls_fhemtabletui.txt" >> ./FHEM/controls.txt && \
    echo "https://raw.githubusercontent.com/klein0r/fhem-style-haus-automatisierung/version-2/controls_ha_theme.txt" >> ./FHEM/controls.txt && \
    echo "https://raw.githubusercontent.com/RFD-FHEM/RFFHEM/dev-r33/controls_signalduino.txt" >> ./FHEM/controls.txt && \
# FEHM starten zum Updaten (durch notify in fhem.cfg)
    perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log && \
# SSL-Zertifikate erstellen
    mkdir /opt/fhem/certs && \
    cd /opt/fhem/certs/ && \
    openssl req -new -x509 -nodes -out server-cert.pem -days 3650 -keyout server-key.pem -subj /C=DE/ST=NRW/L=Juelich/O=FHEM/OU=SmartHome/CN=SErdmann/challengePassword=ZQu6zqcH5gGnFjgX && \
# Rechte der SSL-Zertifikate anpassen
    chmod -R 644 /opt/fhem/certs && \
    chmod 711 /opt/fhem/certs && \
    chown -R 999:dialout /opt/fhem/certs

# Config kopieren
COPY /data/fhem.cfg ./fhem.cfg

# Telegram Token hinzufügen
RUN sed -i "/define TelegramBot TelegramBot/ s/$/ 412221859:AAFEdqcceGMmEfSeWUsbDN2GLtEYbRuF6qw/" /opt/fhem/fhem.cfg

# Wetterverlauf gplot kopieren
COPY data/www/gplot/SVG_Wetterverlauf.gplot ./www/gplot/SVG_Wetterverlauf.gplot

# Fernbedienungsspeziefischer Infrarot-Code kopieren
COPY data/lirc/lircd.conf /etc/lirc/lircd.conf

# Hardware Konfiguration kopieren
COPY data/lirc/hardware.conf /etc/lirc/hardware.conf

# Infrarot-Code Konfiguration für FHEM kopieren
COPY data/lirc/lircrc /opt/fhem/lircrc

# Abfallkalender kopieren
COPY data/kal_abfall.ics ./kal_abfall.ics

# Feiertage NRW & Urlaub kopieren
COPY data/FHEM/hol_nrw.holiday ./FHEM/hol_nrw.holiday
COPY data/FHEM/hol_stefan.holiday ./FHEM/hol_stefan.holiday
COPY data/FHEM/hol_maren.holiday ./FHEM/hol_maren.holiday

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Start-Script
############################################################################

COPY entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh