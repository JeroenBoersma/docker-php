versions = php56 php70 php71 php72 php73 php74 php80 php81 php82 php83 php83 php84
directories = $(foreach version,$(versions),$(version)/fpm)

dockerimage = docker.io/srcoder/development-php
version = 
dockertag = $(version)-fpm

dockerfiles = $(foreach directory,$(directories),$(directory)/Dockerfile)
phpfpmfiles = $(foreach directory,$(directories),$(directory)/conf/zz-srcoder.conf)
phpinifiles = $(foreach directory,$(directories),$(directory)/conf/php.ini)

allfiles = $(dockerfiles) $(phpfpmfiles) $(phpinifiles)

DOCKER_CMD=podman

all: $(allfiles)
	@echo Created all files

.PHONY: clean
clean:
	rm $(allfiles)

.PHONY: build
build: all
	$(MAKE) with CMD=build-version

.PHONY: with
with:
	for version in $(versions); do \
		$(MAKE) $(CMD) version="$${version}"; \
	done
	$(MAKE) $(CMD) version=latest dockertag=latest
	$(MAKE) $(CMD) version=php56 dockertag=php5-fpm
	$(MAKE) $(CMD) version=php70 dockertag=php7-fpm

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

.PHONY: push
push:
	$(MAKE) with CMD=push-version

.PHONY: push-version
push-version:
	$(DOCKER_CMD) push $(dockerimage):$(dockertag) docker://$(dockerimage):$(dockertag)

php%: version = $(shell echo $@ | sed -e 's#/.*##' -e 's/php\([0-9]\)\([0-9]\)\(-rc\)*/\1.\2\3-fpm/')

php%/fpm/Dockerfile: base/Dockerfile
	@mkdir -p $(shell dirname $@)
	cp base/Dockerfile $@
	sed -e 's/%%PHP_VERSION%%/$(version)/' -i $@

php%/fpm/conf/php.ini: base/conf/php.ini
	@mkdir -p $(shell dirname $@)
	cp base/conf/php.ini $@

php%/fpm/conf/zz-srcoder.conf: base/conf/zz-srcoder.conf
	@mkdir -p $(shell dirname $@)
	cp base/conf/zz-srcoder.conf $@

