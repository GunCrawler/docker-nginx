#!/bin/bash
set -eu

# Pull down and load config files from S3
if [ -n "${NGINX_CONF_S3_URI-}" ] ; then
  echo "Downloading config files from $NGINX_CONF_S3_URI ..."
  aws s3 sync $NGINX_CONF_S3_URI /data/conf/
fi
if [ -n "${NGINX_SITES_S3_URI-}" ] ; then
  echo "Downloading site files from $NGINX_SITES_S3_URI ..."
  aws s3 sync $NGINX_SITES_S3_URI /data/sites-templates/
fi

render-templates.sh /data/sites-templates /data/sites-enabled
exec $@
