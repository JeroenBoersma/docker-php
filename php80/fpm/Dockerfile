# Download all remote files once, better caching
FROM docker.io/library/alpine as downloads

# Download PHP Extension Installer
RUN wget -O- https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions > /install-php-extensions

# Install Magerun version 1 & 2
RUN wget -O- https://files.magerun.net/n98-magerun.phar > /n98-magerun1
RUN wget -O- https://files.magerun.net/n98-magerun2.phar > /n98-magerun2

# Set permissions
RUN chmod 0755 /install-php-extensions /n98-magerun1 /n98-magerun2

## Build the image
FROM docker.io/library/php:8.0-fpm
LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

COPY --from=downloads /install-php-extensions /usr/local/bin/

# Install extensions
RUN chmod 0755 /usr/local/bin/install-php-extensions && \
    install-php-extensions \
    	apcu \
	bcmath blackfire \
	exif \
	ftp \
	gd \
	imagick intl \
	mysqli \
	opcache \
	pcntl pdo_mysql \
	redis \
	soap sockets \
	vips \
	xdebug xsl \
	zip

# add internal useful tools
RUN apt-get update --fix-missing \
    && apt-get install -y ssh-client git vim wget unzip msmtp \
    && rm -rf /var/lib/apt/lists/*

# Enable debug extension
RUN echo "blackfire.agent_socket=tcp://blackfire:8307" > $PHP_INI_DIR/conf.d/blackfire.ini

COPY --from=downloads /n98-magerun1 /usr/local/bin/
COPY --from=downloads /n98-magerun2 /usr/local/bin/

RUN ln -s /usr/local/bin/n98-magerun1 /usr/local/bin/n98-magerun \
	&& ln -s /usr/local/bin/n98-magerun1 /usr/local/bin/magerun \
	&& ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/magerun2

# Install composer
COPY --from=docker.io/composer/composer:1-bin /composer /usr/local/bin/composer1
COPY --from=docker.io/composer/composer:2-bin /composer /usr/local/bin/composer2

RUN ln -s /usr/local/bin/composer2 /usr/local/bin/composer

# Copy config files
COPY conf/zz-srcoder.conf /usr/local/etc/php-fpm.d/zz-srcoder.conf
COPY conf/php.ini /usr/local/etc/php/

# Enable PHP cli
RUN chmod ugo+rX -R /usr/local/etc/php

# Add user and group
RUN groupadd -g 1000 app && \
    useradd -g 1000 -u 1000 -d /data -s /bin/bash app

WORKDIR /data
