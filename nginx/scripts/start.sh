#!/bin/bash

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
