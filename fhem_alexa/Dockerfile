############################################################################
# UNDER CONSTRUCTION
# Alexa FHEM
#############################################################################
# Image und Version
# [IMG]:[IMG_VER]

# Debian --> debian:jessie
# RPi    --> resin/rpi-raspbian:latest
# Ubuntu --> ubuntu:latest
FROM debian:jessie

MAINTAINER Erdmaennchen <ich@welt.com>

# Zeitzone
ENV TIME Europe/Berlin

############################################################################
# Benutzdefinierte Parameter
############################################################################
# NodeJs Version
ENV NODE_VER 6.11.0
ENV NODE_ENV production

############################################################################
# Develepor Parameter
############################################################################

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ENV _remove ="rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
ENV _clean  ="eval apt-get clean && $_remove"
ENV _update ="apt-get update && apt-get upgrade -y --force-yes && $_clean"

############################################################################
# Image erstellen und update
############################################################################

# Updates & Dist-Upgrades installieren
RUN $_update
RUN apt-get dist-upgrade -y --force-yes && \
apt-get install -y --force-yes --no-install-recommends apt-utils

############################################################################
# Standart Pakete installieren
############################################################################

RUN apt-get -y --force-yes install \
sudo \
nano \
wget \
git-core \
curl \
apt-transport-https \
openssh-server \
locales \
net-tools

############################################################################
# Sprache und Zeitzone einrichten
############################################################################

# Zeitzone einstellen
RUN echo $TIME > /etc/timezone && dpkg-reconfigure tzdata

# Sprache umstellen (Tastatur Layout und Country Code)
RUN dpkg-reconfigure locales && locale-gen $LANG && /usr/sbin/update-locale LANG=$LANG

############################################################################
# Spezielle Pakete installieren
############################################################################

RUN apt-get -y --force-yes install \
xz-utils \
python \
libavahi-compat-libdnssd-dev

# CleanUp
RUN $_clean

############################################################################
# Benutzerdefinierter Code
############################################################################

# NodeJS herunterladen und installieren
RUN wget https://nodejs.org/dist/v6.11.0/node-v6.11.0-linux-x64.tar.xz -P /tmp && \
cd /usr/local && \
tar -xvf /tmp/node-v6.11.0-linux-x64.tar.xz --strip=1

RUN ln -s /usr/local/bin/node /usr/bin/node

RUN apt-get install -y --force-yes make make gcc g++

RUN npm install -g homebridge homebridge-fhem homebridge-http

############################################################################
# Updates und CleanUp
############################################################################

# Updates installieren
RUN apt-get update && \
apt-get upgrade -y --force-yes

# CleanUp
RUN $_clean_apt

############################################################################
# Startscript erstellen
############################################################################

#ADD start.sh /start.sh
#RUN chmod +x /start.sh
# oder
#COPY start.sh ./
#CMD bash /opt/fhem/start.sh
# oder ENTRYPOINT ???

# Inhalt start.sh'
# [
# #!/bin/bash
# 
# echo "Starte ..."
# [weiterer Code]
# ]

############################################################################
# Laufwerke bzw. Verzeichnisse mounten
# Unterschied yml???
# VOLUME ["/opt/fhem"]
############################################################################

#VOLUME

#VOLUME start.sh /start.sh

############################################################################
# Portfreigabe
############################################################################

EXPOSE 3000

############################################################################
# Start-Script
############################################################################

ADD entrypoint.sh /entrypoint.sh
CMD bash /entrypoint.sh