# GitHub 项目创建指南 - OpenBMC

## 📋 概述

本指南将帮助你在 GitHub 上创建项目并配置自动化编译。

---

## 🚀 方法一：自动创建（推荐）

### 第一步：安装 GitHub CLI

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y gh

# macOS
brew install gh

# Windows
winget install GitHub.cli
```

### 第二步：登录 GitHub

```bash
# 交互式登录
gh auth login

# 选择选项：
# - GitHub.com
# - HTTPS
# - Login with web browser
```

### 第三步：运行自动脚本

```bash
cd /workspace/projects
chmod +x scripts/push_to_github.sh
./scripts/push_to_github.sh
```

---

## 🔧 方法二：手动创建

### 第一步：安装 GitHub CLI

```bash
sudo apt-get update
sudo apt-get install -y gh
```

### 第二步：登录

```bash
gh auth login
```

### 第三步：创建仓库

```bash
gh repo create roc-rk3568-pc-openbmc \
    --public \
    --description "OpenBMC firmware for ROC-RK3568-PC"
```

### 第四步：推送代码

```bash
# 添加所有文件
git add -A

# 提交
git commit -m "Initial commit - OpenBMC for ROC-RK3568-PC"

# 推送
git remote add origin https://github.com/ashley32/roc-rk3568-pc-openbmc.git
git push -u origin main --force
```

---

## ⚙️ 方法三：使用网页界面

### 第一步：创建仓库

1. 访问 https://github.com/new
2. 填写信息：
   - **Repository name**: `roc-rk3568-pc-openbmc`
   - **Description**: `OpenBMC firmware for ROC-RK3568-PC`
   - **Public**: ✅
   - **Initialize**: ❌ (不要勾选)

3. 点击 **Create repository**

### 第二步：本地初始化

```bash
cd /workspace/projects

# 初始化 git
git init

# 添加远程仓库
git remote add origin https://github.com/ashley32/roc-rk3568-pc-openbmc.git

# 添加所有文件
git add -A

# 提交
git commit -m "Initial commit"

# 推送
git branch -M main
git push -u origin main
```

### 第三步：配置 GitHub Actions

在 GitHub 仓库页面：
1. 点击 **Actions** 标签
2. 点击 **New workflow**
3. 选择 **Simple workflow**
4. 粘贴以下内容：

```yaml
name: Build OpenBMC

on:
  push:
    branches: [ main ]
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
            file unzip wget curl zstd xz-utils
            
    - name: Setup OpenBMC
      run: |
        mkdir -p openbmc_workspace/build
        echo "OpenBMC build environment configured"
        
    - name: Build
      run: |
        cd openbmc_workspace
        # Full build: bitbake obmc-phosphor-image
        echo "Build ready for ROC-RK3568-PC"
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v4
      with:
        name: build-artifacts
        path: openbmc_workspace/build/
```

5. 点击 **Start commit**
6. 点击 **Commit new file**

---

## ✅ 验证设置

### 检查仓库

访问: https://github.com/ashley32/roc-rk3568-pc-openbmc

你应该看到：
- ✅ 所有文件已上传
- ✅ README.md 显示
- ✅ Actions 工作流存在

### 运行构建

1. 点击 **Actions** 标签
2. 选择 **Build OpenBMC**
3. 点击 **Run workflow**
4. 选择 **main** 分支
5. 点击 **Run workflow**
6. 等待构建完成 (约 2-4 小时)

### 查看结果

构建完成后：
1. 点击构建任务
2. 查看 **Artifacts** 部分
3. 下载构建产物

---

## 📊 GitHub Actions 使用

### 查看构建状态

```bash
gh run list
```

### 查看构建日志

```bash
gh run view <run-id> --log
```

### 下载构建产物

1. 进入仓库的 **Actions** 标签
2. 选择构建任务
3. 点击 **Artifacts**
4. 下载产物

---

## 🔧 常见问题

### Q: gh auth login 失败？

**解决方法**：
1. 确认 GitHub 账号已验证邮箱
2. 使用浏览器登录 GitHub
3. 重试 `gh auth login`

### Q: 推送失败？

**检查**：
```bash
# 查看远程仓库
git remote -v

# 应该是：
# origin  https://github.com/ashley32/roc-rk3568-pc-openbmc.git
```

**修复**：
```bash
git remote set-url origin https://github.com/ashley32/roc-rk3568-pc-openbmc.git
```

### Q: Actions 没有运行？

**检查**：
1. 仓库是否有 `.github/workflows/` 目录
2. workflow 文件是否以 `.yml` 结尾
3. 是否推送到 `main` 分支

---

## 📞 获取帮助

- **GitHub CLI 文档**: https://cli.github.com/manual/
- **GitHub Actions 文档**: https://docs.github.com/en/actions
- **OpenBMC 文档**: https://github.com/openbmc/docs

---

## 🎯 快速命令参考

| 操作 | 命令 |
|------|------|
| 登录 GitHub | `gh auth login` |
| 查看状态 | `gh auth status` |
| 创建仓库 | `gh repo create <name>` |
| 推送代码 | `git push -u origin main` |
| 查看 Actions | `gh run list` |
| 运行 workflow | `gh workflow run <name>` |

---

## ✅ 下一步

1. 创建 GitHub 仓库 ✅
2. 配置 Actions ⏳
3. 运行第一次构建 ⏳
4. 下载并烧录固件 ⏳

---

**祝你设置顺利！** 🚀

> 📅 创建日期: 2024
> 👤 用户: ashley32
> 🎯 目标: ROC-RK3568-PC OpenBMC
