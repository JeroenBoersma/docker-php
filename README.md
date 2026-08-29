# docker-php

Docker PHP images used for development.

## Versions
Supported versions + the EOL dates

- 5.6 (EOL 31 Dec 2018)
- 7.0 (EOL 10 Jan 2019)
- 7.1 (EOL 1 Dec 2019)
- 7.2 (EOL 30 Nov 2020)
- 7.3 (EOL 6 Dec 2021)
- 7.4 (EOL 28 Nov 2022)
- 8.0 (EOL 26 Nov 2023)
- 8.1 (EOL 31 Dec 2025)
- 8.2
- 8.3
- 8.4
- 8.5

## Tags
- php56-fpm, php5-fpm
- php70-fpm, php7-fpm
- php71-fpm
- php72-fpm
- php73-fpm
- php74-fpm
- php80-fpm
- php81-fpm
- php82-fpm
- php83-fpm
- php84-fpm
- php85-fpm, latest

## Preinstalled
`bcmath ftp mysqli mbstring pdo_mysql soap zip intl opcache xsl pcntl sockets exif redis apcu gd blackfire xdebug vips`

And
- Imagemagick
- Composer 1/2
- Magerun 1/2

## Building
If you want to build the images yourself locally, go ahead

```shell
# docker
make pull build CONTAINER_COMMAND=docker
# podman
make pull build CONTAINER_COMMAND=podman

```

## Customization
If you want to use a different base image, change tags, add more packages or extensions.

- `IMAGE` & `TAG`: Base image to use to build
- `OUTPUT_IMAGE` & `OUTPUT_TAG`: Output tag
- `PHP_EXTENSIONS`: List of basic extensions to install
- `EXTRA_APT_PACKAGES`: If you want to install some extra packages
- `COMPOSER_VERSION(1|2)`: Set a tag for the composer base images 

```shell
make build-version \
    IMAGE=docker.io/library/php \
    TAG=cli \
    OUTPUT_IMAGE=development \
    OUTPUT_TAG=latest \
    PHP_EXTENSIONS='apcu \
	    bcmath \
	    exif \
	    mbstring \
	    opcache \
	    pdo_mysql \
	    sockets \
	    zip' \
    EXTRA_APT_PACKAGES='git vim curl unzip' \
    COMPOSER_VERSION2=lts-bin

```

## User

Runs as user `1000 - app`.
Use `usermod` and `groupmod` to change the userid.

- `FPM_UID`
- `FPM_GID`
- `FPM_SHELL`
- `FPM_USER`
- `FPM_HOME`

```shell
make -b Dockerfile FPM_*=''
make build ... # see above
```

## Authors

- [Jeroen Boersma](https://github.com/JeroenBoersma)
- [Len Lorijn](https://github.com/lenlorijn)
- [Sander Jongsma](https://github.com/sanderjongsma)
- [Peter Jaap](https://github.com/peterjaap)

## License

MIT
