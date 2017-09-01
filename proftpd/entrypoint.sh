#!/bin/bash -x

# Samba starten
echo "Starte Samba Server" && \
service samba start

# Daemon zum Erkennen neuer Dateien starten
echo "Starte Camerawatch" && \
service camerawatch start

# FTP Starten
echo "Starte proftpd" && \
exec proftpd --nodaemon
