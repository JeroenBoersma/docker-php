VERSIONS = php56 php70 php71 php72 php73 php74 php80 php81 php82 php83 php83 php84 php85

OUTPUT_IMAGE = docker.io/srcoder/development-php
OUTPUT_TAG = $(VERSION)-fpm

PHP_EXTENSIONS := apcu \
	bcmath blackfire \
	exif \
	ftp \
	gd \
	imagick intl \
	mbstring \
	mysqli \
	opcache \
	pcntl pdo_mysql \
	redis \
	soap sockets \
	vips \
	xdebug xsl \
	zip

EXTRA_APT_PACKAGES := ssh-client git vim wget unzip msmtp curl

COMPOSER_VERSION1 := 1-bin
COMPOSER_VERSION2 := 2-bin

VERSION = 

IMAGE = docker.io/library/php
TAG = fpm

FPM_UID = 1000
FPM_GID = 1000
FPM_SHELL = /bin/bash
FPM_HOME = /data
FPM_USER = app

CONTAINER_COMMAND = podman

ifeq ($(VERSION),php56)
	PHP_EXTENSIONS := $(PHP_EXTENSIONS:vips=)
endif

LTS_VERSIONS = 56 70 71
ifneq ($(foreach r,$(LTS_VERSIONS),$(if $(VERSION:php$(r)=),$(r),)),$(LTS_VERSIONS))
	COMPOSER_VERSION2 := lts-bin
endif

all: .gitignore pull build

.PHONY: clean
clean:

# Build images locally
.PHONY: build
build:
	$(MAKE) with CMD=build-version
	$(CONTAINER_COMMAND) tag "$(BUILD_IMAGE):php56-fpm" "$(BUILD_IMAGE):php5-fpm" 
	$(CONTAINER_COMMAND) tag "$(BUILD_IMAGE):php70-fpm" "$(BUILD_IMAGE):php7-fpm" 
	$(CONTAINER_COMMAND) tag "$(BUILD_IMAGE):php85-fpm" "$(BUILD_IMAGE):latest" 

# Push build images upstream
.PHONY: push
push:
	$(MAKE) with CMD=push-version
	$(MAKE) push-version OUTPUT_TAG=php5-fpm
	$(MAKE) push-version OUTPUT_TAG=php7-fpm
	$(MAKE) push-version OUTPUT_TAG=latest

# Pull dependend images
.PHONY: pull
pull:
	$(MAKE) pull-image IMAGE=docker.io/library/alpine:latest
	$(MAKE) pull-image IMAGE=docker.io/composer/composer:1-bin
	$(MAKE) pull-image IMAGE=docker.io/composer/composer:2-bin
	$(MAKE) pull-image IMAGE=docker.io/composer/composer:lts-bin
	$(MAKE) with CMD=pull-image

.PHONY: images
images:
	$(CONTAINER_COMMAND) images | grep $(OUTPUT_IMAGE)

# Run for each version in VERSIONS
.PHONY: with
with:
	$(foreach version,$(VERSIONS),$(MAKE) with-version VERSION=$(version);)

.PHONY: with-version
with-version: TAG = $(shell echo $(VERSION) | sed -e 's#/.*##' -e 's/php\([0-9]\)\([0-9]\)\(-rc\)*/\1.\2\3-fpm/')
with-version:
	$(MAKE) $(CMD) TAG='$(TAG)'

.PHONY: build-version
build-version: Dockerfile
ifeq ($(strip $(VERSION)),)
	$(error Provide VERSION argument)
endif
	$(CONTAINER_COMMAND) build \
		--tag "$(OUTPUT_IMAGE):$(OUTPUT_TAG)" \
		--build-arg IMAGE='$(IMAGE)' \
	       	--build-arg TAG='$(TAG)' \
		--build-arg PHP_EXTENSIONS='$(PHP_EXTENSIONS)' \
		--build-arg EXTRA_APT_PACKAGES='$(EXTRA_APT_PACKAGES)' \
		--build-arg COMPOSER_VERSION1='$(COMPOSER_VERSION1)' \
		--build-arg COMPOSER_VERSION2='$(COMPOSER_VERSION2)' \
		.

.PHONY: push-version
push-version:
	$(CONTAINER_COMMAND) push "$(OUTPUT_IMAGE):$(OUTPUT_TAG)" "docker://$(OUTPUT_IMAGE):$(OUTPUT_TAG)"

.PHONY: pull-image
pull-image:
	$(CONTAINER_COMMAND) pull '$(IMAGE):$(TAG)'

# Files

.gitignore: Makefile
	echo "$${GITIGNORE_CONTENTS}" > $@

export DOCKERFILE_CONTENTS
Dockerfile: Makefile conf/zz-srcoder.conf conf/php.ini
	echo "$${DOCKERFILE_CONTENTS}" > $@

export FPM_ZZ_SRCODER_CONF_CONTENTS
conf/zz-srcoder.conf: Makefile
	echo "$${FPM_ZZ_SRCODER_CONF_CONTENTS}"	> $@

export FPM_PHP_INI_CONTENTS
conf/php.ini: Makefile
	echo "$${FPM_PHP_INI_CONTENTS}" > $@

# Contents

define GITIGNORE_CONTENTS
/.*
/Dockerfile
/conf/

endef


define DOCKERFILE_CONTENTS

ARG IMAGE=docker.io/library/php
ARG TAG=8.5-fpm

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
FROM $${IMAGE}:$${TAG}

LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

COPY --from=downloads /install-php-extensions /usr/local/bin/

# Install extensions
ARG PHP_EXTENSIONS
RUN install-php-extensions \
    	$${PHP_EXTENSIONS}

# add internal useful tools
ARG EXTRA_APT_PACKAGES=git vim wget unzip curl
RUN apt-get update --fix-missing \
    && apt-get install -y $${EXTRA_APT_PACKAGES} \
    && rm -rf /var/lib/apt/lists/*

# Enable blackfire debug extension
RUN echo $${PHP_EXTENSIONS} | grep blackfire && echo "blackfire.agent_socket=tcp://blackfire:8307" > $$PHP_INI_DIR/conf.d/blackfire.ini

COPY --from=downloads /n98-magerun1 /usr/local/bin/
COPY --from=downloads /n98-magerun2 /usr/local/bin/

RUN ln -s /usr/local/bin/n98-magerun1 /usr/local/bin/n98-magerun \
	&& ln -s /usr/local/bin/n98-magerun1 /usr/local/bin/magerun \
	&& ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/magerun2

# Install composer
ARG COMPOSER_VERSION1=1-bin
ARG COMPOSER_VERSION2=2-bin

COPY --from=docker.io/composer/composer:$${COMPOSER_VERSION1} /composer /usr/local/bin/composer1
COPY --from=docker.io/composer/composer:$${COMPOSER_VERSION2} /composer /usr/local/bin/composer2

RUN ln -s /usr/local/bin/composer2 /usr/local/bin/composer

# Copy config files
COPY conf/zz-srcoder.conf /usr/local/etc/php-fpm.d/zz-srcoder.conf
COPY conf/php.ini /usr/local/etc/php/

# Enable PHP cli
RUN chmod ugo+rX -R /usr/local/etc/php

# Add user and group
ARG UID=$(FPM_UID)
ARG GID=$(FPM_GID)
ARG USER=$(FPM_USER)
ARG HOME=$(FPM_HOME)
ARG SHELL=$(FPM_SHELL)

RUN groupadd -g $${UID} $${USER} && \
    useradd -g $${UID} -u $${GID} -d $${HOME} -s $${SHELL} $${USER}

WORKDIR $${HOME}

endef

define FPM_ZZ_SRCODER_CONF_CONTENTS
[www]

user = $(FPM_USER)
group = $(FPM_USER)

; increase processes
pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.max_requests = 1000

endef

define FPM_PHP_INI_CONTENTS
sendmail_path = "/usr/bin/msmtp --host=mailcatch --port=1025 -f app@fpm.dev -t "

upload_max_filesize = 64M
memory_limit = 1024M
log_errors = 1
error_reporting = E_ALL
max_input_vars = 10000

xdebug.client_host = 172.17.0.1
xdebug.discover_client_host = true
xdebug.max_nesting_level = 1024
xdebug.mode=coverage,debug,develop

endef

