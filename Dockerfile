# ARM64-Native Dockerfile for Apple Silicon (M1/M2/M3)
# This provides 5-10x better performance than amd64 emulation

FROM python:3.11-slim-bookworm

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV PYTHONUNBUFFERED=1

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# Enable non-free repository for unrar and install system dependencies
RUN sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get install -y --no-install-recommends \
    aria2 \
    build-essential \
    curl \
    ffmpeg \
    gcc \
    git \
    gnupg \
    libcurl4-openssl-dev \
    libmagic1 \
    mediainfo \
    p7zip-full \
    pv \
    unrar \
    unzip \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install qBittorrent-nox (ARM64 native from Debian repos)
RUN apt-get update && apt-get install -y --no-install-recommends \
    qbittorrent-nox \
    && rm -rf /var/lib/apt/lists/*

# Install latest rclone (auto-detects ARM64)
RUN curl -fsSL https://rclone.org/install.sh | bash

# Create necessary directories
RUN mkdir -p /root/.config/qBittorrent \
    && mkdir -p /usr/src/app/downloads \
    && mkdir -p /usr/src/app/accounts \
    && mkdir -p /usr/src/app/rclone \
    && mkdir -p /usr/src/app/torrents

# Copy qBittorrent config
COPY qBittorrent/config/qBittorrent.conf /root/.config/qBittorrent/qBittorrent.conf

# Install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Make scripts executable
RUN chmod +x start.sh aria.sh

# Expose ports
# 80 - qBittorrent selection webserver
# 8080 - rclone serve index webserver
# 6800 - aria2 RPC
# 8090 - qBittorrent WebUI
EXPOSE 80 8080 6800 8090

CMD ["bash", "start.sh"]
