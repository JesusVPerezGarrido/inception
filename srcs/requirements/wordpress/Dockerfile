FROM debian:bullseye

# 1. Install base dependencies (single layer)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    php-fpm \
    php-mysqli \
    mariadb-client

# 2. Install WP-CLI with retry logic
RUN for i in {1..5}; do \
    wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && wp --allow-root cli version \
    && break || sleep 5; \
    done

# 3. Configure PHP/WordPress
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
RUN mkdir -p /run/php /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 4. Copy entrypoint script
COPY tools/wp.sh /usr/local/bin/wp.sh
COPY tools/login-redirect.php /var/www/html/wp-content/plugins/login-redirect.php
RUN chmod +x /usr/local/bin/wp.sh

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["wp.sh"]