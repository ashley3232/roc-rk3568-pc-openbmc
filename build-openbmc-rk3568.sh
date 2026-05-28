#!/bin/bash
# OpenBMC Firmware Build Script for ROC-RK3568-PC
# Usage: ./build-openbmc-rk3568.sh

set -e

MACHINE="qemux86-64"  # Using QEMU first, change to "roc-rk3568-pc" for actual hardware
BUILD_DIR="build-${MACHINE}"
PARALLEL_JOBS=8

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "========================================================================"
echo " OpenBMC Firmware Build Script"
echo " Target: ROC-RK3568-PC (Rockchip RK3568)"
echo "========================================================================"
echo ""

# Check for required tools
log_info "Checking dependencies..."
for cmd in git make; do
    if ! command -v $cmd &> /dev/null; then
        log_error "Required command '$cmd' not found"
        exit 1
    fi
done
log_success "Dependencies OK"
echo ""

# Check disk space (need at least 50GB)
AVAILABLE=$(df -BG /tmp | awk 'NR==2 {print $4}' | tr -d 'G')
if [ "$AVAILABLE" -lt 50 ]; then
    log_warn "Low disk space: ${AVAILABLE}GB available (50GB+ recommended)"
fi

# Clone or update OpenBMC
OPENBMC_DIR="/tmp/openbmc"
if [ -d "$OPENBMC_DIR/.git" ]; then
    log_info "Updating existing OpenBMC repository..."
    cd "$OPENBMC_DIR"
    git pull
else
    log_info "Cloning OpenBMC repository (this may take a while)..."
    rm -rf "$OPENBMC_DIR"
    git clone --depth 1 https://github.com/openbmc/openbmc.git "$OPENBMC_DIR"
fi
log_success "OpenBMC repository ready"
echo ""

cd "$OPENBMC_DIR"

# Initialize build directory
log_info "Setting up build directory: $BUILD_DIR"
if [ -d "$BUILD_DIR" ]; then
    log_warn "Build directory exists, cleaning..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR/conf"

# Write local.conf
log_info "Creating build configuration..."
cat > "$BUILD_DIR/conf/local.conf" << CONF
# OpenBMC Build Configuration
MACHINE = "${MACHINE}"
DISTRO = "poky"
BB_NUMBER_THREADS = "${PARALLEL_JOBS}"
PARALLEL_MAKE = "-j ${PARALLEL_JOBS}"
CONF
log_success "Configuration created"
echo ""

# Build firmware
log_info "Starting OpenBMC build..."
log_warn "This may take 2-4+ hours depending on your hardware"
echo ""

# Source environment and build
. ./openbmc-env "$BUILD_DIR"

log_info "Running bitbake obmc-phosphor-image..."
bitbake obmc-phosphor-image

# Find output files
log_success "Build completed!"
echo ""
log_info "Output files:"
find "$BUILD_DIR/tmp/deploy/images" -type f \( -name "*.ostree*" -o -name "*.wic" -o -name "*.ext4" -o -name "*.tar.bz2" \) 2>/dev/null | head -20

echo ""
echo "========================================================================"
log_success "OpenBMC Firmware Build Complete!"
echo "========================================================================"
echo ""
echo "Next steps:"
echo "1. Copy firmware to SD card/Flash"
echo "2. Boot ROC-RK3568-PC from firmware"
echo "3. Access BMC web interface"
echo ""
