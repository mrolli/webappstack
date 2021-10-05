#!/usr/bin/env bash

# Where to install wordpress into
documentRoot=/var/www/html

if [ $# -ne 1 ]
then
  echo 'Require IP address as the first arguemnt'
  exit 1
fi

if [ ! -d $documentRoot/wordpress ]
then
  wget https://wordpress.org/latest.tar.gz &>/dev/null
  tar -xf latest.tar.gz --directory $documentRoot
  rm -f latest.tar.gz
fi

echo "Now open http://${1}/wordpress/ in your browser"

exit 0
