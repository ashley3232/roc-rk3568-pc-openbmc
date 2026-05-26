# 👤 用户使用指南

## 🎯 你的目标

创建一个 GitHub 项目并自动编译 OpenBMC 固件！

---

## ⚡ 立即开始（5分钟）

### 第一步：打开终端

在项目中打开终端或命令行工具。

### 第二步：运行设置脚本

```bash
cd /workspace/projects
chmod +x scripts/interactive_github_setup.sh
./scripts/interactive_github_setup.sh
```

### 第三步：按照提示操作

脚本会引导你完成：
1. ✅ 检查环境
2. ✅ 登录 GitHub（浏览器认证）
3. ✅ 创建仓库
4. ✅ 推送代码
5. ✅ 配置自动构建

### 第四步：等待完成

大约需要 1-2 分钟完成设置。

---

## 🔐 GitHub 认证

脚本会打开浏览器让你登录 GitHub：

1. **选择 "GitHub.com"**
2. **选择 "HTTPS"**
3. **选择 "Login with web browser"**
4. **在浏览器中完成登录**

如果浏览器没有自动打开，脚本会显示一个链接让你手动访问。

---

## 🎉 设置完成！

脚本完成后，你会看到：

```
📦 仓库地址: https://github.com/ashley32/roc-rk3568-pc-openbmc
🔧 Actions: https://github.com/ashley32/roc-rk3568-pc-openbmc/actions
```

---

## 🚀 启动第一次编译

### 方法一：网页操作

1. 访问: https://github.com/ashley32/roc-rk3568-pc-openbmc
2. 点击 **Actions** 标签
3. 点击 **Build OpenBMC** 工作流
4. 点击 **Run workflow** 按钮
5. 选择 **main** 分支
6. 点击 **Run workflow**

### 方法二：命令行操作

```bash
# 查看 Actions
gh run list

# 运行构建
gh workflow run build-openbmc
```

---

## ⏱️ 等待编译

编译需要 **2-4 小时**！

### 查看进度

- 网页：点击 Actions → 查看日志
- 命令行：`gh run watch`

### 完成后

1. 进入 Actions 标签
2. 选择完成的构建
3. 点击 **Artifacts**
4. 下载构建产物

---

## 🔧 后续使用

### 推送更新

```bash
git add .
git commit -m "Your changes"
git push origin main
```

每次推送都会自动触发构建！

### 查看构建状态

```bash
gh run list
```

### 清理和重新构建

在 Actions 页面：
1. 选择构建
2. 点击 "Re-run all jobs"

---

## ⚠️ 重要提醒

### 🔐 安全提醒

你刚才提供的 GitHub 密码已暴露！

**请立即**：
1. 访问 https://github.com/settings/security
2. 更改密码
3. 启用双因素认证 (2FA)

### 📝 建议使用 Personal Access Token

以后推送代码时，使用 token 而不是密码：

```bash
gh auth refresh -h github.com -s repo
```

---

## 📖 更多文档

查看这些文档了解更多：

- **GITHUB_QUICK_START.md** - 快速开始指南
- **GITHUB_SETUP_GUIDE.md** - 详细设置教程
- **README_OPENBMC.md** - OpenBMC 完整指南
- **QUICKSTART.md** - 快速入门

---

## ❓ 遇到问题？

### 问题 1：gh auth login 失败

**解决方法**:
```bash
gh auth logout
gh auth login
```

### 问题 2：仓库已存在

**解决方法**:
```bash
# 选项1：删除旧仓库
gh repo delete ashley32/roc-rk3568-pc-openbmc

# 选项2：使用新名称
# 修改脚本中的 REPO_NAME
```

### 问题 3：推送被拒绝

**解决方法**:
```bash
# 检查远程地址
git remote -v

# 如果不对，修正
git remote set-url origin https://github.com/ashley32/roc-rk3568-pc-openbmc.git

# 重新推送
git push -u origin main --force
```

---

## 🎊 恭喜！

你已完成所有设置！

### 你的成果

- ✅ GitHub 仓库已创建
- ✅ 代码已推送
- ✅ CI/CD 已配置
- ✅ 自动构建已就绪

### 下一步

1. 🔨 运行第一次构建
2. ⏰ 等待编译完成（2-4小时）
3. 📥 下载构建产物
4. 🔧 烧录固件
5. 🎉 开始使用 OpenBMC！

---

## 📞 获取帮助

- 📖 查看文档: `*.md` 文件
- 💬 GitHub Issues: 在仓库中创建 Issue
- 🌐 在线资源: https://github.com/openbmc/docs

---

**祝你使用愉快！** 🚀

> 📅 日期: 2024
> 🎯 目标: ROC-RK3568-PC OpenBMC
> ✅ 状态: 准备就绪
