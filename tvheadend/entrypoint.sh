#!/bin/bash -x

# USB SAT Treiber
echo "Starte DVB-S2 Treiber" &&
/opt/bin/mediaclient --start

# OSCAM -b daemon (background)
echo "Oscam" && \
/usr/bin/oscam -b -c /config/oscam

# Wartezeit bis OSCAM gestartet ist
echo "Warte 30s" && \
sleep 15s

# TVheadend -f daemon (background)
[ "$hts_uid" ] && usermod  -o -u "$hts_uid" hts
[ "$hts_gid" ] && groupmod -o -g "$hts_gid" hts

echo "Starte TVheadend" && \
/usr/bin/tvheadend -C -u hts -g hts -c /config
