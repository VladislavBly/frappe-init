# Frappe Framework Development Dockerfile
FROM python:3.11-slim-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    git \
    curl \
    wget \
    # Python dependencies
    python3-dev \
    python3-pip \
    python3-setuptools \
    # MariaDB client
    mariadb-client \
    libmariadb-dev \
    # wkhtmltopdf dependencies
    wkhtmltopdf \
    xvfb \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    # Other dependencies
    redis-tools \
    supervisor \
    nginx \
    gettext-base \
    libpango-1.0-0 \
    libharfbuzz0b \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    # Timezone
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn

# Create frappe user
RUN useradd -m -s /bin/bash frappe \
    && mkdir -p /workspace \
    && chown -R frappe:frappe /workspace

# Switch to frappe user
USER frappe
WORKDIR /home/frappe

# Install frappe-bench via pip
RUN pip3 install --user --break-system-packages frappe-bench

# Add local bin to PATH
ENV PATH="/home/frappe/.local/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Expose ports
# 8000 - Frappe web server
# 9000 - Socketio
EXPOSE 8000 9000

# Default command - keep container running
CMD ["sleep", "infinity"]
