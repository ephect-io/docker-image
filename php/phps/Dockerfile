# --------------------------------------------------------------------
# Build arguments
# --------------------------------------------------------------------
ARG PHP_VERSION=8.3.4

# ====================================================================
# == Stage 1 — Dependencies for building PHP ZTS and NTS
# ====================================================================
FROM ubuntu:24.04 AS build-base

ARG PHP_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf bison re2c pkg-config \
    libxml2-dev libssl-dev libsqlite3-dev libcurl4-openssl-dev \
    libonig-dev libzip-dev libpcre2-dev git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

# Download PHP source
RUN curl -fsSL https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz \
    | tar xz

# ====================================================================
# == Stage 2 — Build PHP ZTS (CLI) + Xdebug ZTS
# ====================================================================
FROM build-base AS build-zts

ARG PHP_VERSION

WORKDIR /usr/src/php-${PHP_VERSION}

RUN ./configure \
    --prefix=/usr/local/php-zts \
    --enable-zts \
    --enable-cli \
    --disable-cgi \
    --with-openssl \
    --with-curl \
    --with-pdo-mysql \
    --with-pdo-sqlite \
    --enable-mbstring \
    --enable-opcache \
    && make -j$(nproc) && make install

# Build Xdebug in ZTS mode
RUN git clone https://github.com/xdebug/xdebug.git /usr/src/xdebug && \
    cd /usr/src/xdebug && \
    /usr/local/php-zts/bin/phpize && \
    ./configure --enable-xdebug \
        --with-php-config=/usr/local/php-zts/bin/php-config && \
    make -j$(nproc) && make install

# ====================================================================
# == Stage 3 — Build PHP NTS (FPM) + OPCache
# ====================================================================
FROM build-base AS build-nts

ARG PHP_VERSION

WORKDIR /usr/src/php-${PHP_VERSION}

RUN ./configure \
    --prefix=/usr/local/php-nts \
    --disable-zts \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --with-openssl \
    --with-curl \
    --with-pdo-mysql \
    --with-pdo-sqlite \
    --enable-mbstring \
    --enable-opcache \
    && make -j$(nproc) && make install

# ====================================================================
# == Stage 4 — Final image with both PHP builds
# ====================================================================
FROM ubuntu:24.04 AS final

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2 libssl3 libsqlite3-0 libcurl4 libonig5 libzip4 \
    && rm -rf /var/lib/apt/lists/*

# Copy ZTS and NTS builds
COPY --from=build-zts /usr/local/php-zts /usr/local/php-zts
COPY --from=build-nts /usr/local/php-nts /usr/local/php-nts

# Provide command shortcuts
RUN ln -s /usr/local/php-zts/bin/php /usr/local/bin/phps && \
    ln -s /usr/local/php-nts/bin/php /usr/local/bin/php && \
    ln -s /usr/local/php-nts/sbin/php-fpm /usr/local/sbin/php-fpm

# Config folders
RUN mkdir -p /usr/local/php-zts/etc/conf.d \
             /usr/local/php-nts/etc/conf.d \
             /var/log/php

# Default config: OPcache for NTS
RUN printf "zend_extension=opcache.so\nopcache.enable=1\n" \
    > /usr/local/php-nts/etc/conf.d/opcache.ini

# Default config: Xdebug for ZTS
RUN printf "zend_extension=xdebug.so\nxdebug.mode=debug\n" \
    > /usr/local/php-zts/etc/conf.d/xdebug.ini

EXPOSE 9000

CMD ["php-fpm"]
