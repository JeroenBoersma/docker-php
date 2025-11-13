FROM docker.io/library/php:7.0-fpm
LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

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
	xdebug xsl \
	zip

# add internal useful tools
RUN apt-get update --fix-missing \
    && apt-get install -y ssh-client git vim wget unzip msmtp \
    && rm -rf /var/lib/apt/lists/*


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
