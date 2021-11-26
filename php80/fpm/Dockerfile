FROM php:8.0-fpm
LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

RUN apt-get update --fix-missing && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libwebp-dev \
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

# Install imagick
RUN cd /tmp \
    && git clone https://github.com/Imagick/imagick \
    && cd imagick \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/imagick

RUN docker-php-ext-install bcmath mysqli pdo_mysql soap zip intl opcache xsl pcntl sockets exif \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

# Install PECL extensions
RUN pecl install xdebug redis apcu \
    && docker-php-ext-enable xdebug redis apcu \
    && rm -rf /tmp/pear

# Install blackfire agent
RUN export VERSION=`php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` \
    && (curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${VERSION} \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so `php -r "echo ini_get('extension_dir');"`/blackfire.so \
    && docker-php-ext-enable blackfire \
    && rm /tmp/blackfire* || true)

# Enable debug extension
RUN echo "blackfire.agent_socket=tcp://blackfire:8307" > $PHP_INI_DIR/conf.d/blackfire.ini

# Install Magerun
RUN wget -nv https://files.magerun.net/n98-magerun.phar -O /usr/local/bin/n98-magerun \
    && chmod +x /usr/local/bin/n98-magerun \
    && ln -s /usr/local/bin/n98-magerun /usr/local/bin/magerun

# Install Magerun2
RUN wget -nv https://files.magerun.net/n98-magerun2.phar -O /usr/local/bin/n98-magerun2 \
    && chmod +x /usr/local/bin/n98-magerun2 \
    && ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/magerun2

# Install composer
RUN curl -sS https://getcomposer.org/installer --output composer-setup.php \
    && for version in 1 2; \
        do php composer-setup.php "--$version" --install-dir=/usr/local/bin --filename="composer$version"; \
        chmod ugo+rx /usr/local/bin/"composer$version"; \
    done \
    && ln -s /usr/local/bin/composer1 /usr/local/bin/composer \
    && rm composer-setup.php

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
