############################################################################
# FHEM
#############################################################################

# Image und Version
# Debian --> debian:jessie
# RPi    --> resin/rpi-raspbian:latest
# Ubuntu --> ubuntu:latest
FROM debian:jessie

MAINTAINER Erdmännchen <ich@welt.com>

############################################################################
# Info
#############################################################################

# Ports:
#  FHEM
#    WEB-HTTP   8083
#    Telnet     7072
#    WEB-HTTPS  8084    (deleted)
#    WEB-HTTPS  8085    (deleted)

############################################################################
# Benutzdefinierte Parameter
############################################################################

# Timezone
ENV TZ="Europe/Berlin"

#F HEM
ENV FHEM_VERSION 5.8

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

# Synology NAS Status überwachen
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
libxml-parser-lite-perl

# Install snmp mibs (NAS Status)
RUN cpan install use Net::SNMP

# Install Infrarot Client
RUN cpan Lirc::Client

# FHEM installieren
RUN wget https://fhem.de/fhem-${FHEM_VERSION}.deb && dpkg -i fhem-${FHEM_VERSION}.deb

# FHEM-User löschen
RUN userdel fhem

# Verzeichnis wechseln
WORKDIR "/opt/fhem"

# Update Config kopieren
COPY /data/fhem.cfg.update ./fhem.cfg

# Quellen für Update hinzufügen
RUN echo "http://fhem.de/fhemupdate/controls_fhem.txt" >> ./FHEM/controls.txt
RUN echo "https://raw.githubusercontent.com/uniqueck/fhem-abfall/master/controls_fhemabfall.txt" >> ./FHEM/controls.txt
RUN echo "https://raw.githubusercontent.com/knowthelist/fhem-tablet-ui/master/controls_fhemtabletui.txt" >> ./FHEM/controls.txt
RUN echo "https://raw.githubusercontent.com/klein0r/fhem-style-haus-automatisierung/version-2/controls_ha_theme.txt" >> ./FHEM/controls.txt
RUN echo "https://raw.githubusercontent.com/RFD-FHEM/RFFHEM/dev-r33/controls_signalduino.txt" >> ./FHEM/controls.txt

# FEHM starten zum Updaten (durch notify in fhem.cfg.update)
RUN perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log

# Abfallkalender kopieren
COPY data/kal_abfall.ics ./kal_abfall.ics

# Fernbedienungsspeziefischer Infrarot-Code kopieren
COPY data/lirc/lircd.conf /etc/lirc/lircd.conf

# Hardware Konfiguration kopieren
COPY data/lirc/hardware.conf /etc/lirc/hardware.conf

# Infrarot-Code Konfiguration für FHEM kopieren
COPY data/lirc/lircrc /opt/fhem/lircrc

# Feiertage NRW & Urlaub kopieren
COPY data/FHEM/hol_nrw.holiday ./FHEM/hol_nrw.holiday

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Portfreigabe
############################################################################

EXPOSE 8083 7072

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh