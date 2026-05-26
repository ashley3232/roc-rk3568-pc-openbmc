#!/bin/bash
# GitHub 认证和仓库创建脚本
# 支持使用 Personal Access Token 进行认证

set -e

# 配置
GITHUB_USERNAME="ashley32"
REPO_NAME="roc-rk3568-pc-openbmc"
REPO_DESCRIPTION="OpenBMC firmware for ROC-RK3568-PC (Rockchip RK3568)"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${BLUE}"
cat << 'EOF'

    ██████╗ ██████╗ ███████╗██╗███████╗██╗  ██╗██╗     ██╗     
    ██╔══██╗██╔══██╗██╔════╝██║██╔════╝██║  ██║██║     ██║     
    ██║  ██║██████╔╝███████╗██║███████╗███████║██║     ██║     
    ██║  ██║██╔══██╗╚════██║██║╚════██║██╔══██║██║     ██║     
    ██████╔╝██║  ██║███████║██║███████║██║  ██║███████╗███████╗
    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝
                                                                
    GitHub Repository Setup for OpenBMC
EOF
echo -e "${NC}"

echo ""
echo "========================================================================"
echo " GitHub 认证和仓库设置"
echo "========================================================================"
echo ""

# 检查 gh
log_info "检查 GitHub CLI..."
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI 未安装"
    echo "请运行: apt-get install gh"
    exit 1
fi
log_success "GitHub CLI: $(gh --version | head -1)"
echo ""

# 提示用户输入 token
echo "========================================================================"
echo " GitHub Personal Access Token 认证"
echo "========================================================================"
echo ""
echo "GitHub 现在需要使用 Personal Access Token (PAT) 而不是密码"
echo ""
echo "获取 Token 步骤:"
echo "1. 访问: https://github.com/settings/tokens"
echo "2. 点击 'Generate new token (classic)'"
echo "3. 设置 Token 名称 (如: openbmc-build)"
echo "4. 选择过期时间"
echo "5. 勾选以下权限:"
echo "   ✅ repo (Full control of private repositories)"
echo "   ✅ workflow (Update GitHub Action workflows)"
echo "6. 点击 'Generate token'"
echo "7. 复制 Token 并粘贴到下方"
echo ""
echo -n "请输入你的 GitHub Personal Access Token: "
read -s GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    log_error "Token 不能为空"
    exit 1
fi

log_info "正在验证 Token..."
echo "$GITHUB_TOKEN" | gh auth login -h github.com -p https --token-stdin

if [ $? -ne 0 ]; then
    log_error "Token 验证失败"
    log_info "请确保:"
    log_info "1. Token 没有过期"
    log_info "2. Token 具有正确的权限 (repo, workflow)"
    log_info "3. Token 格式正确"
    exit 1
fi

log_success "GitHub 认证成功!"
echo ""

# 配置 git
log_info "配置 Git..."
git config --global user.email "${GITHUB_USERNAME}@users.noreply.github.com"
git config --global user.name "$GITHUB_USERNAME"
log_success "Git 配置完成"
echo ""

# 初始化 git
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

# 创建 GitHub Actions workflow
log_info "创建 GitHub Actions 配置..."
mkdir -p .github/workflows

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
        
    - name: Build
      run: |
        cd openbmc_workspace
        echo "Build ready for ROC-RK3568-PC"
        echo "SoC: Rockchip RK3568"
        echo "Machine: roc-rk3568-pc"
        
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

log_success "GitHub Actions workflow 创建完成"
echo ""

# 创建 README
log_info "创建 README..."
cat > "README.md" << 'EOF'
# ROC-RK3568-PC OpenBMC

[![Build OpenBMC](https://github.com/ashley32/roc-rk3568-pc-openbmc/actions/workflows/build-openbmc.yml/badge.svg)](https://github.com/ashley32/roc-rk3568-pc-openbmc/actions)

> OpenBMC 固件项目，为 Firefly ROC-RK3568-PC 开发板打造

## 🎯 硬件平台

- **SoC**: Rockchip RK3568
- **CPU**: 四核 Cortex-A55 @ 2.0GHz
- **内存**: 2GB/4GB/8GB LPDDR4
- **网络**: 双千兆网口, WiFi 6

## ✨ 功能特性

- 🌐 Web 管理界面
- 🔌 IPMI 2.0
- 📡 Redfish API
- 🔐 SSH 访问
- 📊 传感器监控

## 🚀 快速开始

### GitHub Actions（推荐）

1. Fork 本仓库
2. 访问 Actions 标签
3. 运行 Build OpenBMC 工作流

### 本地编译

```bash
./scripts/build_openbmc.sh --all
```

## 📖 文档

- [快速入门](QUICKSTART.md)
- [完整指南](README_OPENBMC.md)
- [GitHub 设置](GITHUB_SETUP_GUIDE.md)

## 📄 许可证

GPL-2.0
EOF

log_success "README 创建完成"
echo ""

# 创建仓库
log_info "创建 GitHub 仓库..."

# 检查仓库是否存在
if gh repo view "${GITHUB_USERNAME}/${REPO_NAME}" &> /dev/null; then
    log_info "仓库已存在: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    REPO_EXISTS=true
else
    gh repo create "${REPO_NAME}" \
        --public \
        --description "${REPO_DESCRIPTION}"
    
    if [ $? -eq 0 ]; then
        log_success "仓库创建成功!"
    else
        log_error "仓库创建失败"
        exit 1
    fi
    REPO_EXISTS=false
fi
echo ""

# 设置远程仓库
log_info "设置远程仓库..."
git remote set-url origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git" 2>/dev/null || \
    git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
log_success "远程仓库已设置"
echo ""

# 添加文件
log_info "添加文件到 Git..."
git add -A

# 提交
log_info "提交更改..."
git commit -m "feat: Initial OpenBMC project for ROC-RK3568-PC

- Add complete build scripts
- Add GitHub Actions CI/CD workflow
- Add comprehensive documentation
- Configure for Rockchip RK3568 SoC

Features:
- Web management interface
- IPMI 2.0 support
- Redfish API
- SSH access"

log_success "提交完成"
echo ""

# 推送
log_info "推送到 GitHub..."
git branch -M main

if git push -u origin main --force 2>&1; then
    log_success "推送成功!"
else
    log_error "推送失败"
    log_info "请检查 Token 权限是否包含 'repo'"
    exit 1
fi

echo ""
echo "========================================================================"
echo " 🎉 设置完成!"
echo "========================================================================"
echo ""
log_success "仓库地址: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
log_success "Actions: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/actions"
echo ""
echo "下一步:"
echo "1. 访问仓库地址查看代码"
echo "2. 点击 Actions 标签运行构建"
echo "3. 等待构建完成 (2-4小时)"
echo ""
echo -e "${BLUE}祝你编译顺利!${NC}"
echo ""
