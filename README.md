# docker-php

Docker PHP images used by docker development.

See https://github.com/JeroenBoersma/docker-compose-development for usage.

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
`bcmath ftp mysqli pdo_mysql soap zip intl opcache xsl pcntl sockets exif redis apcu gd blackfire xdebug`

And
- Imagemagick
- Composer 1/2
- Magerun 1/2

## User

Runs as user `1000 - app`.
Use `usermod` and `groupmod` to change the userid.


## Authors

- [Jeroen Boersma](https://github.com/JeroenBoersma)
- [Len Lorijn](https://github.com/lenlorijn)
- [Sander Jongsma](https://github.com/sanderjongsma)
- [Peter Jaap](https://github.com/peterjaap)

## License

MIT
