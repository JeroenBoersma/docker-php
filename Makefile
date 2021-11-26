versions = php72 php73 php74 php80 php81
directories = $(foreach version,$(versions),$(version)/fpm)

dockerimage = srcoder/development-php
version = 
dockertag = $(version)-fpm

dockerfiles = $(foreach directory,$(directories),$(directory)/Dockerfile)
phpfpmfiles = $(foreach directory,$(directories),$(directory)/conf/php-fpm.conf)
phpinifiles = $(foreach directory,$(directories),$(directory)/conf/php.ini)

allfiles = $(dockerfiles) $(phpfpmfiles) $(phpinifiles)

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
	docker images | grep $(dockerimage)

.PHONY: build-version
build-version:
ifeq ($(strip $(version)),)
	$(error Provide version variable)
endif
	cd $(version)/fpm \
		&& docker build --tag "$(dockerimage):$(dockertag)" .

php%: version = $(shell echo $@ | sed -e 's#/.*##' -e 's/php\([0-9]\)\([0-9]\)/\1.\2-fpm/')
php81/fpm/Dockerfile: version = 8.1-rc-fpm

php%/fpm/Dockerfile: base/Dockerfile
	@mkdir -p $(shell dirname $@)
	cp base/Dockerfile $@
	sed -e 's/%%PHP_VERSION%%/$(version)/' -i $@

php%/fpm/conf/php.ini: base/conf/php.ini
	@mkdir -p $(shell dirname $@)
	cp base/conf/php.ini $@

php%/fpm/conf/php-fpm.conf: base/conf/php-fpm.conf
	@mkdir -p $(shell dirname $@)
	cp base/conf/php-fpm.conf $@
