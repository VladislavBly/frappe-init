#!/bin/bash
# Run this script inside the frappe-bench container to initialize Frappe
# Usage: docker exec -it frappe-bench bash /home/frappe/setup.sh

set -e

BENCH_DIR="/workspace/frappe-bench"
FRAPPE_BRANCH="${FRAPPE_BRANCH:-version-15}"
DB_HOST="${DB_HOST:-mariadb}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-admin}"
SITE_NAME="${SITE_NAME:-dev.localhost}"

echo "=== Frappe Development Environment Setup ==="
echo "Frappe Branch: $FRAPPE_BRANCH"
echo "Database Host: $DB_HOST"
echo "Site Name: $SITE_NAME"

# Create workspace directory if not exists
mkdir -p /workspace
cd /workspace

# Initialize bench if not exists
if [ ! -d "$BENCH_DIR/apps/frappe" ]; then
    echo ""
    echo ">>> Initializing Frappe bench..."

    # Remove empty directory if exists
    if [ -d "$BENCH_DIR" ]; then
        rm -rf "$BENCH_DIR"
    fi

    bench init frappe-bench \
        --frappe-branch "$FRAPPE_BRANCH" \
        --skip-redis-config-generation \
        --verbose

    echo ">>> Bench initialized!"
fi

cd "$BENCH_DIR"

# Configure Redis and MariaDB
echo ""
echo ">>> Configuring bench..."
bench set-config -g redis_cache "redis://redis-cache:6379"
bench set-config -g redis_queue "redis://redis-queue:6379"
bench set-config -g redis_socketio "redis://redis-queue:6379"
bench set-config -g db_host "$DB_HOST"
bench set-config -g db_port 3306

# Create site if not exists
if [ ! -d "$BENCH_DIR/sites/$SITE_NAME" ]; then
    echo ""
    echo ">>> Creating site: $SITE_NAME"

    bench new-site "$SITE_NAME" \
        --mariadb-root-password "$DB_ROOT_PASSWORD" \
        --admin-password admin \
        --no-mariadb-socket

    bench --site "$SITE_NAME" set-config developer_mode 1
    bench use "$SITE_NAME"

    echo ">>> Site created!"
fi

echo ""
echo "========================================"
echo "  Frappe Development Environment Ready"
echo "========================================"
echo ""
echo "  Site: $SITE_NAME"
echo "  URL: http://localhost:8000"
echo "  Username: Administrator"
echo "  Password: admin"
echo ""
echo "  To start the development server, run:"
echo "    cd $BENCH_DIR && bench start"
echo ""
