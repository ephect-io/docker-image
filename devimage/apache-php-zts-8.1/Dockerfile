# [Choice] PHP version (use -bullseye variants on local arm64/Apple Silicon): 8-apache-bullseye, 8.1-apache-bullseye, 8.0-apache-bullseye, 7-apache-bullseye, 7.4-apache-bullseye, 8-apache-buster, 8.1-apache-buster, 8.0-apache-buster, 7-apache-buster, 7.4-apache-buster
ARG VARIANT=8.1.9
FROM ephect/php-apache:${VARIANT}

# Copy library scripts to execute
COPY library-scripts/common-debian.sh library-scripts/node-debian.sh library-scripts/meta.env /tmp/library-scripts/

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=salamandra
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get -y install --no-install-recommends lynx vim \
    && usermod -aG www-data ${USERNAME} \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="lts/*"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
RUN bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Remove library scripts for final image
RUN rm -rf /tmp/library-scripts

# display_errors = Off
RUN echo "display_startup_errors = Off" > /usr/local/etc/php/php.ini \
    && echo "display_errors = Off" > /usr/local/etc/php/php.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
	&& echo "error_log = php_errors.log" >> /usr/local/etc/php/php.ini \
	&& echo "log_errors_max_len = 1024" >> /usr/local/etc/php/php.ini \
	&& echo "ignore_repeated_errors = Off" >> /usr/local/etc/php/php.ini \
	&& echo "ignore_repeated_source = Off" >> /usr/local/etc/php/php.ini

# Install xdebug
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,coverage,debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_host=localhost" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log=/dev/stdout" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && rm -rf /tmp/pear

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends unzip; \
	rm -rf /var/lib/apt/lists/*;

# Install parallel
RUN curl -L -O https://github.com/krakjoe/parallel/archive/refs/heads/develop.zip \
    && unzip develop.zip \
    && cd parallel-develop \
    && phpize \
    && ./configure --enable-parallel \
    && make \
    && make install \
	&& cd .. \
	&& rm develop.zip \
	&& rm -rf parallel-develop \
    && echo "extension=parallel.so" > /usr/local/etc/php/conf.d/parallel.ini

# Install composer
RUN curl -sSL https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer

RUN echo "salamandra ALL=(ALL) NOPASSWD: ALL" >  /etc/sudoers.d/salamandra

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends vim

