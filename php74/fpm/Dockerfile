FROM docker.io/library/php:7.4-fpm
LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install extensions
RUN install-php-extensions bcmath ftp mysqli pdo_mysql soap zip intl opcache xsl pcntl sockets exif redis apcu gd blackfire xdebug

RUN apt-get update --fix-missing && apt-get install -y \
    msmtp \
    libmagickwand-dev imagemagick \
    wget \
    unzip \
    ssh-client git \
    vim \
    && rm -rf /var/lib/apt/lists/*

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

# Enable debug extension
RUN echo "blackfire.agent_socket=tcp://blackfire:8307" > $PHP_INI_DIR/conf.d/blackfire.ini

# Install Magerun
RUN curl https://files.magerun.net/n98-magerun.phar > /usr/local/bin/n98-magerun \
    && chmod +x /usr/local/bin/n98-magerun \
    && ln -s /usr/local/bin/n98-magerun /usr/local/bin/magerun

# Install Magerun2
RUN curl https://files.magerun.net/n98-magerun2.phar > /usr/local/bin/n98-magerun2 \
    && chmod +x /usr/local/bin/n98-magerun2 \
    && ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/magerun2

# Install composer
RUN curl -sS https://getcomposer.org/installer --output composer-setup.php \
    && for version in 1 2; \
        do php composer-setup.php "--$version" --install-dir=/usr/local/bin --filename="composer$version"; \
        chmod ugo+rx /usr/local/bin/"composer$version"; \
    done \
    && ln -s /usr/local/bin/composer2 /usr/local/bin/composer \
    && rm composer-setup.php

# Copy config files
COPY conf/zz-srcoder.conf /usr/local/etc/php-fpm.d/zz-srcoder.conf
COPY conf/php.ini /usr/local/etc/php/

# Enable PHP cli
RUN chmod ugo+rX -R /usr/local/etc/php

# Add user and group
RUN groupadd -g 1000 app && \
    useradd -g 1000 -u 1000 -d /data -s /bin/bash app

WORKDIR /data
