versions = php80 php81 php83 php83 php84
directories = $(foreach version,$(versions),$(version)/fpm)

dockerimage = srcoder/development-php
version = 
dockertag = $(version)-fpm

dockerfiles = $(foreach directory,$(directories),$(directory)/Dockerfile)
phpfpmfiles = $(foreach directory,$(directories),$(directory)/conf/zz-srcoder.conf)
phpinifiles = $(foreach directory,$(directories),$(directory)/conf/php.ini)

allfiles = $(dockerfiles) $(phpfpmfiles) $(phpinifiles)

# PHP MODULES and CONFIGURATIONS PARAMETERS
PECL_EXTENSIONS = xdebug redis apcu
DOCKER_EXT_INSTALL = bcmath mysqli pdo_mysql soap zip intl opcache xsl pcntl sockets exif
DOCKER_EXT_CONFIGURE = gd --with-freetype --with-jpeg --with-webp
DOCKER_EXT_CONFIGURE_INSTALL = gd

DOCKER_CMD=podman

all: $(allfiles)
	@echo Created all files

.PHONY: clean
clean:
	rm $(allfiles)

.PHONY: build
build: all
	for version in $(versions); do \
		$(MAKE) build-version version="$${version}"; \
	done

.PHONY: images
images:
	$(DOCKER_CMD) images | grep $(dockerimage)

.PHONY: build-version
build-version:
ifeq ($(strip $(version)),)
	$(error Provide version variable)
endif
	cd $(version)/fpm \
		&& $(DOCKER_CMD) build --tag "$(dockerimage):$(dockertag)" .

php%: version = $(shell echo $@ | sed -e 's#/.*##' -e 's/php\([0-9]\)\([0-9]\)/\1.\2-fpm/')

php%/fpm/Dockerfile: base/Dockerfile
	@mkdir -p $(shell dirname $@)
	cp base/Dockerfile $@
	sed -e 's/%%PHP_VERSION%%/$(version)/' -i $@
	sed -e 's/%%PECL_EXTENSIONS%%/$(PECL_EXTENSIONS)/' -i $@
	sed -e 's/%%DOCKER_EXT_INSTALL%%/$(DOCKER_EXT_INSTALL)/' -i $@
	sed -e 's/%%DOCKER_EXT_CONFIGURE%%/$(DOCKER_EXT_CONFIGURE)/' -i $@
	sed -e 's/%%DOCKER_EXT_CONFIGURE_INSTALL%%/$(DOCKER_EXT_CONFIGURE_INSTALL)/' -i $@

php72/fpm/Dockerfile php73/fpm/Dockerfile:
	sed -e 's# --with-freetype --with-jpeg --with-webp# --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/#' -i $@

php%/fpm/conf/php.ini: base/conf/php.ini
	@mkdir -p $(shell dirname $@)
	cp base/conf/php.ini $@

php%/fpm/conf/zz-srcoder.conf: base/conf/zz-srcoder.conf
	@mkdir -p $(shell dirname $@)
	cp base/conf/zz-srcoder.conf $@

