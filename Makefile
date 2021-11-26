versions = php72 php73 php74 php80 php81

dockerfiles = $(foreach version,$(versions),$(version)/fpm/Dockerfile)

phpfpmfiles = $(foreach version,$(versions),$(version)/fpm/conf/php-fpm.conf)
phpinifiles = $(foreach version,$(versions),$(version)/fpm/conf/php.ini)

allfiles = $(dockerfiles) $(phpfpmfiles) $(phpinifiles)

all: $(allfiles)
	@echo Created all files

.PHONY: clean
clean:
	rm $(allfiles)

php%: version = $(shell echo $@ | sed -e 's#/.*##'))

php%/fpm/.:
	mkdir $@

php%/fpm/Dockerfile: php%/fpm base/Dockerfile
	cp base/Dockerfile $@
	sed -e 's/%%PHP_VERSION%%/$(version)/' -e 's/php:php\([0-9]\)\([0-9]\)$$/php:\1.\2-fpm/' -i $@

php%/fpm/conf/.: php%/fpm
	mkdir $@

php%/fpm/conf/php.ini: php%/fpm/conf base/conf/php.ini
	cp base/conf/php.ini $@

php%/fpm/conf/php-fpm.conf: php%/fpm/conf base/conf/php-fpm.conf
	cp base/conf/php-fpm.conf $@

