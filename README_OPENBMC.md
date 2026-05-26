# OpenBMC Build for ROC-RK3568-PC

## 硬件规格 (Hardware Specifications)

本项目为 **Firefly ROC-RK3568-PC** 开源主板编译 OpenBMC 固件。

### 核心硬件配置 (从规格书提取)

| 参数 | 规格 |
|------|------|
| **SoC** | Rockchip RK3568 |
| **CPU** | 四核 64位 Cortex-A55 @ 2.0GHz (22nm) |
| **GPU** | ARM Mali-G52 2EE |
| **NPU** | 0.8 TOPS @ INT8 |
| **内存** | 2GB/4GB/8GB LPDDR4 (支持 ECC) |
| **存储** | eMMC (32GB/64GB/128GB) + SPI Flash (16MB) |
| **扩展存储** | M.2 NVMe SSD + SATA3.0 + TF卡 |
| **以太网** | 2x 千兆 RJ45 (1000 Mbps) |
| **无线** | WiFi 6 (802.11ax) + Bluetooth 5.0 |
| **USB** | USB 3.0 x1 + USB-C (OTG) x1 + USB 2.0 x2 |
| **显示** | HDMI 2.0 + MIPI DSI x2 + eDP 1.3 |
| **摄像头** | 2x MIPI CSI (支持 HDR) |
| **串口** | RS485 x1 + RS232 x2 |
| **电源** | DC 12V (9V-24V 宽电压输入) |
| **功耗** | 待机 0.3W / 典型 4.2W / 最大 7.8W |
| **尺寸** | 138.0mm × 77.5mm × 19.9mm |

## OpenBMC 功能

编译的 OpenBMC 固件将包含以下功能：

- 🌐 **Web 管理界面** - 通过浏览器管理 BMC
- 🔌 **IPMI 2.0** - 远程电源管理、控制台重定向
- 📡 **Redfish API** - RESTful API 接口
- 🔐 **SSH 访问** - 安全远程登录
- 🖥️ **KVM over IP** - 远程键盘、显示器、鼠标
- 💿 **虚拟媒体** - 远程挂载 CD/USB 镜像
- 📊 **传感器监控** - 温度、电压、风扇转速
- 🔄 **固件更新** - Web UI 或 Redfish 在线升级
- 📹 **视频采集** - ISP 图像处理

## 系统要求

### 硬件要求
- **CPU**: 多核处理器 (建议 4核+)
- **内存**: 至少 8GB RAM
- **磁盘空间**: 至少 50GB 可用空间 (建议 100GB+)
- **网络**: 稳定的互联网连接 (需要克隆大型仓库)

### 软件要求
- **操作系统**: Ubuntu 18.04+ / Debian 10+
- **Git**: 最新版本
- **Python**: Python 3.6+
- **编译工具链**: GCC, G++, Make

## 快速开始

### 方式一：完整构建 (推荐)

```bash
cd /workspace/projects
./scripts/build_openbmc.sh --all
```

这将自动完成以下步骤：
1. 检查系统要求
2. 安装编译依赖
3. 配置 Git
4. 克隆 OpenBMC 仓库
5. 配置编译环境
6. 编译固件
7. 生成构建清单

### 方式二：分步构建

```bash
# 1. 检查系统要求
./scripts/build_openbmc.sh --check

# 2. 安装依赖
./scripts/build_openbmc.sh --deps

# 3. 克隆仓库
./scripts/build_openbmc.sh --clone

# 4. 配置环境
./scripts/build_openbmc.sh --configure

# 5. 编译固件
./scripts/build_openbmc.sh --build
```

## 编译输出

编译完成后，在 `openbmc_workspace/build/` 目录中会生成以下文件：

```
openbmc_workspace/build/
├── image-bmc/           # BMC 固件镜像
├── image-kernel/        # Linux 内核镜像
├── image-rofs/          # 只读根文件系统
├── image-u-boot/        # U-Boot 引导程序
└── tmp/                 # 编译临时文件
```

## 烧录固件

### 烧录到 SPI Flash

1. 通过 USB-C 连接开发板到电脑
2. 进入 Rockchip 烧录模式
3. 使用 `rkdevtool` 或 `upgrade_tool` 烧录镜像

```bash
# 进入 loader 模式后执行
sudo rkflash -w image-bmc /dev/mtdblock0
```

### 通过 BMC 更新

1. 访问 BMC Web 界面: `https://<bmc-ip>`
2. 导航到 Firmware Update
3. 上传新的 BMC 镜像
4. 确认更新并等待完成

## 访问 BMC

### Web 界面
- **URL**: `https://<bmc-ip>`
- **默认用户**: `root` 或 `admin`
- **默认密码**: `0penBmc` 或 `password`

### IPMI 访问
```bash
# 查看传感器
ipmitool -H <bmc-ip> -U admin -P 0penBmc sensor list

# 查看电源状态
ipmitool -H <bmc-ip> -U admin -P 0penBmc power status

# 远程重启
ipmitool -H <bmc-ip> -U admin -P 0penBmc power reset
```

### Redfish API
```bash
# 获取系统信息
curl -k -u admin:0penBmc https://<bmc-ip>/redfish/v1/Managers/BMC.Embedded.1

# 获取传感器数据
curl -k -u admin:0penBmc https://<bmc-ip>/redfish/v1/Chassis/Baseboard/Thermal
```

## 常见问题

### Q: 编译时间太长怎么办？
A: 确保系统有足够的 CPU 核心和内存。可以在 `local.conf` 中调整 `BB_NUMBER_THREADS` 和 `PARALLEL_MAKE`。

### Q: 编译失败如何排查？
A: 查看编译日志：
```bash
tail -f openbmc_workspace/build/tmp/log/cooker/<machine>/*.log
```

### Q: 如何清理编译缓存？
```bash
cd openbmc_workspace
source openbmc-env
rm -rf build/tmp
bitbake -c cleanall
```

### Q: 编译选项在哪里调整？
A: 编辑 `openbmc_workspace/build/conf/local.conf` 文件。

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目基于 OpenBMC 开源项目，遵循 GPL-2.0 许可证。

## 参考资源

- [OpenBMC 官方文档](https://github.com/openbmc/docs)
- [Rockchip RK3568 数据手册](http://www.rock-chips.com/)
- [ROC-RK3568-PC 规格书](./hardware_spec.txt)
- [Firefly 官方论坛](https://www.t-firefly.com/)

## 联系支持

- 官网: https://www.t-firefly.com/
- 论坛: https://www.t-firefly.com/forum/
