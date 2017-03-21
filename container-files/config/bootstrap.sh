#!/bin/sh

set -e
set -u

# Supervisord default params
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

mkdir -p /data/conf /data/logs /data/tmp
chmod 711 /data/conf /data/logs /data/tmp

if [ "$(ls /config/init/)" ]; then
  for init in /config/init/*.sh; do
    . $init
  done
fi

supervisord -n $SUPERVISOR_PARAMS
