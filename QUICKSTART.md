# OpenBMC 快速入门指南 - ROC-RK3568-PC

## 🚀 5分钟快速开始

### 第一步：检查环境 (1分钟)

```bash
cd /workspace/projects
./scripts/build_openbmc.sh --check
```

应该看到所有检查项都显示绿色 ✓

### 第二步：安装依赖 (2分钟)

```bash
./scripts/build_openbmc.sh --deps
```

### 第三步：克隆仓库 (3-10分钟)

```bash
./scripts/build_openbmc.sh --clone
```

### 第四步：编译固件 (2-4小时 ⏰)

```bash
./scripts/build_openbmc.sh --build
```

> ⚠️ **注意**：编译需要较长时间，请确保系统稳定运行！

---

## 📋 完整流程 (推荐)

一次性完成所有步骤：

```bash
cd /workspace/projects
./scripts/build_openbmc.sh --all
```

这个命令会自动：
1. ✓ 检查系统要求
2. ✓ 安装编译依赖
3. ✓ 配置 Git
4. ✓ 克隆 OpenBMC 仓库
5. ✓ 设置编译环境
6. ✓ 编译固件
7. ✓ 生成构建清单

---

## 🎯 分步执行 (高级用户)

如果需要更精细的控制：

### 1️⃣ 仅安装依赖
```bash
./scripts/build_openbmc.sh --deps
```

### 2️⃣ 仅克隆仓库
```bash
./scripts/build_openbmc.sh --clone
```

### 3️⃣ 仅配置环境
```bash
./scripts/build_openbmc.sh --configure
```

### 4️⃣ 仅编译
```bash
./scripts/build_openbmc.sh --build
```

---

## 💡 常见命令

### 查看帮助
```bash
./scripts/build_openbmc.sh --help
```

### 查看验证报告
```bash
cat /workspace/projects/VALIDATION_REPORT.md
```

### 查看硬件规格
```bash
cat /workspace/projects/hardware_spec.txt
```

### 查看构建指南
```bash
cat /workspace/projects/README_OPENBMC.md
```

---

## 📦 编译产物

编译完成后，在 `openbmc_workspace/build/` 目录中会有：

```
openbmc_workspace/build/
├── image-bmc/           # 🔧 BMC 固件主镜像
├── image-kernel/        # 🐧 Linux 内核
├── image-rofs/          # 📁 只读根文件系统
├── image-u-boot/       # 🚀 U-Boot 引导程序
├── conf/                # ⚙️ 配置文件
└── tmp/                 # 📝 编译日志
```

---

## 🔧 固件烧录

### 方法一：Web 界面烧录 (推荐新手)

1. 访问 BMC Web UI: `https://<bmc-ip>`
2. 登录 (默认: admin / 0penBmc)
3. 导航到 "Firmware Update"
4. 上传 `image-bmc` 文件
5. 点击更新并等待完成

### 方法二：命令行烧录

```bash
# 连接串口或 SSH
ssh root@<bmc-ip>

# 烧录镜像
bmc-update image-bmc
reboot
```

### 方法三：USB 烧录 (用于救砖)

```bash
# 进入 Rockchip 烧录模式
# 短接 Flash 的 WP 引脚或按住 Maskrom 按键

# 使用 rkdevtool 烧录
rkdevtool -d /dev/sdX -i image-bmc
```

---

## 🌐 访问 BMC

### Web 管理界面
```
https://<bmc-ip>
```
- 用户名: `admin` 或 `root`
- 密码: `0penBmc` 或 `password`

### IPMI 命令行
```bash
# 安装 ipmitool (如果未安装)
sudo apt-get install ipmitool

# 查看所有传感器
ipmitool -H <bmc-ip> -U admin -P 0penBmc sensor list

# 查看电源状态
ipmitool -H <bmc-ip> -U admin -P 0penBmc power status

# 重启主机
ipmitool -H <bmc-ip> -U admin -P 0penBmc power reset

# 查看 BMC 信息
ipmitool -H <bmc-ip> -U admin -P 0penBmc mc info
```

### Redfish API
```bash
# 获取系统信息
curl -k -u admin:0penBmc \
  https://<bmc-ip>/redfish/v1/Managers/BMC.Embedded.1

# 获取传感器数据
curl -k -u admin:0penBmc \
  https://<bmc-ip>/redfish/v1/Chassis/Baseboard/Thermal

# 获取电源信息
curl -k -u admin:0penBmc \
  https://<bmc-ip>/redfish/v1/Chassis/Baseboard/Power

# 获取日志
curl -k -u admin:0penBmc \
  https://<bmc-ip>/redfish/v1/Managers/BMC.Embedded.1/LogServices
```

### SSH 登录
```bash
ssh admin@<bmc-ip>
# 密码: 0penBmc
```

---

## 🔍 故障排查

### 编译失败？

1. **检查日志**：
```bash
tail -f openbmc_workspace/build/tmp/log/cooker/*/*.log
```

2. **清理并重新编译**：
```bash
cd openbmc_workspace
source openbmc-env
bitbake -c cleanall
bitbake obmc-phosphor-image
```

3. **检查依赖**：
```bash
./scripts/build_openbmc.sh --check
```

### 内存不足？

增加 Swap 分区：
```bash
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 编译太慢？

调整并行度（在 `build/conf/local.conf` 中）：
```bash
BB_NUMBER_THREADS = "16"
PARALLEL_MAKE = "-j 16"
```

---

## 📚 更多资源

### 文档
- 📘 [完整构建指南](./README_OPENBMC.md) - 详细的功能说明和配置选项
- 📗 [硬件规格书](./hardware_spec.txt) - ROC-RK3568-PC 完整硬件规格
- 📙 [验证报告](./VALIDATION_REPORT.md) - 构建系统验证结果

### 官方网站
- 🔗 [OpenBMC GitHub](https://github.com/openbmc)
- 🔗 [Rockchip 官网](http://www.rock-chips.com/)
- 🔗 [Firefly 论坛](https://www.t-firefly.com/)

### 技术支持
- 📧 Email: support@t-firefly.com
- 💬 论坛: https://www.t-firefly.com/forum/
- 📖 Wiki: https://wiki.t-firefly.com/

---

## ⚡ 快速参考卡

| 操作 | 命令 |
|------|------|
| 完整构建 | `./scripts/build_openbmc.sh --all` |
| 检查环境 | `./scripts/build_openbmc.sh --check` |
| 安装依赖 | `./scripts/build_openbmc.sh --deps` |
| 克隆仓库 | `./scripts/build_openbmc.sh --clone` |
| 开始编译 | `./scripts/build_openbmc.sh --build` |
| 查看帮助 | `./scripts/build_openbmc.sh --help` |

---

## 📞 需要帮助？

如果你遇到问题：

1. 📖 查看本文档的 [故障排查](#故障排查) 部分
2. 📝 查看完整文档: [README_OPENBMC.md](./README_OPENBMC.md)
3. 🔍 搜索 [OpenBMC Issues](https://github.com/openbmc/openbmc/issues)
4. 💬 在 [Firefly 论坛](https://www.t-firefly.com/forum/) 提问

---

**祝你编译成功！** 🎉

> 🔧 Built with ❤️ for ROC-RK3568-PC
> 
> 📅 最后更新: $(date '+%Y-%m-%d')
