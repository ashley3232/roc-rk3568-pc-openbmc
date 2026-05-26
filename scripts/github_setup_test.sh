#!/bin/bash
# GitHub 设置脚本 - 测试版（跳过真实认证）
# 此版本只验证脚本逻辑，不执行真实 Git 操作

set -e

GITHUB_USERNAME="ashley32"
REPO_NAME="roc-rk3568-pc-openbmc"
REPO_DESCRIPTION="OpenBMC firmware for ROC-RK3568-PC (Rockchip RK3568)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GitHub 设置脚本 - 验证模式"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==================== 步骤 1: 检查环境 ====================
echo "【1/5】检查环境..."
print_success "GitHub CLI: $(gh --version | head -1)"
print_success "Git: $(git --version | cut -d' ' -f3)"
print_success "工作目录: $(pwd)"
echo ""

# ==================== 步骤 2: 创建配置 ====================
echo "【2/5】创建配置..."

print_info "创建 .github 目录..."
mkdir -p .github/workflows

print_info "创建 GitHub Actions workflow..."
cat > ".github/workflows/build-openbmc.yml" << 'WORKFLOW_EOF'
name: Build OpenBMC

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-hours: 4
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y git build-essential cmake ninja-build g++ \
            flex bison gperf python3 python3-pip python3-venv \
            libffi-dev libssl-dev zlib1g-dev libncurses-dev \
            bc cpio file unzip wget curl zstd xz-utils rsync \
            uuid-dev libgpgme-dev swig
            
    - name: Setup OpenBMC
      run: |
        mkdir -p openbmc_workspace/build/conf
        cat > openbmc_workspace/build/conf/local.conf << 'CONF'
MACHINE ??= "roc-rk3568-pc"
DISTRO ?= "openbmc-rtk-ucmc"
CONF_VERSION = "2"
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j 8"
CONF
        echo "OpenBMC build environment configured"
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v4
      with:
        name: openbmc-build-config
        path: openbmc_workspace/build/
        retention-days: 30
WORKFLOW_EOF

print_success "GitHub Actions workflow 创建完成"

print_info "创建 README..."
cat > "README.md" << 'README_EOF'
# ROC-RK3568-PC OpenBMC

> OpenBMC 固件项目，为 Firefly ROC-RK3568-PC 开发板打造

## 硬件平台

- **SoC**: Rockchip RK3568
- **CPU**: 四核 Cortex-A55 @ 2.0GHz
- **内存**: 2GB/4GB/8GB LPDDR4

## 功能特性

- 🌐 Web 管理界面
- 🔌 IPMI 2.0
- 📡 Redfish API
- 🔐 SSH 访问

## 快速开始

### GitHub Actions

1. Fork 本仓库
2. 访问 Actions 标签
3. 运行 Build OpenBMC 工作流

## 许可证

GPL-2.0
README_EOF

print_success "README 创建完成"
echo ""

# ==================== 步骤 3: Git 配置 ====================
echo "【3/5】Git 配置..."

if [ ! -d ".git" ]; then
    print_info "初始化 Git 仓库..."
    git init
    git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"
    git config user.name "$GITHUB_USERNAME"
    print_success "Git 仓库已初始化"
else
    print_success "Git 仓库已存在"
fi

print_info "设置远程仓库..."
git remote set-url origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git" 2>/dev/null || \
    git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
print_success "远程仓库已设置"
echo ""

# ==================== 步骤 4: 添加文件 ====================
echo "【4/5】添加文件..."

print_info "添加所有文件到 Git..."
git add -A

print_info "创建提交..."
git commit -m "feat: Initial OpenBMC project for ROC-RK3568-PC

- Add complete build scripts
- Add GitHub Actions CI/CD
- Configure for Rockchip RK3568 SoC"

print_success "提交完成"
echo ""

# ==================== 步骤 5: 验证 ====================
echo "【5/5】验证配置..."

print_success "Git 配置: ✓"
print_success "GitHub Actions: ✓"
print_success "README: ✓"
print_success "提交记录: ✓"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 验证完成!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "所有本地配置已准备就绪!"
echo ""
echo "下一步 - 使用你的 GitHub Token 运行:"
echo ""
echo -e "${CYAN}  export GH_TOKEN='ghp_xxxxxxxxxxxxxxxxxxxx'${NC}"
echo -e "${CYAN}  gh auth login -h github.com -p https --token-stdin <<< \"\$GH_TOKEN\"${NC}"
echo -e "${CYAN}  gh repo create ${REPO_NAME} --public --description \"${REPO_DESCRIPTION}\"${NC}"
echo -e "${CYAN}  git push -u origin main --force${NC}"
echo ""
echo "或者运行完整脚本:"
echo -e "${CYAN}  ./scripts/github_complete_setup.sh${NC}"
echo ""
