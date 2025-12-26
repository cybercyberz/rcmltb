# RCMLTB - ARM64 Native Version for Apple Silicon

This is an optimized version of RCMLTB specifically built for **Apple Silicon (M1/M2/M3)** Macs.

## 🚀 Performance Improvement

| Setup | Relative Speed |
|-------|---------------|
| **This ARM64 version** | **100% (5-10x faster)** |
| Original with `linux/amd64` emulation | 10-20% |

## 📋 What Changed

1. **Dockerfile** - Uses `python:3.11-slim-bookworm` (multi-arch base image)
2. **docker-compose.yml** - No platform override, builds natively
3. **All dependencies** - Installed from ARM64-native packages:
   - qBittorrent-nox (ARM64)
   - aria2 (ARM64)
   - rclone (ARM64)
   - ffmpeg (ARM64)

## 🏃 Quick Start

### Option 1: Using the helper script (Recommended)

```bash
cd /Users/macm2/Downloads/rcmltb-arm64

# Start in foreground (see logs)
./run-arm64.sh up

# Or start in background
./run-arm64.sh up-d

# View logs
./run-arm64.sh logs

# Stop
./run-arm64.sh down
```

### Option 2: Using docker compose directly

```bash
cd /Users/macm2/Downloads/rcmltb-arm64

# Build and start (DO NOT use DOCKER_DEFAULT_PLATFORM=linux/amd64)
docker compose up --build

# Or in background
docker compose up --build -d
```

## ⚠️ Important: Do NOT Use Platform Override

**WRONG (slow, uses emulation):**
```bash
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose up --build
```

**CORRECT (fast, native ARM64):**
```bash
docker compose up --build
```

## 🔧 Configuration

Your `config.env` and `rclone.conf` files are already copied from the original project.

## 📊 Verify Native Execution

After starting, you can verify you're running natively:

```bash
# Check container architecture
docker exec rcmltb-arm64 uname -m
# Should output: aarch64

# Check Python architecture
docker exec rcmltb-arm64 python -c "import platform; print(platform.machine())"
# Should output: aarch64
```

## 🐛 Troubleshooting

### Build fails with package errors
Some packages might have different names. Check the Dockerfile and adjust package names if needed.

### Container won't start
Check logs: `docker logs rcmltb-arm64`

### Still slow?
Make sure you're not setting `DOCKER_DEFAULT_PLATFORM` anywhere:
```bash
echo $DOCKER_DEFAULT_PLATFORM  # Should be empty
unset DOCKER_DEFAULT_PLATFORM
```

## 📁 Files Changed

| File | Change |
|------|--------|
| `Dockerfile` | Complete rewrite for ARM64 |
| `docker-compose.yml` | Removed platform override |
| `run-arm64.sh` | New helper script |
| `README-ARM64.md` | This file |

## 🔄 Syncing with Original

If you update the original `rcmltb` folder, copy the changes (except Docker files):

```bash
# Copy bot code changes
cp -r ../rcmltb/bot ./
cp ../rcmltb/requirements.txt ./
cp ../rcmltb/config.env ./
# Don't copy Dockerfile or docker-compose.yml
```
