FROM php:7.2-fpm
LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

RUN apt-get update --fix-missing && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        msmtp \
        imagemagick \
        libssl-dev \
        libxml2-dev \
        libicu-dev \
        libxslt-dev \
        wget libcurl4-openssl-dev \
        libmagickwand-dev imagemagick \
        libzip-dev \
        unzip \
        ssh-client git vim \
    && rm -rf /var/lib/apt/lists/*

# Install libsodium
RUN mkdir -p /tmp/sodium \
    && cd /tmp/sodium \
    && curl -L 'https://download.libsodium.org/libsodium/releases/LATEST.tar.gz' -o latest.tar.gz \
    && tar xzvf latest.tar.gz \
    && cd libsodium-*/ \
    && ./configure \
    && make && make check \
    && make install \
    && rm -rf /tmp/sodium

RUN docker-php-ext-install bcmath mysqli pdo_mysql soap zip intl opcache xsl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# Install xdebug and redis
RUN pecl install imagick xdebug redis libsodium apcu \
    && docker-php-ext-enable imagick xdebug redis sodium apcu \
    && rm -rf /tmp/pear

# Install blackfire agent
RUN export VERSION=`php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${VERSION} \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so `php -r "echo ini_get('extension_dir');"`/blackfire.so \
    && docker-php-ext-enable blackfire \
    && rm /tmp/blackfire*

# Enable debug extension
RUN echo "blackfire.agent_socket=\${BLACKFIRE_PORT}" > $PHP_INI_DIR/conf.d/blackfire.ini

# Install Magerun
RUN wget -nv https://files.magerun.net/n98-magerun.phar -O /usr/local/bin/n98-magerun \
    && chmod +x /usr/local/bin/n98-magerun \
    && ln -s /usr/local/bin/n98-magerun /usr/local/bin/magerun

# Install Magerun2
RUN wget -nv https://files.magerun.net/n98-magerun2.phar -O /usr/local/bin/n98-magerun2 \
    && chmod +x /usr/local/bin/n98-magerun2 \
    && ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/magerun2

# Install composer
RUN wget -nv https://getcomposer.org/installer -O /tmp/composer-setup.php \
    && php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php

# Copy config files
COPY conf/php-fpm.conf /usr/local/etc/
COPY conf/php.ini /usr/local/etc/php/

# Enable PHP cli
RUN chmod ugo+rX -R /usr/local/etc/php

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=app --with-fpm-group=app

# Add user and group
RUN groupadd -g 1000 app && \
    useradd -g 1000 -u 1000 -d /data -s /bin/bash app

WORKDIR /data

