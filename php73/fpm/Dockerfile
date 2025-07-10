FROM docker.io/library/php:7.3-fpm
LABEL maintainer="Jeroen Boersma <jeroen@srcode.nl>"

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install system dependencies for building ImageMagick and lib-vips
RUN apt-get update --fix-missing \
    && apt-get install -y \
        ssh-client git vim wget unzip msmtp \
        build-essential pkg-config \
        libpng-dev libjpeg-dev libwebp-dev libtiff-dev libgif-dev \
        libfreetype6-dev libfontconfig1-dev \
        libxml2-dev libxslt1-dev \
        liblcms2-dev libraw-dev \
        libheif-dev libde265-dev \
        libopenjp2-7-dev \
        libfftw3-dev \
        libexpat1-dev \
        libglib2.0-dev \
        libgsf-1-dev \
        liborc-0.4-dev \
        libtool \
        gobject-introspection \
        libgirepository1.0-dev \
        meson \
        ninja-build \
        cmake \
        libaom-dev \
        libdav1d-dev \
        libavif-dev \
    && rm -rf /var/lib/apt/lists/*

# Build and install latest ImageMagick from source
ARG IMAGEMAGICK_VERSION=7.1.1-39
RUN cd /tmp \
    && wget https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGEMAGICK_VERSION}.tar.gz \
    && tar -xzf ${IMAGEMAGICK_VERSION}.tar.gz \
    && cd ImageMagick-${IMAGEMAGICK_VERSION} \
    && ./configure \
        --with-modules \
        --with-quantum-depth=16 \
        --with-heic=yes \
        --with-webp=yes \
        --with-openjp2=yes \
        --with-raw=yes \
        --with-png=yes \
        --with-jpeg=yes \
        --with-tiff=yes \
        --with-freetype=yes \
        --with-fontconfig=yes \
        --with-xml=yes \
        --with-lcms=yes \
        --with-fftw=yes \
        --with-avif=yes \
        --enable-shared \
        --disable-static \
        --without-perl \
        --without-magick-plus-plus \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/ImageMagick-*

# Build and install latest lib-vips from source
ARG LIBVIPS_VERSION=8.15.5
RUN cd /tmp \
    && wget https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.xz \
    && tar -xf vips-${LIBVIPS_VERSION}.tar.xz \
    && cd vips-${LIBVIPS_VERSION} \
    && meson setup build \
        --buildtype=release \
        --prefix=/usr/local \
        -Dintrospection=enabled \
        -Dmodules=enabled \
        -Dcplusplus=false \
        -Ddeprecated=false \
    && cd build \
    && ninja \
    && ninja install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/vips-*

# Install PHP extensions (including imagick and vips)
RUN chmod 0755 /usr/local/bin/install-php-extensions && \
    install-php-extensions bcmath ftp mysqli pdo_mysql soap zip intl opcache xsl pcntl sockets exif redis apcu gd blackfire xdebug imagick vips

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
