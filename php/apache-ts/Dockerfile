# --------------------------------------------------------------------
# Build arguments
# --------------------------------------------------------------------
ARG VERSION=8.4.15

# ====================================================================
# == Stage 1 — Dependencies for building PHP ZTS and NTS
# ====================================================================
FROM ubuntu:24.04 AS build-base

ARG VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf bison re2c pkg-config \
    libxml2-dev libssl-dev libsqlite3-dev libpq-dev libcurl4-openssl-dev \
    libonig-dev libzip-dev libpcre2-dev git curl ca-certificates \
    libsodium-dev libreadline-dev libbz2-dev libgmp-dev gettext \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=salamandra
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# OCI Labels pour métadonnées
LABEL org.opencontainers.image.title="PHP ${VERSION} Apache Development Image"
LABEL org.opencontainers.image.description="PHP ${VERSION} with Apache mod_php, Xdebug, Composer, NVM and Node LTS"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.vendor="ephect"
LABEL org.opencontainers.image.authors="David Blanchard"

ENV LOG_FILE="/tmp/build-log.md"

# Create build log
RUN touch ${LOG_FILE}

WORKDIR /usr/src

# Download PHP source
RUN curl -fsSL https://www.php.net/distributions/php-${VERSION}.tar.gz \
    | tar xz

# ====================================================================
# == Stage 2 — Build PHP ZTS (CLI) + Xdebug ZTS
# ====================================================================
FROM build-base AS build-zts

ARG VERSION
ENV SUCCESS="✅"
ENV FAILURE="❌"
ENV STAGE="zts"
ENV LOG_FILE="/tmp/build-log-stage-${STAGE}.md"

WORKDIR /usr/src/php-${VERSION}

RUN ./configure \
    --prefix=/usr/local/zts \
    --enable-zts \
    --enable-cli \
    --disable-cgi \
    --with-openssl \
    --with-curl \
    --with-pdo-mysql \
    --with-pdo-pgsql \
    --with-pdo-sqlite \
    --with-zlib \
    --with-bz2 \
    --with-iconv \
    --with-gmp \
    --with-gettext \
    --with-pear \
    --with-apcu \
    --with-sodium \
    --with-ctype \
    --with-fileinfo \
    --with-readline \
    --enable-mysqlnd \
    --enable-pdo \
    --enable-mbstring \
    --enable-opcache \
    --enable-dom \
    --enable-xml \
    --enable-xmlreader \
    --enable-xmlwriter \
    --enable-simplexml \
    --enable-ftp \
    --enable-filter \
    --enable-tokenizer \
    --enable-session \
    --enable-posix \
    --enable-sockets \
    && make -j$(nproc) && make install

# Xdebug
ENV STEP="Xdebug extension"
RUN (git clone https://github.com/xdebug/xdebug.git /usr/src/xdebug && \
    cd /usr/src/xdebug && \
    /usr/local/zts/bin/phpize && \
    ./configure --enable-xdebug \
        --with-php-config=/usr/local/zts/bin/php-config && \
    make -j$(nproc) && make install \
    && mkdir -p /usr/local/zts/etc/conf.d \
    && echo "zend_extension=$(find /usr/local/zts/lib/php/extensions/ -name xdebug.so)" > /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,coverage,debug" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.client_host=localhost" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.log=/dev/stdout" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && echo "xdebug.log_level=0" >> /usr/local/zts/etc/conf.d/xdebug.ini \
    && rm -rf /tmp/pear \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# Install parallel
ENV STEP="Parallel extension"
RUN (curl -L -O https://github.com/krakjoe/parallel/archive/refs/heads/develop.zip \
    && unzip develop.zip \
    && cd parallel-develop \
    && sed -E "s/ZEND_TYPE_HAS_CLASS/ZEND_TYPE_IS_COMPLEX/" -i src/check.c \
    && /usr/local/zts/bin/phpize \
    && ./configure --enable-parallel --with-php-config=/usr/local/zts/bin/php-config \
    && make \
    && make install \
    && cd .. \
    && rm develop.zip \
    && rm -rf parallel-develop \
    && mkdir -p /usr/local/zts/etc/conf.d \
    && echo "extension=parallel.so" > /usr/local/zts/etc/conf.d/parallel.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# PHP configuration
ENV STEP="PHP configuration"
RUN (mkdir -p /usr/local/zts/etc \
    && echo "display_startup_errors = Off" > /usr/local/zts/etc/php.ini \
    && echo "display_errors = Off" >> /usr/local/zts/etc/php.ini \
    && echo "log_errors = On" >> /usr/local/zts/etc/php.ini \
    && echo "error_log = php_errors.log" >> /usr/local/zts/etc/php.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# Zip extension
ENV STEP="Zip extension"
RUN (apt-get update \
    && apt-get -y install --no-install-recommends libzip-dev \
    && /usr/local/zts/bin/pecl install zip \
    && mkdir -p /usr/local/zts/etc/conf.d \
    && echo "extension=zip.so" > /usr/local/zts/etc/conf.d/zip.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# ====================================================================
# == Stage 3 — Build PHP with Apache mod_php
# ====================================================================
FROM build-base AS build-apache

ARG VERSION
ENV SUCCESS="✅"
ENV FAILURE="❌"
ENV STAGE="nts"
ENV LOG_FILE="/tmp/build-log-stage-${STAGE}.md"

# Install Apache and development files
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 apache2-dev libapr1-dev libaprutil1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/php-${VERSION}

RUN ./configure \
    --prefix=/usr/local/apache-php \
    --with-apxs2=/usr/bin/apxs \
    --with-openssl \
    --with-curl \
    --with-pdo-mysql \
    --with-pdo-pgsql \
    --with-pdo-sqlite \
    --with-zlib \
    --with-bz2 \
    --with-iconv \
    --with-gmp \
    --with-gettext \
    --with-pear \
    --with-apcu \
    --with-sodium \
    --with-ctype \
    --with-fileinfo \
    --with-readline \
    --enable-mysqlnd \
    --enable-pdo \
    --enable-mbstring \
    --enable-opcache \
    --enable-dom \
    --enable-xml \
    --enable-xmlreader \
    --enable-xmlwriter \
    --enable-simplexml \
    --enable-ftp \
    --enable-filter \
    --enable-tokenizer \
    --enable-session \
    --enable-posix \
    --enable-sockets \
    && make -j$(nproc) && make install

# Xdebug
ENV STEP="Xdebug"
RUN (git clone https://github.com/xdebug/xdebug.git /usr/src/xdebug && \
    cd /usr/src/xdebug && \
    /usr/local/apache-php/bin/phpize && \
    ./configure --enable-xdebug \
        --with-php-config=/usr/local/apache-php/bin/php-config && \
    make -j$(nproc) && make install \
    && mkdir -p /usr/local/apache-php/etc/conf.d \
    && echo "zend_extension=$(find /usr/local/apache-php/lib/php/extensions/ -name xdebug.so)" > /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,coverage,debug" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.client_host=localhost" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.log=/dev/stdout" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && echo "xdebug.log_level=0" >> /usr/local/apache-php/etc/conf.d/xdebug.ini \
    && rm -rf /tmp/pear \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# PHP configuration
ENV STEP="PHP configuration"
RUN (mkdir -p /usr/local/apache-php/etc \
    && echo "display_startup_errors = Off" > /usr/local/apache-php/etc/php.ini \
    && echo "display_errors = Off" >> /usr/local/apache-php/etc/php.ini \
    && echo "log_errors = On" >> /usr/local/apache-php/etc/php.ini \
    && echo "error_log = /var/log/php/php_errors.log" >> /usr/local/apache-php/etc/php.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Zip extension
ENV STEP="Zip extension"
RUN (apt-get update \
    && apt-get -y install --no-install-recommends libzip-dev \
    && /usr/local/apache-php/bin/pecl install zip \
    && mkdir -p /usr/local/apache-php/etc/conf.d \
    && echo "extension=zip.so" > /usr/local/apache-php/etc/conf.d/zip.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# ====================================================================
# == Stage 4 — Final image with both PHP builds
# ====================================================================
FROM ubuntu:24.04 AS final

ARG USERNAME=salamandra
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Define build log variables
ENV SUCCESS="✅"
ENV FAILURE="❌"
ENV STAGE="final"
ENV LOG_FILE="/tmp/build-log-stage-${STAGE}.md"

# Install runtime dependencies
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    libxml2 libssl3t64 libsqlite3-0 libcurl4t64 libonig5 libzip4 libpq5 \
    libsodium23 libreadline8t64 libbz2-1.0 libgmp10 \
    apache2 libapr1t64 libaprutil1t64 \
    curl ca-certificates sudo \
    && rm -rf /var/lib/apt/lists/*

# Create build log
RUN touch ${LOG_FILE} && chmod 666 ${LOG_FILE}

# Create user and groups
ENV STEP="User setup"
RUN (groupadd --gid 33 www-data 2>/dev/null || true && \
    (userdel $(getent passwd $USER_UID | cut -d: -f1) 2>/dev/null || true) && \
    (groupdel $(getent group $USER_GID | cut -d: -f1) 2>/dev/null || true) && \
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    usermod -aG www-data $USERNAME && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Copy ZTS and Apache PHP builds
COPY --from=build-zts /usr/local/zts /usr/local/zts
COPY --from=build-apache /usr/local/apache-php /usr/local/apache-php

# Copy build logs from previous stages
COPY --from=build-zts /tmp/build-log-stage-zts.md /tmp/build-log-stage-zts.md
COPY --from=build-apache /tmp/build-log-stage-nts.md /tmp/build-log-stage-nts.md

# Copy Apache module
COPY --from=build-apache /usr/lib/apache2/modules/libphp.so /usr/lib/apache2/modules/

# Provide command shortcuts
RUN ln -s /usr/local/zts/bin/php /usr/local/bin/phps && \
    ln -s /usr/local/apache-php/bin/php /usr/local/bin/php

# Config folders
RUN mkdir -p /usr/local/zts/etc/conf.d \
             /usr/local/apache-php/etc/conf.d \
             /var/log/php \
             /var/www/html

# Configure Apache for PHP with MPM prefork (non-threaded)
RUN echo "LoadModule php_module /usr/lib/apache2/modules/libphp.so" > /etc/apache2/mods-available/php.load && \
    echo "<FilesMatch \.php$>" > /etc/apache2/mods-available/php.conf && \
    echo "    SetHandler application/x-httpd-php" >> /etc/apache2/mods-available/php.conf && \
    echo "</FilesMatch>" >> /etc/apache2/mods-available/php.conf && \
    echo "PHPINIDir /usr/local/apache-php/etc" >> /etc/apache2/mods-available/php.conf && \
    a2dismod mpm_event mpm_worker && \
    a2enmod mpm_prefork php rewrite && \
    sed -i 's|/var/www/html|/var/www/html|g' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|DocumentRoot.*|DocumentRoot /var/www/html|g' /etc/apache2/sites-available/000-default.conf && \
    echo "<Directory /var/www/html>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    AllowOverride All" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    Require all granted" >> /etc/apache2/sites-available/000-default.conf && \
    echo "</Directory>" >> /etc/apache2/sites-available/000-default.conf

# Composer
ENV STEP="Composer"
RUN (curl -sSL https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Dev tools
ENV STEP="Dev tools"
RUN (apt-get update \
    && apt-get install -y --no-install-recommends curl wget lynx vim git make ssh-client unzip \
    && rm -rf /var/lib/apt/lists/* \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

USER $USERNAME

# NVM
ENV STEP="NVM and Node LTS"
SHELL ["/bin/bash", "-c"]
RUN export NVM_DIR="$HOME/.nvm" && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    corepack enable && \
    corepack prepare yarn@stable --activate && \
    sudo bash -c "echo '$SUCCESS $STEP' >> $LOG_FILE" || (sudo bash -c "echo '$FAILURE $STEP' >> $LOG_FILE" && exit 1)
SHELL ["/bin/sh", "-c"]

# Set proper permissions for web directory
RUN sudo chown -R www-data:www-data /var/www/html && \
    sudo chmod -R 755 /var/www/html

ENV LOG_FILE="/tmp/build-log.md"

# Consolidate all build logs
RUN echo "### Build ZTS Stage" >> $LOG_FILE && \
    echo "" >> $LOG_FILE && \
    cat /tmp/build-log-stage-zts.md >> $LOG_FILE && \
    echo "" >> $LOG_FILE && \
    echo "### Build NTS Stage" >> $LOG_FILE && \
    echo "" >> $LOG_FILE && \
    cat /tmp/build-log-stage-nts.md >> $LOG_FILE && \
    echo "" >> $LOG_FILE && \
    echo "### Build Global Stage" >> $LOG_FILE && \
    echo "" >> $LOG_FILE && \
    cat /tmp/build-log-stage-final.md >> $LOG_FILE

EXPOSE 80

CMD ["sudo", "apachectl", "-D", "FOREGROUND"]
