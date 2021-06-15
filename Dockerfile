FROM php:apache-buster

RUN set -eux; \
	  savedAptMark="$(apt-mark showmanual)"; \
	  apt-get update; \
	  apt-get install -y --no-install-recommends \
        zlib1g-dev \
        libwebp-dev \
        libxpm-dev \
        libxml2-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libmagickwand-dev \
        imagemagick \
        libzip-dev \
        libpq-dev \
        ${PHP_EXTRA_BUILD_DEPS:-} ; \
	  rm -rf /var/lib/apt/lists/*; \
    docker-php-ext-configure gd \
        --enable-gd \
        --with-jpeg \
        --with-freetype \
	      --with-gnu-ld \
        --with-xpm \
        --with-freetype \
        --with-webp && \
    docker-php-ext-install -j "$(nproc)" \
        soap \
        exif \
        gd \
        zip \
        intl \
        pdo_mysql \
        tokenizer \
        xml \
        pcntl \
        pgsql \
        pdo_pgsql \
        opcache && \
        pecl channel-update pecl.php.net && \
    printf "\n" | pecl install -o -f \
        swoole \
        redis; \
    docker-php-ext-enable \
        swoole \
        redis && \
    docker-php-source delete && \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
      | awk '/=>/ { print $(NF-1) }' \
      | sort -u \
      | xargs -r dpkg-query --search \
      | cut -d: -f1 \
      | sort -u \
      | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
      pecl update-channels; \
    rm -rf /tmp/pear ~/.pearrc
