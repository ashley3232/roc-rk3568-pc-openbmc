#!/bin/bash
# 自动 GitHub 设置脚本 - 使用环境变量 GH_TOKEN
# 用法: GH_TOKEN="your-token" ./scripts/auto_github_setup.sh

set -e

GITHUB_USERNAME="ashley32"
REPO_NAME="roc-rk3568-pc-openbmc"
REPO_DESCRIPTION="OpenBMC firmware for ROC-RK3568-PC (Rockchip RK3568)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "========================================================================"
echo " GitHub 自动设置 - OpenBMC 项目"
echo "========================================================================"
echo ""

# 检查 GitHub CLI
log_info "检查 GitHub CLI..."
if ! command -v gh &> /dev/null; then
    log_info "安装 GitHub CLI..."
    apt-get update && apt-get install -y gh
fi
log_success "GitHub CLI: $(gh --version | head -1)"
echo ""

# 检查 Token
if [ -z "$GH_TOKEN" ]; then
    echo ""
    log_error "错误: 未设置 GH_TOKEN 环境变量"
    echo ""
    echo "请先设置 Token:"
    echo ""
    echo "1. 获取 Token:"
    echo "   访问: https://github.com/settings/tokens"
    echo "   点击 'Generate new token (classic)'"
    echo "   勾选 'repo' 权限"
    echo "   生成并复制 Token"
    echo ""
    echo "2. 运行脚本:"
    echo "   export GH_TOKEN='your-token-here'"
    echo "   ./scripts/auto_github_setup.sh"
    echo ""
    exit 1
fi

log_info "检测到 GH_TOKEN，开始认证..."
echo ""

# 认证
if gh auth status &> /dev/null; then
    log_success "已经登录到 GitHub"
else
    log_info "正在登录 GitHub..."
    echo "$GH_TOKEN" | gh auth login -h github.com -p https --token-stdin
    
    if [ $? -ne 0 ]; then
        log_error "GitHub 认证失败"
        exit 1
    fi
    log_success "GitHub 认证成功!"
fi
echo ""

# Git 配置
log_info "配置 Git..."
git config --global user.email "${GITHUB_USERNAME}@users.noreply.github.com"
git config --global user.name "$GITHUB_USERNAME"
log_success "Git 配置完成"
echo ""

# 初始化 Git
log_info "初始化 Git 仓库..."
if [ ! -d ".git" ]; then
    git init
    git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"
    git config user.name "$GITHUB_USERNAME"
    log_success "Git 仓库已初始化"
else
    log_info "Git 仓库已存在"
fi
echo ""

# 创建 .github 目录
log_info "创建 GitHub Actions 配置..."
mkdir -p .github/workflows

cat > ".github/workflows/build-openbmc.yml" << 'EOF'
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
        sudo apt-get install -y \
            git build-essential cmake ninja-build g++ \
            flex bison gperf python3 python3-pip \
            python3-venv libffi-dev libssl-dev \
            zlib1g-dev libncurses-dev bc cpio \
            file unzip wget curl zstd xz-utils \
            rsync uuid-dev libgpgme-dev swig
            
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
EOF

log_success "GitHub Actions workflow 创建完成"
echo ""

# 创建 README
cat > "README.md" << 'EOF'
# ROC-RK3568-PC OpenBMC

> OpenBMC 固件项目，为 Firefly ROC-RK3568-PC 开发板打造

## 硬件平台

- **SoC**: Rockchip RK3568
- **CPU**: 四核 Cortex-A55 @ 2.0GHz
- **内存**: 2GB/4GB/8GB LPDDR4
- **网络**: 双千兆网口, WiFi 6

## 功能特性

- 🌐 Web 管理界面
- 🔌 IPMI 2.0
- 📡 Redfish API
- 🔐 SSH 访问
- 📊 传感器监控

## 快速开始

### GitHub Actions

1. Fork 本仓库
2. 访问 Actions 标签
3. 运行 Build OpenBMC 工作流

### 本地编译

```bash
./scripts/build_openbmc.sh --all
```

## 许可证

GPL-2.0
EOF

log_success "README 创建完成"
echo ""

# 创建仓库
log_info "创建 GitHub 仓库..."
if gh repo view "${GITHUB_USERNAME}/${REPO_NAME}" &> /dev/null; then
    log_info "仓库已存在"
else
    gh repo create "${REPO_NAME}" \
        --public \
        --description "${REPO_DESCRIPTION}"
    log_success "仓库创建成功"
fi
echo ""

# 设置远程仓库
log_info "设置远程仓库..."
git remote set-url origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git" 2>/dev/null || \
    git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
log_success "远程仓库已设置"
echo ""

# 添加文件并提交
log_info "添加文件..."
git add -A

log_info "提交更改..."
git commit -m "feat: Initial OpenBMC project for ROC-RK3568-PC

- Add complete build scripts
- Add GitHub Actions CI/CD
- Configure for Rockchip RK3568 SoC

Features:
- Web management interface
- IPMI 2.0 support
- Redfish API"

log_success "提交完成"
echo ""

# 推送
log_info "推送到 GitHub..."
git branch -M main

if git push -u origin main --force; then
    log_success "推送成功!"
else
    log_error "推送失败"
    exit 1
fi

echo ""
echo "========================================================================"
echo " 🎉 设置完成!"
echo "========================================================================"
echo ""
log_success "仓库: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
log_success "Actions: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/actions"
echo ""
echo "下一步:"
echo "1. 访问仓库 → https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo "2. 点击 Actions → 运行 Build OpenBMC"
echo "3. 等待构建完成 (2-4小时)"
echo ""
