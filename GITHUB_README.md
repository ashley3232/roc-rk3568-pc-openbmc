# ROC-RK3568-PC OpenBMC

[![Build OpenBMC](https://github.com/ashley32/roc-rk3568-pc-openbmc/actions/workflows/build-openbmc.yml/badge.svg)](https://github.com/ashley32/roc-rk3568-pc-openbmc/actions)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL%202.0-blue.svg)](LICENSE)

> OpenBMC 固件项目，为 Firefly ROC-RK3568-PC 开源主板打造

## 🎯 项目简介

本项目为 **Firefly ROC-RK3568-PC** 开发板编译 OpenBMC 固件，基于 Rockchip RK3568 芯片。

### 硬件平台

| 组件 | 规格 |
|------|------|
| **SoC** | Rockchip RK3568 |
| **CPU** | 四核 Cortex-A55 @ 2.0GHz |
| **GPU** | ARM Mali-G52 2EE |
| **NPU** | 0.8 TOPS |
| **内存** | 2GB/4GB/8GB LPDDR4 |
| **存储** | eMMC, SPI Flash, M.2 NVMe, SATA |
| **网络** | 双千兆网口, WiFi 6 |
| **接口** | USB 3.0, USB-C, HDMI, MIPI, eDP |

## ✨ 功能特性

- 🌐 **Web 管理界面** - 通过浏览器管理 BMC
- 🔌 **IPMI 2.0** - 远程电源管理和控制台重定向
- 📡 **Redfish API** - RESTful API 接口
- 🔐 **SSH 访问** - 安全远程登录
- 📊 **传感器监控** - 温度、电压、风扇转速
- 🔄 **固件更新** - Web UI 或 API 在线升级

## 🚀 快速开始

### 方式一：GitHub Actions 自动编译（推荐）

1. **Fork 本仓库**
2. **访问 Actions 标签**
3. **点击 "Build OpenBMC"**
4. **点击 "Run workflow"**
5. **等待构建完成** (2-4小时)

### 方式二：本地编译

```bash
# 克隆仓库
git clone https://github.com/ashley32/roc-rk3568-pc-openbmc.git
cd roc-rk3568-pc-openbmc

# 检查环境
./scripts/build_openbmc.sh --check

# 完整编译
./scripts/build_openbmc.sh --all
```

## 📖 文档导航

| 文档 | 说明 |
|------|------|
| [QUICKSTART.md](QUICKSTART.md) | 🚀 5分钟快速入门 |
| [README_OPENBMC.md](README_OPENBMC.md) | 📘 完整构建指南 |
| [GITHUB_SETUP_GUIDE.md](GITHUB_SETUP_GUIDE.md) | 🐙 GitHub 项目创建 |
| [hardware_spec.txt](hardware_spec.txt) | 📄 硬件规格详情 |
| [CHECKLIST.md](CHECKLIST.md) | ✅ 编译检查清单 |

## 🔧 构建要求

### 系统要求

| 资源 | 最低配置 | 推荐配置 |
|------|----------|----------|
| **CPU** | 2 核 | 8 核 |
| **内存** | 4 GB | 16 GB |
| **磁盘** | 50 GB | 100 GB |
| **时间** | 6 小时 | 2 小时 |

### 软件依赖

- Git
- Python 3.6+
- GCC/G++ 7+
- Make, CMake
- Yocto/OpenBMC 构建工具

## 📦 构建产物

编译完成后生成以下镜像：

```
openbmc_workspace/build/tmp/deploy/images/roc-rk3568-pc/
├── image-bmc/           # BMC 主固件
├── image-kernel/        # Linux 内核
├── image-rofs/          # 只读文件系统
└── u-boot.rom          # 引导程序
```

## 🔌 BMC 使用指南

### 访问方式

| 方式 | 地址 | 默认账号 |
|------|------|----------|
| **Web UI** | `https://<bmc-ip>` | admin / 0penBmc |
| **IPMI** | `ipmitool -H <bmc-ip>` | admin / 0penBmc |
| **Redfish** | `https://<bmc-ip>/redfish/v1` | admin / 0penBmc |
| **SSH** | `ssh admin@<bmc-ip>` | admin / 0penBmc |

### IPMI 示例

```bash
# 查看传感器
ipmitool -H 192.168.1.100 -U admin -P 0penBmc sensor list

# 电源控制
ipmitool -H 192.168.1.100 -U admin -P 0penBmc power status
ipmitool -H 192.168.1.100 -U admin -P 0penBmc power reset

# BMC 信息
ipmitool -H 192.168.1.100 -U admin -P 0penBmc mc info
```

### Redfish API

```bash
# 获取系统信息
curl -k -u admin:0penBmc \
  https://192.168.1.100/redfish/v1/Managers/BMC.Embedded.1

# 获取传感器
curl -k -u admin:0penBmc \
  https://192.168.1.100/redfish/v1/Chassis/Baseboard/Thermal
```

## 🔥 GitHub Actions

### 工作流状态

| 工作流 | 状态 | 说明 |
|--------|------|------|
| Build OpenBMC | ![Build](https://github.com/ashley32/roc-rk3568-pc-openbmc/actions/workflows/build-openbmc.yml/badge.svg) | 主构建流程 |

### 触发条件

- 推送到 `main` 分支
- 创建 Pull Request
- 手动触发 (`workflow_dispatch`)

### 查看构建

1. 进入仓库 **Actions** 标签
2. 选择 **Build OpenBMC**
3. 查看构建日志
4. 下载构建产物

## 📝 项目结构

```
roc-rk3568-pc-openbmc/
├── .github/
│   └── workflows/
│       └── build-openbmc.yml    # GitHub Actions 配置
├── scripts/
│   ├── build_openbmc.sh        # 主编译脚本
│   ├── validate_build.sh       # 验证脚本
│   ├── github_setup.sh         # GitHub 初始化
│   └── push_to_github.sh       # 快速推送脚本
├── docs/
│   ├── README_OPENBMC.md       # 完整指南
│   ├── QUICKSTART.md           # 快速入门
│   └── GITHUB_SETUP_GUIDE.md   # GitHub 使用
├── hardware_spec.txt           # 硬件规格
├── LICENSE                     # 许可证
└── README.md                   # 本文件
```

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. **Fork 本仓库**
2. **创建分支**: `git checkout -b feature/amazing-feature`
3. **提交更改**: `git commit -m 'Add amazing feature'`
4. **推送分支**: `git push origin feature/amazing-feature`
5. **创建 Pull Request**

## ⚠️ 注意事项

### 安全建议

- ⚠️ **首次使用后立即修改默认密码！**
- 🔐 使用强密码策略
- 🔒 生产环境关闭不必要的服务
- 📅 定期更新固件

### 资源限制

- OpenBMC 完整编译需要 2-4 小时
- GitHub Actions 免费额度：2000分钟/月
- 建议使用本地编译进行频繁构建

## 📚 参考资源

- [OpenBMC 官方文档](https://github.com/openbmc/docs)
- [Rockchip RK3568 数据手册](http://www.rock-chips.com/)
- [Firefly 官方论坛](https://www.t-firefly.com/forum/)
- [Yocto Project](https://www.yoctoproject.org/)

## 📄 许可证

本项目基于 [OpenBMC](https://github.com/openbmc/openbmc) ，遵循 GPL-2.0 许可证。

详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [OpenBMC 项目](https://github.com/openbmc/openbmc)
- [Firefly](https://www.t-firefly.com/)
- [Rockchip](http://www.rock-chips.com/)
- 所有贡献者！

---

## ⭐ 使用统计

[![Star History Chart](https://api.star-history.com/svg?repos=ashley32/roc-rk3568-pc-openbmc&type=Date)](https://star-history.com/#ashley32/roc-rk3568-pc-openbmc&Date)

---

<div align="center">

**Built with ❤️ for ROC-RK3568-PC**

[🌐 Website](https://github.com/ashley32) | [📦 Issues](https://github.com/ashley32/roc-rk3568-pc-openbmc/issues) | [📖 Wiki](https://github.com/ashley32/roc-rk3568-pc-openbmc/wiki)

</div>
