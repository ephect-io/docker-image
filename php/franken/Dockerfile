ARG VERSION=8.5.0
ARG FRANKENPHP_VERSION=1.3.5
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${VERSION}-alpine

ARG VERSION=8.5.0
ARG USERNAME=salamandra
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# OCI Labels pour métadonnées
LABEL org.opencontainers.image.title="FrankenPHP ${FRANKENPHP_VERSION} with PHP ${VERSION}"
LABEL org.opencontainers.image.description="FrankenPHP ${FRANKENPHP_VERSION} with PHP ${VERSION}, Xdebug, Composer, NVM and Node.js LTS"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.vendor="ephect"
LABEL org.opencontainers.image.authors="David Blanchard"

ENV SUCCESS="✅"
ENV FAILURE="❌"
ENV LOG_FILE="/tmp/build-log.md"

# Create build log
RUN touch ${LOG_FILE}

# Base user setup (critique)
ENV STEP="User setup"
RUN (apk add --no-cache sudo shadow \
    && groupadd --gid $USER_GID $USERNAME 2>/dev/null || addgroup -g $USER_GID $USERNAME \
    && useradd -s /bin/sh --uid $USER_UID --gid $USER_GID -m $USERNAME 2>/dev/null || adduser -D -s /bin/sh -u $USER_UID -G $USERNAME $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# PHP configuration
ENV STEP="PHP configuration"
RUN (echo "display_startup_errors = Off" > /usr/local/etc/php/php.ini \
    && echo "display_errors = Off" > /usr/local/etc/php/php.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
    && echo "error_log = php_errors.log" >> /usr/local/etc/php/php.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Xdebug
ENV STEP="Xdebug"
RUN (apk add --no-cache linux-headers \
    && install-php-extensions xdebug \
    && echo "xdebug.mode=develop,coverage,debug" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/dev/stdout" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# Dev tools
ENV STEP="Dev tools"
RUN (apk add --no-cache lynx vim git make bash curl \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Zip extension and other common extensions
ENV STEP="PHP extensions"
RUN (install-php-extensions \
    zip \
    pdo_mysql \
    pdo_pgsql \
    opcache \
    intl \
    gd \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || (echo "$FAILURE $STEP" >> $LOG_FILE && false)

# Composer
ENV STEP="Composer"
RUN (curl -sSL https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Copy Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

USER $USERNAME

# NVM and Node.js
ENV STEP="NVM and Node.js"
ENV NVM_DIR="/home/$USERNAME/.nvm"
ENV NODE_VERSION="--lts"
SHELL ["/bin/bash", "-c"]
RUN (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    source "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    corepack enable && \
    corepack prepare yarn@stable --activate && \
    sudo bash -c "echo '$SUCCESS $STEP' >> $LOG_FILE") || (sudo bash -c "echo '$FAILURE $STEP' >> $LOG_FILE" && exit 1)

# Ensure NVM is available in subsequent shells
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/$USERNAME/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /home/$USERNAME/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"' >> /home/$USERNAME/.bashrc

SHELL ["/bin/sh", "-c"]

# Display log at build time
RUN cat $LOG_FILE

# Set working directory
WORKDIR /app

# Expose ports
EXPOSE 80 443 443/udp

# Switch back to root for runtime
USER root

# Use FrankenPHP entrypoint
ENTRYPOINT ["frankenphp"]
CMD ["run", "--config", "/etc/caddy/Caddyfile"]