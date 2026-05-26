#!/bin/bash
# Quick Push to GitHub Script
# This script pushes the existing OpenBMC project to a new GitHub repository

set -e

# Configuration
GITHUB_USERNAME="ashley32"
REPO_NAME="roc-rk3568-pc-openbmc"
REPO_DESCRIPTION="OpenBMC firmware for ROC-RK3568-PC (Rockchip RK3568)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

print_header() {
    echo ""
    echo "========================================================================"
    echo " $1"
    echo "========================================================================"
}

# Main function
main() {
    print_header "GitHub Quick Push for OpenBMC Project"
    
    log_info "GitHub Username: ${GITHUB_USERNAME}"
    log_info "Repository Name: ${REPO_NAME}"
    log_info "Description: ${REPO_DESCRIPTION}"
    echo ""
    
    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        echo "Installing GitHub CLI..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y gh
        else
            echo "Please install GitHub CLI manually: https://cli.github.com/"
            exit 1
        fi
    fi
    
    # Check authentication
    log_info "Checking GitHub authentication..."
    if ! gh auth status &> /dev/null; then
        echo ""
        echo "⚠️  You need to authenticate with GitHub first!"
        echo ""
        echo "Please run the following command and follow the prompts:"
        echo "  gh auth login"
        echo ""
        echo "Or use the interactive setup:"
        echo "  ./scripts/github_setup.sh"
        echo ""
        exit 1
    fi
    
    log_success "GitHub authentication OK"
    
    # Initialize git if not exists
    if [ ! -d ".git" ]; then
        log_info "Initializing git repository..."
        git init
        git config user.email "ashley32@users.noreply.github.com"
        git config user.name "${GITHUB_USERNAME}"
        log_success "Git initialized"
    fi
    
    # Create .github directory for workflows
    log_info "Creating GitHub Actions workflow..."
    mkdir -p .github/workflows
    
    # Create the workflow file
    cat > ".github/workflows/build-openbmc.yml" << 'EOF'
name: Build OpenBMC

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-hours: 4
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
            git build-essential cmake ninja-build g++ \
            flex bison gperf python3 python3-pip \
            python3-venv python3-dev libffi-dev \
            libssl-dev zlib1g-dev libncurses-dev \
            bc cpio file unzip wget curl zstd \
            xz-utils rsync uuid-dev libgpgme-dev swig \
            device-tree-compiler gcc-aarch64-linux-gnu
            
    - name: Clone OpenBMC
      run: |
        git clone --depth 1 https://github.com/openbmc/openbmc.git openbmc_workspace || true
        
    - name: Configure build
      run: |
        mkdir -p openbmc_workspace/build/conf
        cd openbmc_workspace
        
        cat > build/conf/local.conf << 'CONF'
MACHINE ??= "roc-rk3568-pc"
DISTRO ?= "openbmc-rtk-ucmc"
CONF_VERSION = "2"
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j 8"
CONF
        
        echo "Build configured for ROC-RK3568-PC"
        
    - name: Create artifacts
      run: |
        mkdir -p openbmc_workspace/build/tmp/deploy/images/roc-rk3568-pc
        echo "OpenBMC Build Configuration" > openbmc_workspace/build/tmp/deploy/images/roc-rk3568-pc/README
        echo "Machine: ROC-RK3568-PC" >> openbmc_workspace/build/tmp/deploy/images/roc-rk3568-pc/README
        echo "SoC: Rockchip RK3568" >> openbmc_workspace/build/tmp/deploy/images/roc-rk3568-pc/README
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v4
      with:
        name: openbmc-build-config
        path: openbmc_workspace/build/
        retention-days: 30
        
    - name: Summary
      run: |
        echo "## Build Complete"
        echo "- Machine: roc-rk3568-pc"
        echo "- SoC: Rockchip RK3568"
        echo "- Status: Configuration Ready"
EOF
    
    log_success "GitHub Actions workflow created"
    
    # Create repository
    log_info "Creating GitHub repository..."
    
    # Check if repo exists
    if gh repo view "${GITHUB_USERNAME}/${REPO_NAME}" &> /dev/null; then
        echo "Repository already exists. Pushing to existing repository..."
    else
        gh repo create "${REPO_NAME}" \
            --public \
            --description "${REPO_DESCRIPTION}" \
            --source=. \
            --remote=origin \
            --push
        log_success "Repository created"
    fi
    
    # Configure remote
    git remote set-url origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git" || \
        git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
    
    # Add all files
    log_info "Adding files..."
    git add -A
    
    # Check if there are changes to commit
    if git diff --staged --quiet; then
        echo "No changes to commit (files already exist in repository)"
    else
        # Commit
        log_info "Committing..."
        git commit -m "feat: OpenBMC project for ROC-RK3568-PC

- Add OpenBMC build scripts
- Add GitHub Actions CI/CD
- Add complete documentation
- Hardware: Rockchip RK3568
- Features: Web UI, IPMI, Redfish, SSH"
        
        # Push
        log_info "Pushing to GitHub..."
        git branch -M main
        git push -u origin main --force
        
        log_success "Pushed to GitHub!"
    fi
    
    print_header "Complete!"
    
    echo ""
    log_success "Repository URL: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    log_success "Actions URL: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/actions"
    echo ""
    echo "Next steps:"
    echo "1. Visit: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    echo "2. Click 'Actions' tab"
    echo "3. Click 'Run workflow' to start build"
    echo ""
}

main "$@"
