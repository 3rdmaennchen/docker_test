############################################################################
# Debian Jessie
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
# Update/Install/Zeitzone
############################################################################

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Build-date:- ${BUILD_DATE}"

# Develepor Commands
ENV _clean="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _apt_clean="eval apt-get clean && $_clean"
ENV _update="eval apt-get update && apt-get upgrade -y --force-yes"
ENV _install="eval apt-get install -y --force-yes"

# Develepor Parameter
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Updates & Dist-Upgrades installieren
RUN $_update && \
apt-get install -y --force-yes --no-install-recommends apt-utils && \
apt-get dist-upgrade -y --force-yes

# Standart Pakete installieren
RUN $_install \
nano \
wget \
git-core \
curl \
apt-transport-https \
usbutils \
net-tools \
tar

# Zeitzone einstellen
RUN echo ${TZ} > /etc/timezone && dpkg-reconfigure tzdata

############################################################################
# Benutzerdefinierter Code
############################################################################







############################################################################
# CleanUp
############################################################################

RUN $_update && $_apt_clean

############################################################################
# Laufwerke (docker volume) erstellen
############################################################################

# Dockerfile    Docker volume erstellen
# yml           Docker volume in container mounten

# VOLUME /my_vol

############################################################################
# Portfreigabe
############################################################################

# EXPOSE 1234

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh