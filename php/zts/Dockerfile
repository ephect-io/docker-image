ARG VERSION=8.5.0
FROM php:${VERSION}-zts

ARG USERNAME=salamandra
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV SUCCESS="✅"
ENV FAILURE="❌"
ENV LOG_FILE="./README.md"

# Create build log
RUN echo "# Build Log" > ${LOG_FILE}


# Base user setup (critique)
ENV STEP="User setup"
RUN (apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends sudo \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -aG www-data ${USERNAME} \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
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
RUN (yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,coverage,debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_host=localhost" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log=/dev/stdout" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && rm -rf /tmp/pear \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# System packages
ENV STEP="System packages"
RUN (apt-get update \
    && apt-get install -y --no-install-recommends lynx vim git make unzip \
    && rm -rf /var/lib/apt/lists/* \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Install parallel
ENV STEP="Parallel extension"
RUN (curl -L -O https://github.com/krakjoe/parallel/archive/refs/heads/develop.zip \
    && unzip develop.zip \
    && cd parallel-develop \
    && phpize \
    && ./configure --enable-parallel \
    && make \
    && make install \
	&& cd .. \
	&& rm develop.zip \
	&& rm -rf parallel-develop \
    && echo "extension=parallel.so" > /usr/local/etc/php/conf.d/parallel.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Zip extension
ENV STEP="Zip extension"
RUN (apt-get update \
    && apt-get -y install --no-install-recommends libzip-dev \
    && pecl install zip \
    && echo extension=zip.so > /usr/local/etc/php/conf.d/zip.ini \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Composer
ENV STEP="Composer"
RUN (curl -sSL https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

USER $USERNAME

# NVM
ENV STEP="NVM and Node.js"
ENV BASH_ENV=/home/$USERNAME/.bash_env
RUN touch "${BASH_ENV}" && echo '. "${BASH_ENV}"' >> ~/.bashrc

RUN (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE="${BASH_ENV}" bash \
    && echo node > .nvmrc \
    && bash -c "source ${BASH_ENV} && nvm install --lts" \
    && echo "$SUCCESS $STEP" >> $LOG_FILE) || echo "$FAILURE $STEP" >> $LOG_FILE

# Display log at build time
RUN cat $LOG_FILE