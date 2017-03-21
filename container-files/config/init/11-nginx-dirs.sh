#!/bin/sh

#
# This script will be placed in /config/init/ and run when container starts.
# It creates (if they're not exist yet) necessary directories
# from where custom Nginx configs can be loaded (from mounted /data volumes).
#

set -e

WEB_DIR='/data'
CONF_DIR=${WEB_DIR}/conf/nginx

if [ -d ${CONF_DIR} ]
then
  echo 'nginx conf existed'
else
  mkdir -p ${CONF_DIR}
  cp -r /src/nginx-conf/* ${CONF_DIR}

  # change process num
  CPU_NUM=`cat /proc/cpuinfo |grep "processor"|sort -u|wc -l`
  sed -i 's/^worker_processes.*/worker_processes '${CPU_NUM}';/' ${CONF_DIR}/nginx.conf
fi

mkdir -p ${WEB_DIR}/logs/nginx-access
chmod 711 ${CONF_DIR} ${WEB_DIR}/logs/nginx-access

mkdir -p ${WEB_DIR}/tmp/nginx/client_temp
mkdir -p ${WEB_DIR}/tmp/nginx/proxy_temp
chmod 711 ${WEB_DIR}/tmp/nginx

mkdir -p ${WEB_DIR}/www
mkdir -p ${WEB_DIR}/www/default
cp /etc/nginx/html/index.html ${WEB_DIR}/www/default
chown -R www-data:www-data ${WEB_DIR}/www ${WEB_DIR}/logs
