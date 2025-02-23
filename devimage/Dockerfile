# [Choice] PHP version (add -arm64 after the variant for arm64/Apple Silicon): 8.4.3, 8.3.16, 8.2.27, 8.1.9
ARG VERSION=8.4.3
FROM ephect/php-apache-zts:${VERSION}

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=salamandra
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends sudo \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -aG www-data ${USERNAME} \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

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
	apt-get install -y --no-install-recommends lynx vim git make unzip; \
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

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libzip-dev \
    && pecl install zip \
    && echo extension=zip.so > /usr/local/etc/php/conf.d/zip.ini

# Install composer
RUN curl -sSL https://getcomposer.org/installer | php \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer

#
# User space installation
#
USER salamandra

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV=/home/$USERNAME/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install --lts

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
