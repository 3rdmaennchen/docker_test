#!/bin/bash

cd /var/www/ftp/camera

mypidfile=/scripte/camerawatch.sh.pid
trap "rm -f '$mypidfile'" 2
echo $$ > "$mypidfile"

inotifywait -m -e create /var/www/ftp/camera |
while true; do
    while read $T path action file; do
        rm -f `ls -td -1 /var/www/ftp/camera** | awk 'NR>50'`
        echo "The file '$file' appeared in directory '$path' via '$action'"
        curl "http://192.168.X.X:8089/fhem?cmd=setreading%20d_NeueDatei%20file%20$file"
    done
done