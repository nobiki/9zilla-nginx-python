#!/bin/bash

if [ ! -e /bootstrap.lock ]; then
  /uwsgi.sh

  touch /bootstrap.lock
fi

/usr/bin/supervisord -n
