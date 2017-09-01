############################################################################
# TVHEADEND MIT OSCAM
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

# Don't install sundtek driver on your host. (Privileged regelt?)

# TVheadend Volume vorher sichern

# Kopiere Container:Volume Zielordner
# docker cp tvheadend:/config /home/ich/docker/tvheadend/data/
# docker cp tvheadend:/recordings /home/ich/docker/tvheadend/data/

# Config Packen
# cd /home/ich/docker/tvheadend/data/config/
# tar -C /home/ich/docker/tvheadend/data/config/ -cvJf /home/ich/docker/tvheadend/data/config.tar.xz .

# Config Entpacken
# tar -xvJf /home/ich/docker/tvheadend/data/test/config.tar.xz -C /home/ich/docker/tvheadend/data/test

# Container löschen
# docker rm tvheadend

# Image löschen
# docker rmi docker_tvheadend

# Volumes löschen (nicht benuzte)
# docker volume prune

# Container/Image/Volume löschen und docker-compose neu starten
# docker rm tvheadend && docker rmi docker_tvheadend && docker volume prune -f && docker-compose up

############################################################################
# ToDo
#############################################################################

# BackUp-Script für TVheadend volumes erstellen

# Privileged aktiviert
# USB SAT Stick richtig mounten /dev/dvb/adapter*
# Stick wird auf host nicht erkannt (fehlende Treiber)
# Pfad zum Mounten des Stick fehlt

############################################################################
# Benutzdefinierte Parameter
############################################################################

# Timezone
ENV TZ="Europe/Berlin"

# TVheadend Version (master, unstable, testing, or stable)
ENV TVH_REL="stable"
ENV TVH_VER="4.2"

############################################################################
# Laufwerke (docker volume) erstellen
############################################################################

# Dockerfile             Docker volume erstellen
# docker-compose (yml)   Docker volume in container mounten

VOLUME /config /recordings

############################################################################
# Portfreigabe
############################################################################

# Ports:
#  TVheadend
#    HTTP   9981
#    HTSP   9982
#  OSCAM
#    WebUI  8888
#    dvbapi 9000    (deleted)
#    ????   19240   (deleted)
#    ????   15999   (deleted)

EXPOSE 9981 9982 8888

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
apt-get dist-upgrade -y --force-yes

# Standart Pakete installieren
RUN $_install $PACKAGE

# Zeitzone einstellen
RUN echo ${TZ} > /etc/timezone && dpkg-reconfigure tzdata

############################################################################
# TVHeadend mit DVB-S2 Treiber
############################################################################

# Update-Quelle hinzufügen: TVheadend (bintray's GPG key)
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61
RUN echo "deb https://dl.bintray.com/tvheadend/deb jessie ${TVH_REL}-${TVH_VER}" | tee -a /etc/apt/sources.list

# TVheadend installieren
RUN apt-get update && $_install tvheadend

WORKDIR /home/hts/

# Install Sundtek DVB Driver
RUN wget http://www.sundtek.de/media/sundtek_netinst.sh && \
    chmod 777 sundtek_netinst.sh && \
    ./sundtek_netinst.sh -easyvdr

# TVheadend Config/Recordings kopieren
ADD data/config.tar.xz /config
#ADD data/recordings /recordings

# !!! VOLUMES ZUM ERSTEN MAL ERSTELLEN !!!
# TVheadend Config/Recordings erstellen
#RUN mkdir /config && \
#    mkdir /recordings

# Picons kopieren
#ADD data/picon/snp.tar.xz /config/picon/snp
#ADD data/picon/srp.tar.xz /config/picon/srp

# Picon in Container kopieren
# docker cp /home/ich/docker/tvheadend/data/picon/snp.tar.xz tvheadend:/config/picon/snp.tar.xz
# docker cp /home/ich/docker/tvheadend/data/picon/srp.tar.xz tvheadend:/config/picon/srp.tar.xz

# Picons in Container entpacken
# tar -xvJf /config/picon/snp.tar.xz -C /config/picon/
# tar -xvJf /config/picon/srp.tar.xz -C /config/picon/

# Picons-Ordner umbenennen
# cd /config/picon/
# mv snp-full.800x450-760x410.light.on.transparent_2017-08-04--07-25-47/ snp/
# mv srp-full.800x450-760x410.light.on.transparent_2017-08-04--07-25-47/ srp/

# Rechte für Picons-Ordner vergebenS
# chown -R hts:hts /config/picon
# chmod -R 755 /config/picon

# TVheadend Einstellungen
# Picons dem Kanalnamen vorziehen:  true
# Kanallogo Pfad (SNP):             file:///config/picon/snp/%C.png
# Kanallogo Namensschema:           Servicename Picon
# Picon-Pfad (SRP):                 file:///config/picon/srp/
# Picon Namensschema:               Setze den Typ des Dienstes auf 1

# Aufnahme Einstellungen
# /recordings Pfad ändern

# hts User/Gruppe/Homeverzeichnis erstellen
# Gruppen ID    gid: 9981
# User ID       uid: 9981
RUN groupmod -o -g 9981 hts && \
    usermod -o -u 9981 -aG video -d /config hts && \
    install -o hts -g hts -d /config /recordings

# hts User Rechte auf die kopierten Ordner und Unter-Ordner geben
RUN chown -R hts:hts /config && \
    chown -R hts:hts /recordings

############################################################################
# OSCAM
############################################################################

# install build packages
RUN $_install \
    gcc \
    make \
    openssl \
    libssl-dev \
    subversion \
    libusb-1.0

# !!! VOLUMES ZUM ERSTEN MAL ERSTELLEN !!!
# OSCAM Config kopieren /config/oscam/
# RUN mkdir /config/oscam
# WORKDIR /config/oscam
# COPY data/oscam/oscam.conf ./oscam.conf
# COPY data/oscam/oscam.dvbapi ./oscam.dvbapi
# COPY data/oscam/oscam.server ./oscam.server
# COPY data/oscam/oscam.user ./oscam.user

# compile oscam from source
WORKDIR /tmp/oscam-svn
RUN svn checkout http://www.streamboard.tv/svn/oscam/trunk /tmp/oscam-svn && \
    ./config.sh \
    --enable all \
    --disable \
        CARDREADER_DB2COM \
        CARDREADER_INTERNAL \
        CARDREADER_STINGER \
        CARDREADER_STAPI \
        CARDREADER_STAPI5 \
        IPV6SUPPORT \
        LCDSUPPORT \
        LEDSUPPORT \
        READ_SDT_CHARSETS
RUN make \
        OSCAM_BIN=/usr/bin/oscam \
        CONF_DIR=/config/oscam \
        NO_PLUS_TARGET=1 \
        USE_LIBUSB=1

############################################################################
# OSCAM config.sh
############################################################################

#CONFIG_WEBIF
#CONFIG_WEBIF_LIVELOG
#CONFIG_WEBIF_JQUERY
#CONFIG_TOUCH
#CONFIG_WITH_SSL
#CONFIG_HAVE_DVBAPI
#CONFIG_READ_SDT_CHARSETS
#CONFIG_IRDETO_GUESSING
#CONFIG_CS_ANTICASC
#CONFIG_WITH_DEBUG
#CONFIG_MODULE_MONITOR
#CONFIG_WITH_LB
#CONFIG_CS_CACHEEX
#CONFIG_CW_CYCLE_CHECK
#CONFIG_LCDSUPPORT
#CONFIG_LEDSUPPORT
#CONFIG_CLOCKFIX
#CONFIG_IPV6SUPPORT
#CONFIG_MODULE_CAMD33
#CONFIG_MODULE_CAMD35
#CONFIG_MODULE_CAMD35_TCP
#CONFIG_MODULE_NEWCAMD
#CONFIG_MODULE_CCCAM
#CONFIG_MODULE_CCCSHARE
#CONFIG_MODULE_GBOX
#CONFIG_MODULE_RADEGAST
#CONFIG_MODULE_SERIAL
#CONFIG_MODULE_CONSTCW
#CONFIG_MODULE_PANDORA
#CONFIG_MODULE_SCAM
#CONFIG_MODULE_GHTTP
#CONFIG_WITH_CARDREADER
#CONFIG_READER_NAGRA
#CONFIG_READER_IRDETO
#CONFIG_READER_CONAX
#CONFIG_READER_CRYPTOWORKS
#CONFIG_READER_SECA
#CONFIG_READER_VIACCESS
#CONFIG_READER_VIDEOGUARD
#CONFIG_READER_DRE
#CONFIG_READER_TONGFANG
#CONFIG_READER_BULCRYPT
#CONFIG_READER_GRIFFIN
#CONFIG_READER_DGCRYPT
#CARDREADER_PHOENIX
#CARDREADER_INTERNAL
#CARDREADER_SC8IN1
#CARDREADER_MP35
#CARDREADER_SMARGO
#CARDREADER_DB2COM
#CARDREADER_STAPI
#CARDREADER_STAPI5
#CARDREADER_STINGER

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh