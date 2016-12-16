#!/bin/bash

/uwsgi.sh

/usr/bin/supervisord -n
