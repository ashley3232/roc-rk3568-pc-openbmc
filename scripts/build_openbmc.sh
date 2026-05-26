#!/bin/bash
#=============================================================================
# OpenBMC Build Script for ROC-RK3568-PC (Rockchip RK3568)
# 
# This script compiles OpenBMC firmware for the Firefly ROC-RK3568-PC board
# featuring Rockchip RK3568 SoC (Quad-core Cortex-A55)
#
# Hardware Specs from PDF:
# - SoC: RK3568 (4x Cortex-A55 @ 2.0GHz)
# - GPU: Mali-G52 2EE
# - NPU: 0.8 TOPS
# - Memory: 2GB/4GB/8GB LPDDR4
# - Storage: eMMC, SPI Flash (16MB), M.2 NVMe, SATA, TF Card
# - Ethernet: 2x Gigabit
# - USB: USB3.0, USB-C (OTG), 2x USB2.0
# - Power: DC 12V (9V-24V wide input)
#=============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
OPENBMC_DIR="${PROJECT_ROOT}/openbmc_workspace"
BUILD_DIR="${OPENBMC_DIR}/build"
MACHINE="roc-rk3568-pc"
BOARD_NAME="ROC-RK3568-PC"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Print section header
print_header() {
    echo ""
    echo "========================================================================"
    echo " $1"
    echo "========================================================================"
}

# Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Required command '$1' not found. Please install it first."
        return 1
    fi
    return 0
}

# Check system requirements
check_requirements() {
    print_header "Checking System Requirements"
    
    local required_commands=("git" "make" "gcc" "g++" "python3")
    local all_installed=true
    
    for cmd in "${required_commands[@]}"; do
        if check_command "$cmd"; then
            log_success "$cmd is installed"
        else
            all_installed=false
        fi
    done
    
    if [ "$all_installed" = false ]; then
        log_error "Some required commands are missing. Please install them first."
        log_info "Run: sudo apt-get update && sudo apt-get install -y build-essential git python3"
        return 1
    fi
    
    # Check disk space (need at least 20GB)
    if [ ! -d "${PROJECT_ROOT}" ]; then
        mkdir -p "${PROJECT_ROOT}"
    fi
    local available_space=$(df -BG "${PROJECT_ROOT}" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 20 ]; then
        log_warning "Available disk space is less than 20GB. OpenBMC build may require more."
    else
        log_success "Disk space check passed (${available_space}GB available)"
    fi
    
    # Check memory (need at least 8GB)
    local total_mem=$(free -g | awk 'NR==2 {print $2}')
    if [ "$total_mem" -lt 8 ]; then
        log_warning "System has less than 8GB RAM. Build may be slow or fail."
    else
        log_success "Memory check passed (${total_mem}GB total)"
    fi
    
    return 0
}

# Install build dependencies
install_dependencies() {
    print_header "Installing Build Dependencies"
    
    log_info "Updating package lists..."
    sudo apt-get update
    
    log_info "Installing OpenBMC build dependencies..."
    sudo apt-get install -y \
        git \
        build-essential \
        cmake \
        ninja-build \
        g++ \
        flex \
        bison \
        gperf \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        python3-setuptools \
        libffi-dev \
        libssl-dev \
        zlib1g-dev \
        libncurses-dev \
        libncursesw5-dev \
        bc \
        cpio \
        file \
        unzip \
        wget \
        curl \
        zstd \
        xz-utils \
        rsync \
        uuid-dev \
        libgpgme-dev \
        libssl-dev \
        libsasl2-dev \
        swig \
        device-tree-compiler
        
    log_success "All dependencies installed successfully"
}

# Setup git configuration
setup_git() {
    print_header "Setting up Git Configuration"
    
    if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
        git config --global user.email "builder@openbmc.local"
        log_info "Git user.email configured"
    fi
    
    if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
        git config --global user.name "OpenBMC Builder"
        log_info "Git user.name configured"
    fi
    
    # Optimize git performance
    git config --global pack.threads 0
    git config --global pack.windowMemory "256m"
    git config --global http.postBuffer 524288000
    
    log_success "Git configuration completed"
}

# Clone OpenBMC repository
clone_openbmc() {
    print_header "Cloning OpenBMC Repository"
    
    if [ -d "${OPENBMC_DIR}" ]; then
        log_warning "OpenBMC directory already exists: ${OPENBMC_DIR}"
        read -p "Do you want to update the existing repository? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Updating existing repository..."
            cd "${OPENBMC_DIR}"
            git pull origin master || git pull origin main
            git submodule update --init --recursive
            log_success "Repository updated"
        else
            log_info "Using existing repository"
        fi
    else
        log_info "Cloning OpenBMC repository..."
        log_info "This may take 10-20 minutes depending on your connection..."
        
        # Clone OpenBMC
        git clone https://github.com/openbmc/openbmc.git "${OPENBMC_DIR}"
        cd "${OPENBMC_DIR}"
        
        log_info "Initializing submodules (this may take a while)..."
        git submodule update --init --recursive || {
            log_warning "Some submodules failed to initialize. Continuing anyway..."
        }
        
        log_success "OpenBMC repository cloned successfully"
    fi
    
    log_info "OpenBMC directory: ${OPENBMC_DIR}"
}

# Setup build environment
setup_build() {
    print_header "Setting Up Build Environment"
    
    # Create build directory
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    # Source OpenBMC environment
    if [ -f "${OPENBMC_DIR}/openbmc-env" ]; then
        source "${OPENBMC_DIR}/openbmc-env"
        log_info "OpenBMC environment sourced"
    fi
    
    # Clean if directory is not empty
    if [ "$(ls -A ${BUILD_DIR})" ]; then
        log_warning "Build directory is not empty"
        read -p "Do you want to clean it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Cleaning build directory..."
            rm -rf "${BUILD_DIR}"/*
        fi
    fi
    
    # Set environment variables
    export MACHINE="${MACHINE}"
    export BUILD_DIR="${BUILD_DIR}"
    
    log_success "Build environment configured"
    log_info "Machine: ${MACHINE}"
    log_info "Build directory: ${BUILD_DIR}"
}

# Configure OpenBMC for RK3568
configure_openbmc() {
    print_header "Configuring OpenBMC for ${BOARD_NAME}"
    
    cd "${OPENBMC_DIR}"
    
    # Add meta-rockchip layer if not present
    if [ ! -d "meta-rockchip" ]; then
        log_info "Adding meta-rockchip layer for RK3568 support..."
        git clone https://github.com/openbmc/meta-rockchip.git meta-rockchip
    fi
    
    # Create build configuration
    cat > "${BUILD_DIR}/conf/local.conf" << EOF
MACHINE ??= "${MACHINE}"
DISTRO ?= "openbmc-rtk-ucmc"
PACKAGE_CLASSES ?= "package_ipk"
EXTRA_IMAGE_FEATURES ?= "debug-tweaks ssh-server-openssh"
USER_CLASSES ?= "buildstats image-prelink"
PATCHRESOLVE = "noop"
CONF_VERSION = "2"

# Enable parallel build
BB_NUMBER_THREADS = "\${@oe.utils.cpu_count()}"
PARALLEL_MAKE = "-j \${@oe.utils.cpu_count()}"

# Storage configuration
IMAGE_INSTALL_append = " linux-firmware"
EOF

    # Create bblayers.conf
    cat > "${BUILD_DIR}/conf/bblayers.conf" << 'EOF'
LCONF_VERSION = "8"

BBPATH ?= "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  ${TOPDIR}/../meta \
  ${TOPDIR}/../meta-poky \
  ${TOPDIR}/../meta-openembedded/meta-oe \
  ${TOPDIR}/../meta-openembedded/meta-python \
  ${TOPDIR}/../meta-rockchip \
  "

BBLAYERS_NON_REMOVABLE ?= " \
  ${TOPDIR}/../meta \
  ${TOPDIR}/../meta-poky \
  "
EOF

    # Create machine configuration for ROC-RK3568-PC
    mkdir -p "${OPENBMC_DIR}/meta-rockchip/conf/machine"
    cat > "${OPENBMC_DIR}/meta-rockchip/conf/machine/${MACHINE}.conf" << EOF
# Machine configuration for ${BOARD_NAME}
# Rockchip RK3568 SoC

require conf/machine/include/rk3568.inc

DESCRIPTION = "${BOARD_NAME} - OpenBMC for Rockchip RK3568"

# Hardware features
UBOOT_CONFIG = "rockchip"
KERNEL_DEVICETREE = "rockchip/rk3568-roc-pc.dtb"

# Serial console
SERIAL_CONSOLE = "1500000 ttyS2"

# Flash layout
RK3568_SPI_NOR_SIZE = "16"
EOF

    log_success "OpenBMC configured for ${BOARD_NAME}"
}

# Build OpenBMC
build_openbmc() {
    print_header "Building OpenBMC for ${BOARD_NAME}"
    
    cd "${OPENBMC_DIR}"
    
    # Source environment
    source "${OPENBMC_DIR}/openbmc-env" || {
        log_error "Failed to source OpenBMC environment"
        return 1
    }
    
    export MACHINE="${MACHINE}"
    
    log_info "Starting OpenBMC build..."
    log_info "This will take 2-4 hours depending on your system"
    log_info "Building target: ${TARGET:-all}"
    
    # Run build
    if command -v bitbake &> /dev/null; then
        bitbake obmc-phosphor-image || {
            log_error "bitbake build failed"
            return 1
        }
    else
        log_warning "bitbake not found. Attempting to use alternative build method..."
        
        # Alternative: Use make-based build if available
        if [ -f "Makefile" ]; then
            make MACHINE="${MACHINE}" all || {
                log_error "Make build failed"
                return 1
            }
        else
            log_error "Neither bitbake nor make build system available"
            log_info "Please ensure OpenBMC environment is properly set up"
            return 1
        fi
    fi
    
    log_success "OpenBMC build completed"
}

# Generate build manifest
generate_manifest() {
    print_header "Generating Build Manifest"
    
    local manifest_file="${BUILD_DIR}/BUILD_MANIFEST.md"
    
    cat > "${manifest_file}" << EOF
# OpenBMC Build Manifest
## ${BOARD_NAME}

### Build Information
- **Build Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Build Directory**: ${BUILD_DIR}
- **Machine**: ${MACHINE}
- **Builder Version**: 1.0

### Board Hardware Specifications
Based on ROC-RK3568-PC Specification Document:

#### Processor (SoC)
- **Chip**: Rockchip RK3568
- **Architecture**: Quad-core 64-bit Cortex-A55
- **Process**: 22nm
- **Max Frequency**: 2.0 GHz

#### Graphics & AI
- **GPU**: ARM Mali-G52 2EE
- **GPU Features**: OpenGL ES 3.2/2.0/1.1, OpenCL 2.0, Vulkan 1.1
- **NPU**: 0.8 TOPS @ INT8
- **VPU**: 4K@60fps H.265/H.264/VP9 decode, 1080P@100fps encode

#### Memory
- **RAM**: 2GB / 4GB / 8GB LPDDR4
- **ECC**: Full链路 ECC support

#### Storage
- **eMMC**: 32GB / 64GB / 128GB
- **SPI Flash**: 16MB
- **Expansion**: M.2 NVMe SSD, SATA3.0 SSD/HDD, TF Card

#### Networking
- **Ethernet**: 2x Gigabit RJ45 (1000 Mbps)
- **Wireless**: WiFi 6 (802.11ax), Bluetooth 5.0

#### USB & I/O
- **USB**: 1x USB 3.0, 1x USB-C (OTG), 2x USB 2.0
- **Display**: HDMI 2.0, 2x MIPI DSI, eDP 1.3
- **Camera**: 2x MIPI CSI
- **Serial**: RS485 x1, RS232 x2

#### Power
- **Input**: DC 12V (9V-24V wide range)
- **Standby**: 0.3W
- **Typical**: 4.2W
- **Maximum**: 7.8W

#### Dimensions
- **Size**: 138.0 mm × 77.5 mm × 19.9 mm

### OpenBMC Features
- **Web Interface**: BMC Web UI (port 443)
- **IPMI**: IPMI 2.0 support
- **Redfish**: RESTful API for management
- **SSH**: Secure shell access
- **KVM**: Keyboard-Video-Mouse over IP
- **Virtual Media**: Remote CD/USB mounting
- **Sensor Monitoring**: Temperature, voltage, fan speed
- **Firmware Update**: Via Web UI or Redfish API

### Build Output
The following images are generated:
- \`image-bmc\` - Main BMC firmware
- \`image-kernel\` - Linux kernel image
- \`image-rofs\` - Read-only root filesystem
- \`image-u-boot\` - U-Boot bootloader

### Flashing Instructions
1. Connect to BMC via USB-C or serial
2. Access BMC shell
3. Flash images using \`bmc-update\` tool
4. Reboot BMC

### Network Configuration
Default BMC IP: DHCP
- Static IP configuration via Web UI or IPMI

### Access Information
- **Web UI**: https://<bmc-ip>
- **Redfish API**: https://<bmc-ip>/redfish/v1
- **IPMI**: ipmitool -H <bmc-ip> -U admin -P 0penBmc shell

### Build Logs
See \`${BUILD_DIR}/tmp/log/\` directory for detailed build logs

---
Generated by OpenBMC Build System for ${BOARD_NAME}
EOF

    log_success "Build manifest generated: ${manifest_file}"
}

# Print usage
print_usage() {
    cat << EOF
OpenBMC Build Script for ${BOARD_NAME}

Usage: $0 [OPTION]

Options:
    --deps              Install build dependencies only
    --clone             Clone OpenBMC repository only
    --configure         Configure build environment only
    --build             Build OpenBMC (requires repo to be cloned)
    --all               Full build process (default)
    --check             Check system requirements only
    --help              Show this help message

Examples:
    $0                  # Full build process
    $0 --deps           # Install dependencies
    $0 --clone          # Clone repository
    $0 --build          # Build only

For more information, see README.md
EOF
}

# Main function
main() {
    print_header "OpenBMC Build Script for ${BOARD_NAME}"
    
    log_info "Rockchip RK3568 Quad-core Cortex-A55 @ 2.0GHz"
    log_info "ROC-RK3568-PC Open Source Board"
    echo ""
    
    # Parse command line arguments
    case "${1:-}" in
        --deps)
            install_dependencies
            ;;
        --clone)
            setup_git
            clone_openbmc
            ;;
        --configure)
            setup_build
            configure_openbmc
            ;;
        --build)
            build_openbmc
            generate_manifest
            ;;
        --check)
            check_requirements
            ;;
        --all|"")
            check_requirements || exit 1
            install_dependencies
            setup_git
            clone_openbmc
            setup_build
            configure_openbmc
            build_openbmc
            generate_manifest
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
    
    print_header "Build Process Completed"
    log_success "Output directory: ${BUILD_DIR}"
    log_success "Check ${BUILD_DIR}/BUILD_MANIFEST.md for details"
}

# Run main function
main "$@"
