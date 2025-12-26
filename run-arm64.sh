#!/bin/bash

# ARM64 Native Docker Runner for Apple Silicon (M1/M2/M3)
# This script ensures you're running natively without emulation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  RCMLTB ARM64 Native Docker Runner    ${NC}"
echo -e "${GREEN}  Optimized for Apple Silicon M1/M2/M3 ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check architecture
ARCH=$(uname -m)
echo -e "System Architecture: ${YELLOW}${ARCH}${NC}"

if [ "$ARCH" = "arm64" ]; then
    echo -e "${GREEN}✓ Running on ARM64 (Apple Silicon) - Native performance enabled!${NC}"
else
    echo -e "${RED}⚠ Warning: Not running on ARM64. Performance may be reduced.${NC}"
fi

# Unset any platform overrides that would force emulation
unset DOCKER_DEFAULT_PLATFORM

echo ""
echo -e "Docker Platform: ${YELLOW}linux/arm64 (native)${NC}"
echo ""

# Parse command
case "${1:-up}" in
    up)
        echo -e "${GREEN}Starting bot in foreground...${NC}"
        docker compose up --build
        ;;
    up-d)
        echo -e "${GREEN}Starting bot in background...${NC}"
        docker compose up --build -d
        echo -e "${GREEN}Bot started! Use 'docker logs -f rcmltb-arm64' to view logs${NC}"
        ;;
    down)
        echo -e "${YELLOW}Stopping bot...${NC}"
        docker compose down
        ;;
    restart)
        echo -e "${YELLOW}Restarting bot...${NC}"
        docker compose down
        docker compose up --build -d
        ;;
    logs)
        docker logs -f rcmltb-arm64
        ;;
    shell)
        echo -e "${GREEN}Opening shell in container...${NC}"
        docker exec -it rcmltb-arm64 bash
        ;;
    clean)
        echo -e "${RED}Cleaning up (removing container and images)...${NC}"
        docker compose down --rmi all --volumes
        ;;
    *)
        echo "Usage: $0 {up|up-d|down|restart|logs|shell|clean}"
        echo ""
        echo "Commands:"
        echo "  up      - Start bot in foreground (with logs)"
        echo "  up-d    - Start bot in background (detached)"
        echo "  down    - Stop the bot"
        echo "  restart - Restart the bot"
        echo "  logs    - View bot logs"
        echo "  shell   - Open shell in container"
        echo "  clean   - Remove container and images"
        exit 1
        ;;
esac
