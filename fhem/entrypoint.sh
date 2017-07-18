#!/bin/bash

set -e
cd /opt/fhem
port=7072

echo "Starte Lirc" && \
/etc/init.d/lirc start

sleep 5s

echo "Starte FHEM" && \
perl fhem.pl fhem.cfg | tee /opt/fhem/log/fhem.log