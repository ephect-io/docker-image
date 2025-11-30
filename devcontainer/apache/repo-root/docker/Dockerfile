# [Choice] PHP version (use -bullseye variants on local arm64/Apple Silicon): 8-apache-bullseye, 8.1-apache-bullseye, 8.0-apache-bullseye, 7-apache-bullseye, 7.4-apache-bullseye, 8-apache-buster, 8.1-apache-buster, 8.0-apache-buster, 7-apache-buster, 7.4-apache-buster
ARG VARIANT=8.4.15
ARG ROCKER=localhost:5000/dev-php
FROM ${ROCKER}:apache-${VARIANT}

USER root

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

COPY apache/000-default.conf /etc/apache2/sites-available/
COPY php/xdebug.ini /usr/local/etc/php/conf.d/

RUN echo "ServerName myapp.docker.internal" >> /etc/apache2/apache2.conf
RUN echo '#!/bin/bash \
echo "127.0.0.1 myapp.docker.internal" >> /etc/hosts 2>/dev/null || true'

RUN apt-get update && apt-get install -y libpq-dev

RUN docker-php-ext-install pdo_pgsql \
    && docker-php-ext-enable pdo_pgsql

RUN a2enmod rewrite
RUN apachectl restart

USER salamandra