#!/bin/bash
set -e

BENCH_DIR="/home/frappe/frappe-bench"
FRAPPE_BRANCH="${FRAPPE_BRANCH:-version-15}"

echo "=== Frappe Development Environment Setup ==="
echo "Frappe Branch: $FRAPPE_BRANCH"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
while ! mariadb -h"${DB_HOST}" -uroot -p"${DB_ROOT_PASSWORD}" -e "SELECT 1" &> /dev/null; do
    sleep 2
done
echo "MariaDB is ready!"

# Wait for Redis
echo "Waiting for Redis..."
while ! redis-cli -h redis-cache ping &> /dev/null; do
    sleep 1
done
echo "Redis is ready!"

cd /home/frappe

# Initialize bench if not exists (check for apps/frappe which indicates successful init)
if [ ! -d "$BENCH_DIR/apps/frappe" ]; then
    echo "Initializing new Frappe bench..."

    bench init "$BENCH_DIR" \
        --frappe-branch "$FRAPPE_BRANCH" \
        --skip-redis-config-generation \
        --verbose

    echo "Bench initialized successfully!"
else
    echo "Bench already initialized, skipping..."
fi

cd "$BENCH_DIR"

# Configure Redis and MariaDB in common_site_config.json
echo "Configuring Frappe..."
bench set-config -g redis_cache "redis://redis-cache:6379"
bench set-config -g redis_queue "redis://redis-queue:6379"
bench set-config -g redis_socketio "redis://redis-queue:6379"
bench set-config -g db_host "$DB_HOST"
bench set-config -g db_port 3306

# Check if site exists
SITE_NAME="${SITE_NAME:-dev.localhost}"
if [ ! -d "$BENCH_DIR/sites/$SITE_NAME" ]; then
    echo "Creating new site: $SITE_NAME"

    bench new-site "$SITE_NAME" \
        --mariadb-root-password "$DB_ROOT_PASSWORD" \
        --admin-password admin \
        --no-mariadb-socket

    bench --site "$SITE_NAME" set-config developer_mode 1
    bench use "$SITE_NAME"

    echo "Site created successfully!"
else
    echo "Site $SITE_NAME already exists, skipping..."
fi

echo ""
echo "=== Frappe Development Environment Ready ==="
echo "Site: $SITE_NAME"
echo "URL: http://localhost:8000"
echo "Username: Administrator"
echo "Password: admin"
echo ""

# Start bench in development mode
echo "Starting Frappe development server..."
exec bench start
