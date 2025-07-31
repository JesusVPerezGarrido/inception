#!/bin/bash

echo "Setting up MariaDB"

# Initialize the database if it's empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB with explicit socket path
echo "Starting MariaDB server..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock &

# Wait for MariaDB to start and check if it's running
echo "Waiting for MariaDB to initialize..."
for i in {1..30}; do
  if [ -S "/run/mysqld/mysqld.sock" ]; then
    echo "Socket file created. MariaDB is running."
    break
  fi
  echo "Waiting for socket file... ($i/30)"
  sleep 1
done

# If socket still doesn't exist, show running processes and error logs
if [ ! -S "/run/mysqld/mysqld.sock" ]; then
  echo "ERROR: Socket file not created after 30 seconds"
  echo "Running processes:"
  ps aux
  echo "Error log contents:"
  cat /var/log/mysql/error.log 2>/dev/null || echo "No error log found"
  exit 1
fi

# Set up database and users
if [ ! -f /var/lib/mysql/.initialized ]; then
	echo "Configuring database..."
	mysqladmin -u root password "${MYSQL_ROOT_PASSWORD}"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

	# Add these lines after setting up the database
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User='';" # Remove anonymous users
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" # Restrict root login to localhost
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" # Ensure root password is set for socket connections
	mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;" # Apply changes
	touch /var/lib/mysql/.initialized
else
	echo "Database already configured."
fi;
echo "MariaDB is fully configured and ready to use"
# Keep the container running
wait