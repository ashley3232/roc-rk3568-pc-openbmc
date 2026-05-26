# GitHub Token 获取指南

## ⚠️ 为什么需要 Token？

GitHub 已于 2021 年不再支持密码认证，必须使用 **Personal Access Token (PAT)** 来访问 GitHub API 和 CLI。

---

## 🔑 获取 GitHub Personal Access Token

### 步骤 1：访问 Token 设置页面

打开浏览器访问：
```
https://github.com/settings/tokens
```

或者依次点击：
1. 右上角头像 → **Settings**
2. 左侧菜单 → **Developer settings**
3. 点击 **Personal access tokens** → **Tokens (classic)**
4. 点击 **Generate new token** → **Generate new token (classic)**

### 步骤 2：配置 Token

在生成 Token 页面，填写以下信息：

#### 基本信息
- **Note** (名称): `openbmc-build` (或其他描述性名称)
- **Expiration** (过期时间): 选择 `90 days` 或 `No expiration`

#### 权限选择 (Select scopes)

✅ **必选权限**:
- ✅ `repo` → `repo:all` (Full control of private repositories)

✅ **建议权限**:
- ✅ `workflow` (Update GitHub Action workflows)

不要勾选其他权限，保持最小权限原则。

### 步骤 3：生成 Token

1. 点击 **Generate token** 按钮
2. **立即复制 Token**（页面刷新后会消失）
3. Token 格式类似：`ghp_xxxxxxxxxxxxxxxxxxxx`

### 步骤 4：保存 Token

⚠️ **重要**: Token 只显示一次，请立即保存！

将 Token 保存在安全的地方，例如：
- 密码管理器
- 环境变量
- 安全的笔记应用

---

## 🚀 使用 Token 运行脚本

### 方法一：交互式输入

```bash
cd /workspace/projects
chmod +x scripts/github_auth_and_setup.sh
./scripts/github_auth_and_setup.sh
```

脚本会提示你输入 Token。

### 方法二：环境变量

```bash
export GH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
cd /workspace/projects
./scripts/github_auth_and_setup.sh
```

### 方法三：管道输入

```bash
echo "ghp_xxxxxxxxxxxxxxxxxxxx" | ./scripts/github_auth_and_setup.sh
```

---

## 🔧 直接使用 gh CLI

### 认证

```bash
# 方式1：交互式
gh auth login

# 方式2：使用 Token
echo "ghp_xxxxxxxxxxxxxxxxxxxx" | gh auth login -h github.com -p https --token-stdin
```

### 验证认证状态

```bash
gh auth status
```

应该显示：
```
✓ Logged in to github.com as ashley32
```

### 创建仓库

```bash
gh repo create roc-rk3568-pc-openbmc \
    --public \
    --description "OpenBMC firmware for ROC-RK3568-PC"
```

---

## ❓ 常见问题

### Q: Token 过期了怎么办？

**解决方法**:
1. 访问 https://github.com/settings/tokens
2. 点击旧 Token
3. 点击 "Regenerate token"
4. 使用新 Token 重新认证

### Q: Token 权限不够？

**解决方法**:
1. 删除旧 Token
2. 创建新 Token，确保勾选 `repo` 权限
3. 重新认证

### Q: 如何撤销 Token？

1. 访问 https://github.com/settings/tokens
2. 点击要撤销的 Token
3. 点击 "Delete token"
4. 确认删除

### Q: Token 泄露了怎么办？

⚠️ **立即行动**:
1. 访问 https://github.com/settings/tokens
2. 删除泄露的 Token
3. 创建新 Token
4. 重新认证所有应用

---

## 🛡️ 安全最佳实践

### ✅ 推荐做法

1. **定期轮换**: 每 90 天生成新 Token
2. **最小权限**: 只授予必需的权限
3. **环境变量**: 使用 `GH_TOKEN` 环境变量而非硬编码
4. **安全存储**: 保存在密码管理器中

### ❌ 不要做

1. ❌ 不要在代码中硬编码 Token
2. ❌ 不要在聊天中分享 Token
3. ❌ 不要使用过期太久的 Token
4. ❌ 不要授予过多权限

---

## 📋 Token 权限说明

| 权限 | 说明 | 是否必需 |
|------|------|----------|
| `repo` | 完整控制私有仓库 | ✅ 必需 |
| `workflow` | 更新 GitHub Actions | ⚠️ 推荐 |
| `read:org` | 读取组织信息 | ❌ 可选 |
| `gist` | 管理 Gist | ❌ 不需要 |

---

## 🎯 快速检查清单

在运行脚本之前，确认：

- [ ] ✅ 已访问 https://github.com/settings/tokens
- [ ] ✅ 已创建 Personal Access Token
- [ ] ✅ Token 具有 `repo` 权限
- [ ] ✅ 已复制 Token
- [ ] ✅ Token 已保存到安全位置

---

## 📞 获取帮助

- **GitHub 文档**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
- **GitHub CLI 文档**: https://cli.github.com/manual/auth_login

---

**安全提示**: 永远不要在公开渠道分享你的 Token！
