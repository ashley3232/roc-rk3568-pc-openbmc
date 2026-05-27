# GitHub Actions Workflow 创建指南

## ⚠️ Token 权限问题

你的 Token 缺少 `workflow` 权限，无法自动创建 GitHub Actions workflow 文件。

## 🔧 解决方案（选择其一）

### 方案 1：手动创建 Workflow（推荐）

#### 第一步：访问 GitHub 创建文件

1. 打开: https://github.com/ashley3232/roc-rk3568-pc-openbmc
2. 点击 **"Add file"** → **"Create new file"**

#### 第二步：创建文件

1. 文件名输入: `.github/workflows/build-openbmc.yml`
2. 复制以下内容到文件内容框:

```yaml
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
```

#### 第三步：提交文件

1. 点击 **"Commit changes..."**
2. 选择 **"Commit directly to the main branch"**
3. 点击 **"Commit changes"**

---

### 方案 2：重新生成 Token（完整权限）

#### 第一步：撤销旧 Token

1. 访问: https://github.com/settings/tokens
2. 找到你的 Token
3. 点击 **"Delete"**

#### 第二步：创建新 Token

1. 点击 **"Generate new token (classic)"**
2. 填写:
   - Note: `openbmc-full`
   - Expiration: `90 days`
   - Scopes: 勾选 ✅
     - `repo` (全部)
     - `workflow` ⭐ **重要！**
     - `read:org`

3. 点击 **"Generate token"**
4. **复制新 Token**

#### 第三步：推送 Workflow

```bash
cd /workspace/projects
git push origin main
```

---

## 🎉 完成后验证

1. 访问: https://github.com/ashley3232/roc-rk3568-pc-openbmc
2. 查看 **Actions** 标签
3. 应该看到 **"Build OpenBMC"** workflow
4. 点击 **"Run workflow"** 启动编译

---

## 📊 当前状态

✅ **已完成:**
- ✅ 代码已推送到 GitHub
- ✅ 仓库已创建
- ✅ README 已生成

⏳ **待完成:**
- ⏳ GitHub Actions workflow（需手动或新 Token）

---

## 🚀 下一步

无论选择哪个方案，完成后：

1. 访问仓库: https://github.com/ashley3232/roc-rk3568-pc-openbmc
2. 点击 **Actions**
3. 点击 **"Build OpenBMC"**
4. 点击 **"Run workflow"**
5. 等待 2-4 小时编译完成

---

## 📞 需要帮助？

- 📖 GitHub Actions 文档: https://docs.github.com/en/actions
- 💬 GitHub Community: https://github.community/

---

**方案 1 最快（2分钟），方案 2 最完整！**
