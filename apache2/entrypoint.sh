#!/bin/bash -x

# SSL-Zertifikate mit letsencrypt erneuern
echo "SSL-Zertifikate werden erneuert" &&
/opt/letsencrypt/letsencrypt-auto renew

# Wartezeit bis SSL-Zertifikate erneuert wurden
echo "Warte 15s" && \
sleep 15s

# fail2ban starten ?

# FTP Starten ?

# Daemon (Script) zum Erkennen neuer Dateien (z.B. IP-Kamera) starten

# Apache Starten
echo "Starte apache2" &&
/usr/sbin/apache2ctl -D FOREGROUND
