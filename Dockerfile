FROM debian:wheezy

MAINTAINER Vincent Chalamon <vincentchalamon@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      curl \
      nginx \
      sqlite3 \
      php5 \
      php5-curl \
      php5-fpm \
      php5-intl \
      php5-sqlite \
      php5-pgsql \
      php5-mysql \
      php5-memcache \
      php-apc \
      supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
    && echo "apc.enabled=1" >> /etc/php5/conf.d/20-apc.ini \
    && echo "apc.stat=1" >> /etc/php5/conf.d/20-apc.ini

COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY vhost.conf /etc/nginx/sites-available/default

RUN usermod -u 1000 www-data

VOLUME /var/www
WORKDIR /var/www

EXPOSE 80

CMD ["/usr/bin/supervisord"]
