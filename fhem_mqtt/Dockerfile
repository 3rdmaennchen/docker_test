############################################################################
# apache2 (ReverseProxy/FTP)
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

# MQTT environment variables
#ENV

############################################################################
# Update/Install/Zeitzone
############################################################################

# Develepor Parameter
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Updates & Dist-Upgrades installieren
RUN apt-get update && apt-get upgrade -y --force-yes
RUN apt-get dist-upgrade -y --force-yes && \
apt-get install -y --force-yes apt-utils

# Standart Pakete installieren
RUN apt-get -y --force-yes install \
sudo \
nano \
wget \
git-core \
curl \
apt-transport-https \
openssh-server \
net-tools \
tar \
xz-utils

# Zeitzone einstellen
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure tzdata

############################################################################
# Benutzerdefinierter Code
############################################################################

############################################################################
# Verzeichnisse Mounten
############################################################################

############################################################################
# CleanUp
############################################################################

RUN apt-get update && apt-get upgrade -y --force-yes
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

############################################################################
# Portfreigabe
############################################################################

EXPOSE 1883

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh