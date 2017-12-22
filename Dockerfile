FROM ubuntu:16.04

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_GB.UTF-8
# Update base image
# Add sources for latest nginx
# Install software requirements
RUN apt-get update && \
apt-get install -y software-properties-common language-pack-en && \
add-apt-repository -y -u ppa:ondrej/php && \
nginx=stable && \
add-apt-repository ppa:nginx/$nginx && \
apt-get update && \
apt-get upgrade -y && \
BUILD_PACKAGES="wget vim supervisor nginx php7.2-fpm git php7.2-mysql php7.2-curl php7.2-gd php7.2-intl php7.2-mcrypt php7.2-sqlite php7.2-tidy php7.2-xmlrpc php7.2-xsl php7.2-pgsql php7.2-ldap pwgen unzip php7.2-zip curl php-mbstring php-mongodb cron" && \
apt-get -y install $BUILD_PACKAGES && \
curl -sS https://getcomposer.org/installer -o composer-setup.php && \
php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
apt-get remove --purge -y software-properties-common && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_*

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.2/fpm/php.ini && \
sed -i -e "s/max_input_time\s*=\s*60/max_input_time = 300/g" /etc/php/7.2/fpm/php.ini && \
sed -i -e "s/max_execution_time\s*=\s*30/max_execution_time = 300/g" /etc/php/7.2/fpm/php.ini && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.2/fpm/php.ini && \
sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 256M/g" /etc/php/7.2/fpm/php.ini && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.2/fpm/php.ini && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_children = 5/pm.max_children = 30/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 14/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 10/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 18/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -e 's/;clear_env = no/clear_env = no/' -i /etc/php/7.2/fpm/pool.d/www.conf

# fix ownership of sock file for php-fpm
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.2/fpm/pool.d/www.conf && \
find /etc/php/7.2/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# mycrypt conf
RUN phpenmod mcrypt

# nginx site conf
RUN rm -Rf /etc/nginx/conf.d/* && \
rm -Rf /etc/nginx/sites-available/default && \
rm -Rf /etc/nginx/sites-enabled/default && \
mkdir -p /etc/nginx/ssl/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default
ADD conf/nginx.conf /etc/nginx/nginx.conf
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Supervisor Config
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Fix socket file
RUN mkdir -p /run/php/ && chown -Rf www-data.www-data /run/php

# Add Supervisord script
ADD scripts/start.sh /start.sh

# Add newrelic
RUN wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - \
  && echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list \
  && apt-get update \
  && apt-get install -y newrelic-php5 \
  && newrelic-install install \
  && rm -rf /var/lib/apt/lists/*
ADD conf/newrelic.ini /etc/php/7.2/fpm/conf.d/newrelic.ini

RUN chmod 755 /start.sh

