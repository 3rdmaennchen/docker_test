#!/bin/bash -x

# SSL-Zertifikate mit letsencrypt erneuern
echo "SSL-Zertifikate werden erneuert" && \
/opt/letsencrypt/letsencrypt-auto renew && \
sleep 5s

# Apache im Vordergrund Starten
echo "Starte apache2" && \
usr/sbin/apache2ctl -D FOREGROUND