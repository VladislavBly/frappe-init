# Frappe Framework Docker Development Environment

Docker-based development environment for Frappe Framework on Windows.

## Prerequisites

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- Git

## Quick Start

### 1. Clone and setup

```bash
cd d:\frappe\frappe_react
```

### 2. Configure environment (optional)

```bash
# Copy example env file
cp .env.example .env

# Edit .env as needed
```

### 3. Build and start containers

```bash
# Build the Docker image
docker-compose build

# Start all services
docker-compose up -d
```

### 4. Watch the logs

```bash
# Follow all logs
docker-compose logs -f

# Or just frappe logs
docker-compose logs -f frappe
```

### 5. Access Frappe

Once setup is complete (first run takes several minutes):

- **URL:** http://localhost:8000
- **Username:** Administrator
- **Password:** admin

## Services

| Service | Port | Description |
|---------|------|-------------|
| frappe | 8000 | Frappe web server |
| frappe | 9000 | Socket.IO (real-time) |
| mariadb | 3307 | MariaDB database |
| redis-cache | - | Redis for caching |
| redis-queue | - | Redis for job queue |

## Common Commands

### Access Frappe container shell

```bash
docker-compose exec frappe bash
```

### Run bench commands

```bash
# Inside container
bench --site dev.localhost console
bench --site dev.localhost migrate
bench --site dev.localhost clear-cache

# Or from host
docker-compose exec frappe bench --site dev.localhost console
```

### Create a new app

```bash
docker-compose exec frappe bench new-app my_app
docker-compose exec frappe bench --site dev.localhost install-app my_app
```

### Restart services

```bash
docker-compose restart frappe
```

### Stop all services

```bash
docker-compose down
```

### Stop and remove volumes (full reset)

```bash
docker-compose down -v
```

## Development Workflow

### Install existing app

```bash
# Access container
docker-compose exec frappe bash

# Clone app to apps directory
cd apps
git clone https://github.com/user/app_name.git

# Install app
bench --site dev.localhost install-app app_name
```

### File changes

- App files in `./apps/` are mounted to container
- Site files in `./sites/` are mounted to container
- Changes reflect automatically (hot reload enabled)

## Troubleshooting

### Container won't start

Check if ports are free:
```bash
netstat -ano | findstr :8000
netstat -ano | findstr :3307
```

### Database connection issues

```bash
# Check MariaDB status
docker-compose logs mariadb

# Restart MariaDB
docker-compose restart mariadb
```

### Full reset

```bash
# Stop and remove everything
docker-compose down -v

# Remove built images
docker-compose down --rmi local

# Rebuild and start fresh
docker-compose up -d --build
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| DB_ROOT_PASSWORD | admin | MariaDB root password |
| FRAPPE_BRANCH | version-15 | Frappe version branch |
| SITE_NAME | dev.localhost | Development site name |
| DEVELOPER_MODE | 1 | Enable developer mode |

### Frappe Versions

Change `FRAPPE_BRANCH` in `.env`:

- `version-14` - Frappe v14 (LTS)
- `version-15` - Frappe v15 (Latest)
- `develop` - Development branch

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Network                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   MariaDB    │  │ Redis Cache  │  │   Redis Queue    │  │
│  │   :3306      │  │   :6379      │  │     :6379        │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         │                 │                    │            │
│         └────────────┬────┴────────────────────┘            │
│                      │                                      │
│              ┌───────┴────────┐                             │
│              │  Frappe Bench  │                             │
│              │  :8000 (web)   │                             │
│              │  :9000 (ws)    │                             │
│              └────────────────┘                             │
└─────────────────────────────────────────────────────────────┘
              │         │
              ▼         ▼
         localhost:8000  localhost:9000
```
