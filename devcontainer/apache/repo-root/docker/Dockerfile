ARG VARIANT=8.5.0
ARG REPO=${ROCKER:-ephect/dev-php}
FROM ${REPO}:apache-ts-${VARIANT}

ARG BUILD_ENV=development

USER root

COPY docker/apache/000-default.conf /etc/apache2/sites-available/

# Configure Apache to run as salamandra user
RUN sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=salamandra/' /etc/apache2/envvars && \
    sed -i 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=salamandra/' /etc/apache2/envvars

# Configure Apache to listen on port 8080
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf && \
    echo "ServerName myapp.docker.internal" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite

# For production: copy application files into the image
RUN if [ "$BUILD_ENV" = "production" ]; then \
        mkdir -p /var/www/html; \
    fi

COPY --chown=salamandra:salamandra docker/post-up-dev.sh /tmp/docker-config/
COPY --chown=salamandra:salamandra docker/post-up-prod.sh /tmp/docker-config/

RUN if [ "$BUILD_ENV" = "development" ]; then \
        #cp -r /tmp/docker-config /var/www/html/docker; \
        cp /tmp/docker-config/post-up-dev.sh /usr/local/bin/post-up && \
        chmod +x /usr/local/bin/post-up; \
    fi

RUN if [ "$BUILD_ENV" = "production" ]; then \
        #cp -r /tmp/docker-config /var/www/html/docker; \
        cp /tmp/docker-config/post-up-prod.sh /usr/local/bin/post-up && \
        chmod +x /usr/local/bin/post-up; \
    fi

# Production: copy all files
COPY --chown=salamandra:salamandra . /tmp/app-files/

RUN if [ "$BUILD_ENV" = "production" ]; then \
        cp -r /tmp/app-files/* /var/www/html/ && \
        cp -r /tmp/app-files/.[!.]* /var/www/html/ 2>/dev/null || true && \
        chown -R salamandra:salamandra /var/www/html && \
        cd /var/www/html && \
        composer install --no-dev --optimize-autoloader; \
    fi && \
    rm -rf /tmp/app-files /tmp/docker-config

# Set working directory
WORKDIR /var/www/html

# Run as salamandra
USER salamandra

EXPOSE 8080
