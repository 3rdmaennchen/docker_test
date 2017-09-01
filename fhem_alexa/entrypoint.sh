#!/bin/bash

# Bestehende SSL Zertifikate nutzen
#ln -s /ssl/live/erdmann-nas.myds.me/privkey.pem /alexa-fhem/privkey.pem && \
#ln -s /ssl/live/erdmann-nas.myds.me/cert.pem /alexa-fhem/cert.pem && \

echo "Warte 20s ..." && \
sleep 20s && \
echo "Starte Alexa" && \
/alexa-fhem/bin/alexa