FROM debian:bullseye

RUN apt-get update \
	&& apt-get install -y mariadb-client \
	mariadb-server

# Ensure MariaDB directories exist with proper permissions
RUN mkdir -p /run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql \
	&& chmod 777 /run/mysqld

COPY ./conf/my.cnf /etc/mysql/my.cnf

# Create your custom directory for the script
RUN mkdir -p /var/www/initdb

# Copy the setup script into the container
COPY ./tools/db.sh /var/www/initdb/db.sh

# Make the script executable
RUN chmod +x /var/www/initdb/db.sh

EXPOSE 3306

# The script will handle user switching as needed
ENTRYPOINT ["/var/www/initdb/db.sh"]