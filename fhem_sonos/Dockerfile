############################################################################
# FHEM SONOS
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

# host

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
lirc

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

# Install fhem
RUN wget https://fhem.de/fhem-${FHEM_VERSION}.deb && dpkg -i fhem-${FHEM_VERSION}.deb
RUN userdel fhem

WORKDIR "/opt/fhem"

# Update Config kopieren
COPY /data/fhem.cfg.update ./fhem.cfg

# Config existiert zu diesem Zeitpunkt noch nicht
# fhem.cfg für update ändern (Update und Shutdown)
# RUN echo "define Update notify global:INITIALIZED sleep 2;;update" >> fhem.cfg
# RUN echo "define Shutdown notify global:UPDATE sleep 2;;shutdown" >> fhem.cfg

# FEHM starten zum Updaten (durch notify in fhem.cfg)
RUN perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Portfreigabe
############################################################################

# host

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh