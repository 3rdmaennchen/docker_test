############################################################################
# Alexa FHEM
#############################################################################

# Image und Version
# [IMG]:[IMG_VER]

# Debian --> debian:jessie
# RPi    --> resin/rpi-raspbian:latest
# Ubuntu --> ubuntu:latest

FROM debian:jessie

MAINTAINER Erdmaennchen <ich@welt.com>

############################################################################
# Benutzdefinierte Parameter
############################################################################

# Zeitzone
ENV TZ="Europe/Berlin"

# Alexa FHEM
# Aktuellste Version von alexa-fhem herunterladen unter und Versions anpassen
# https://forum.fhem.de/index.php/topic,60244.msg540117.html#msg540117

ENV ALEXA_VER="0.3.4"

############################################################################
# Laufwerke (docker volume) erstellen
############################################################################

# Dockerfile             Docker volume erstellen
# docker-compose (yml)   Docker volume in container mounten

# SSL-Zertifikate
VOLUME /etc/letsencrypt

############################################################################
# Portfreigabe
############################################################################

# Ports:
#  Alexa FHEM
#    WEB-HTTP   3000

EXPOSE 3000

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
ARG _clean="cd / rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
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
# Alexa FHEM installieren
############################################################################

# Pakete installieren
RUN $_install \
    npm \
    nodejs-legacy \
    curl

# npm install
RUN npm cache clean -f && \
    npm install -g n && \
    n stable

# Aktuellste Alexa-FHEM Version entpacken
ADD data/prog/alexa-fhem-${ALEXA_VER}.tgz /

# Entpacken "package" Ordner in "alexa-fhem" umbenennen und Alexa-FHEM installieren
RUN mv package alexa-fhem && \
    cd alexa-fhem && \
    npm install

# Config Kopieren
COPY data/config/config.json /config/config.json

# Ordner erstellen und SimLinks für config.json erstellen
RUN mkdir /etc/letsencrypt && \
    mkdir ~/.alexa && \
    ln -s /config/config.json ~/.alexa/config.json

############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Start-Script
############################################################################

COPY entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh