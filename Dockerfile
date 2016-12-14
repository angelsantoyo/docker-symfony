FROM debian:jessie

MAINTAINER AngelSantoyo <angelsantoyo1980@gmail.com>

# Install dependencies
RUN apt-get update && apt-get install -y locales --no-install-recommends \
      ca-certificates \
      git \
      curl \
      nginx \
      php5 \
      php5-curl \
      php5-fpm \
      php5-intl \
      php5-sqlite \
      php5-pgsql \
      php5-mysql \
      php5-memcache \
      php5-apcu \
      php-twig \
      supervisor \
      vim \
      php5-xdebug \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM & Nginx
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf \
    && echo "opcache.enable=1" >> /etc/php5/mods-available/opcache.ini \
    && echo "opcache.enable_cli=1" >> /etc/php5/mods-available/opcache.ini \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
    && echo "zend_extension=$(find / -name xdebug.so)" > /etc/php5/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php5/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /etc/php5/xdebug.ini \
    && echo "xdebug.remote_port = 9900" >> /etc/php5/xdebug.ini \
    && echo "xdebug.idekey = PHPSTORM" >> /etc/php5/xdebug.ini \
    && echo "xdebug.default_enable=on" >> /etc/php5/xdebug.ini \
    && echo "xdebug.remote_connect_back=on" >> /etc/php5/xdebug.ini \

COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY vhost.conf /etc/nginx/sites-available/default

RUN usermod -u 1000 www-data

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Display version information.
RUN composer --version

VOLUME /var/www
WORKDIR /var/www

EXPOSE 80

COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
CMD ["/usr/bin/supervisord"]
