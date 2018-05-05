#!/bin/bash


# Set the right permissions (needed when mounting from a volume)
#chown -Rf www-data.www-data /var/www/

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf

exec $@
