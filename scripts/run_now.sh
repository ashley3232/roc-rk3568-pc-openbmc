#!/bin/bash
# 一键运行脚本 - 完成后请运行这个！
# 用法: ./scripts/run_now.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎯 OpenBMC GitHub 仓库创建"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 Token
if [ -z "$1" ]; then
    echo "❌ 请提供 GitHub Token"
    echo ""
    echo "使用方法:"
    echo "  ./scripts/run_now.sh ghp_xxxxxxxxxxxxxxxxxxxx"
    echo ""
    echo "如何获取 Token:"
    echo "  1. 访问: https://github.com/settings/tokens"
    echo "  2. 点击 'Generate new token (classic)'"
    echo "  3. 勾选 'repo' 权限"
    echo "  4. 生成并复制 Token"
    echo ""
    exit 1
fi

GH_TOKEN="$1"
GITHUB_USERNAME="ashley32"
REPO_NAME="roc-rk3568-pc-openbmc"

echo "🔐 GitHub 用户名: $GITHUB_USERNAME"
echo "📦 仓库名称: $REPO_NAME"
echo ""

# 1. 登录
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "【1/3】登录 GitHub..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$GH_TOKEN" | gh auth login -h github.com -p https --token-stdin

if [ $? -eq 0 ]; then
    echo "✅ 登录成功!"
else
    echo "❌ 登录失败，请检查 Token"
    exit 1
fi
echo ""

# 2. 创建仓库
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "【2/3】创建仓库..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
gh repo create "${REPO_NAME}" \
    --public \
    --description "OpenBMC firmware for ROC-RK3568-PC (Rockchip RK3568)" 2>/dev/null || \
    echo "仓库可能已存在，跳过创建"

echo "✅ 仓库已就绪!"
echo ""

# 3. 推送
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "【3/3】推送代码..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git remote set-url origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
git push -u origin main --force

if [ $? -eq 0 ]; then
    echo "✅ 推送成功!"
else
    echo "❌ 推送失败"
    exit 1
fi
echo ""

# 完成
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 完成!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 仓库: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo "✅ Actions: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/actions"
echo ""
echo "下一步:"
echo "1. 访问仓库查看代码"
echo "2. 点击 Actions → Build OpenBMC"
echo "3. 点击 Run workflow"
echo "4. 等待 2-4 小时编译完成"
echo ""
