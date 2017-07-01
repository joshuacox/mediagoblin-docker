#!/bin/bash

nginx
chown -hR mediagoblin:www-data /var/lib/mediagoblin
cd /srv/mediagoblin.example.org/mediagoblin/
if [ ! -f /var/lib/mediagoblin/date-configured.txt ]
  then
    if [ -z ${GOBLIN_USER+x} ]
      then
        echo set GOBLIN_USER
    fi
    if [ -z ${GOBLIN_PASSWORD+x} ]
      then
        echo set GOBLIN_PASSWORD
    fi
    if [ -z ${GOBLIN_EMAIL+x} ]
      then
        echo set GOBLIN_EMAIL
    fi
    sudo -u mediagoblin bin/gmg dbupdate
    sudo -u mediagoblin bin/gmg adduser --username $GOBLIN_USER --password $GOBLIN_PASSWORD --email $GOBLIN_EMAIL
    sudo -u mediagoblin bin/gmg makeadmin $GOBLIN_USER
    sudo -u mediagoblin ./lazyserver.sh --server-name=fcgi fcgi_host=127.0.0.1 fcgi_port=26543
    date -I > /var/lib/mediagoblin/date-configured.txt
fi
