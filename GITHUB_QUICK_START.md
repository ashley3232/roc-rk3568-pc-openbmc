# GitHub 项目创建 - 快速指南

## ✅ 项目准备完成！

你的 OpenBMC 项目已经准备好推送到 GitHub 了！

---

## 🚀 立即开始（3分钟）

### 方法一：交互式设置（推荐）

运行以下命令：

```bash
cd /workspace/projects
chmod +x scripts/interactive_github_setup.sh
./scripts/interactive_github_setup.sh
```

这个脚本会：
1. ✅ 检查 Git 和 GitHub CLI
2. ✅ 引导你登录 GitHub
3. ✅ 创建仓库
4. ✅ 推送所有文件
5. ✅ 配置 GitHub Actions

### 方法二：手动操作

#### 第一步：安装 GitHub CLI

```bash
sudo apt-get update
sudo apt-get install -y gh
```

#### 第二步：登录 GitHub

```bash
gh auth login
# 选择 GitHub.com
# 选择 HTTPS
# 选择 Login with web browser
```

#### 第三步：运行推送脚本

```bash
cd /workspace/projects
chmod +x scripts/push_to_github.sh
./scripts/push_to_github.sh
```

---

## 📋 仓库信息

| 项目 | 值 |
|------|------|
| **用户名** | ashley32 |
| **仓库名** | roc-rk3568-pc-openbmc |
| **描述** | OpenBMC firmware for ROC-RK3568-PC |
| **可见性** | Public (公开) |
| **仓库URL** | https://github.com/ashley32/roc-rk3568-pc-openbmc |

---

## 🎯 创建的脚本

| 脚本 | 功能 | 难度 |
|------|------|------|
| `interactive_github_setup.sh` | 交互式引导设置 | ⭐ |
| `push_to_github.sh` | 快速推送 | ⭐⭐ |
| `github_setup.sh` | 完整配置 | ⭐⭐⭐ |

---

## 📦 将包含的内容

推送到 GitHub 的文件：

```
roc-rk3568-pc-openbmc/
├── .github/
│   └── workflows/
│       └── build-openbmc.yml    # 🆕 CI/CD 自动构建
├── scripts/
│   ├── build_openbmc.sh         # OpenBMC 编译脚本
│   ├── validate_build.sh        # 验证工具
│   ├── github_setup.sh          # GitHub 配置
│   ├── push_to_github.sh        # 快速推送
│   └── interactive_github_setup.sh  # 🆕 交互式设置
├── README.md                    # 项目主页 🆕
├── README_OPENBMC.md            # 完整指南
├── QUICKSTART.md                # 快速入门
├── CHECKLIST.md                 # 检查清单
├── hardware_spec.txt            # 硬件规格
└── LICENSE                      # 许可证
```

---

## 🔧 GitHub Actions 功能

创建的 CI/CD 工作流将：

1. **自动构建** - 每次推送到 main 分支自动运行
2. **环境配置** - 安装所有编译依赖
3. **构建 OpenBMC** - 配置 Yocto/OpenBMC 环境
4. **生成产物** - 创建可下载的构建文件
5. **保存日志** - 保留构建过程记录

### 工作流特点

- ✅ **自动触发**: 推送代码时自动运行
- ✅ **手动触发**: 可以手动选择分支运行
- ✅ **并行构建**: 支持多任务构建
- ✅ **产物保存**: 30天保留构建产物
- ✅ **详细日志**: 完整的构建日志

---

## 📖 文档说明

推送到 GitHub 后，你的仓库将包含：

### 英文文档（自动生成）
- **README.md** - GitHub 项目主页，适合国外社区

### 中文文档
- **README_OPENBMC.md** - OpenBMC 完整使用指南
- **QUICKSTART.md** - 5分钟快速入门
- **CHECKLIST.md** - 编译检查清单
- **hardware_spec.txt** - 硬件规格详情

### 操作指南
- **GITHUB_SETUP_GUIDE.md** - GitHub 使用教程

---

## 🎉 完成后你将拥有

1. **GitHub 仓库** - 代码云端存储
2. **CI/CD 自动构建** - 每次推送自动编译
3. **完整文档** - 专业的项目说明
4. **下载页面** - GitHub Releases 分发固件
5. **Issue 追踪** - 问题反馈和跟踪

---

## 📝 GitHub 日常使用

### 查看构建状态

```bash
gh run list
```

### 查看构建日志

```bash
gh run view <run-id> --log
```

### 创建 Release

```bash
gh release create v1.0.0 \
    --title "OpenBMC v1.0.0" \
    --notes "Initial release for ROC-RK3568-PC"
```

### 推送更新

```bash
git add .
git commit -m "Update description"
git push origin main
```

---

## 🔐 安全提醒

⚠️ **重要**: 你刚才提供的密码 `ly123456@bc` 已经暴露！

**建议立即**：
1. 更改 GitHub 密码
2. 启用两步验证 (2FA)
3. 使用 Personal Access Token 代替密码

### 创建 Access Token

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 选择权限：
   - ✅ repo (Full control)
   - ✅ workflow
4. 生成 token 并保存

---

## ❓ 常见问题

### Q: GitHub CLI 认证失败？

**解决方法**:
```bash
# 清除认证
gh auth logout

# 重新登录
gh auth login
```

### Q: 仓库已存在？

**解决方法**:
```bash
# 删除旧仓库
gh repo delete ashley32/roc-rk3568-pc-openbmc

# 或者使用现有仓库
# 修改脚本中的 REPO_NAME
```

### Q: 推送被拒绝？

**解决方法**:
```bash
# 查看远程地址
git remote -v

# 应该是：
# origin  https://github.com/ashley32/roc-rk3568-pc-openbmc.git

# 如果不对，修正：
git remote set-url origin https://github.com/ashley32/roc-rk3568-pc-openbmc.git
```

---

## 🎯 快速参考

### 最重要的命令

| 操作 | 命令 |
|------|------|
| **登录 GitHub** | `gh auth login` |
| **查看状态** | `gh auth status` |
| **创建仓库** | `gh repo create <name>` |
| **推送代码** | `git push origin main` |
| **查看 Actions** | `gh run list` |
| **运行构建** | `gh workflow run build-openbmc` |

---

## 📞 获取帮助

- **GitHub CLI**: https://cli.github.com/
- **GitHub Actions**: https://docs.github.com/en/actions
- **OpenBMC**: https://github.com/openbmc/docs

---

## ✅ 下一步行动

1. **现在运行**:
   ```bash
   cd /workspace/projects
   ./scripts/interactive_github_setup.sh
   ```

2. **访问你的仓库**:
   ```
   https://github.com/ashley32/roc-rk3568-pc-openbmc
   ```

3. **运行第一次构建**:
   - 点击 Actions 标签
   - 选择 Build OpenBMC
   - 点击 Run workflow

4. **等待完成** (2-4小时)

---

**祝你使用愉快！** 🎉

> 📅 创建日期: 2024
> 👤 用户: ashley32
> 🎯 项目: ROC-RK3568-PC OpenBMC
> 🔧 状态: 准备就绪
