ARG RELEASE=8.2.27-apache-bookworm
FROM php:${RELEASE}

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium
RUN docker-php-ext-enable zip
RUN docker-php-ext-enable redis
