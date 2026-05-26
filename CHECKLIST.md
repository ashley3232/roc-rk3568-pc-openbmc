# OpenBMC 编译检查清单

## ✅ 编译前检查

### 硬件检查
- [ ] CPU: 至少 1 核 (推荐 4 核+)
- [ ] 内存: 至少 2GB (推荐 8GB+)
- [ ] 磁盘空间: 至少 50GB (推荐 100GB+)
- [ ] 网络: 稳定的互联网连接

### 软件检查
- [ ] 操作系统: Ubuntu 18.04+ / Debian 10+
- [ ] Git: 已安装并配置
- [ ] Python: Python 3.6+
- [ ] 编译工具链: GCC, G++, Make

### 环境检查
```bash
# 运行检查脚本
./scripts/build_openbmc.sh --check
```

预期结果:
```
✓ git is installed
✓ make is installed
✓ gcc is installed
✓ g++ is installed
✓ python3 is installed
✓ Disk space check passed
```

---

## 📦 编译阶段检查

### 阶段 1: 依赖安装
- [ ] 执行: `./scripts/build_openbmc.sh --deps`
- [ ] 等待所有包安装完成
- [ ] 无错误输出

### 阶段 2: Git 配置
- [ ] 执行: `./scripts/build_openbmc.sh --clone`
- [ ] Git 用户名已配置
- [ ] Git 邮箱已配置
- [ ] 仓库克隆成功 (约 2-5GB)

### 阶段 3: 环境配置
- [ ] 执行: `./scripts/build_openbmc.sh --configure`
- [ ] 配置文件已生成
- [ ] `conf/local.conf` 存在
- [ ] `conf/bblayers.conf` 存在

### 阶段 4: 编译
- [ ] 执行: `./scripts/build_openbmc.sh --build`
- [ ] Bitbake 启动成功
- [ ] 依赖下载完成 (可能需要 1-2 小时)
- [ ] 内核编译完成
- [ ] 根文件系统构建完成
- [ ] BMC 镜像生成完成

---

## 📋 编译产物检查

### 必要文件
```bash
ls -lh openbmc_workspace/build/tmp/deploy/images/roc-rk3568-pc/
```

应该包含:
- [ ] `obmc-phosphor-image-roc-rk3568-pc.bootfiles.tar` - 启动文件
- [ ] `obmc-phosphor-image-roc-rk3568-pc.ext4` - 根文件系统镜像
- [ ] `image-bmc` - BMC 主镜像
- [ ] `image-kernel` - 内核镜像
- [ ] `u-boot.rom` - U-Boot 镜像

### 镜像大小检查
- [ ] `image-bmc`: 约 50-100MB
- [ ] `image-kernel`: 约 10-20MB
- [ ] 根文件系统: 约 200-500MB

---

## 🔧 固件烧录检查

### 烧录前
- [ ] 准备 USB-C 数据线
- [ ] 准备串口调试线 (可选)
- [ ] 备份原固件 (如果有)
- [ ] 确认目标设备型号

### 烧录中
- [ ] 进入烧录模式 (按住 Maskrom 键或短接)
- [ ] 电脑识别到设备
- [ ] 使用工具烧录成功
- [ ] 无错误提示

### 烧录后
- [ ] BMC 启动正常
- [ ] 串口有输出
- [ ] 网络连接建立
- [ ] LED 指示灯正常

---

## 🌐 BMC 访问检查

### Web 界面
- [ ] 访问 `https://<bmc-ip>` 成功
- [ ] 登录页面正常显示
- [ ] 使用默认账号登录成功
- [ ] Dashboard 正常加载

### IPMI 访问
```bash
# 测试连接
ping <bmc-ip>

# 查看 BMC 信息
ipmitool -H <bmc-ip> -U admin -P 0penBmc mc info

# 查看传感器
ipmitool -H <bmc-ip> -U admin -P 0penBmc sensor list
```
- [ ] Ping 成功
- [ ] BMC 信息正确
- [ ] 传感器数据正常

### SSH 访问
```bash
ssh admin@<bmc-ip>
# 密码: 0penBmc
```
- [ ] SSH 连接成功
- [ ] 登录正常
- [ ] Shell 可用

### Redfish API
```bash
curl -k -u admin:0penBmc \
  https://<bmc-ip>/redfish/v1/Managers
```
- [ ] API 响应正常
- [ ] 返回 JSON 数据
- [ ] 认证通过

---

## 📊 功能验证

### 电源管理
- [ ] 查看电源状态: `ipmitool power status`
- [ ] 开机: `ipmitool power on`
- [ ] 关机: `ipmitool power off`
- [ ] 重启: `ipmitool power reset`

### 传感器监控
- [ ] 温度传感器数据
- [ ] 电压传感器数据
- [ ] 风扇转速数据
- [ ] 无异常告警

### 日志查看
- [ ] BMC 系统日志可查看
- [ ] SEL 日志正常记录
- [ ] 日志可正常导出

### 固件更新
- [ ] 进入固件更新页面
- [ ] 上传新镜像
- [ ] 更新过程正常
- [ ] 更新后系统正常

---

## 🐛 故障排查检查

### 编译问题
| 问题 | 检查项 | 解决方案 |
|------|--------|----------|
| 依赖安装失败 | 网络连接 | 检查代理设置 |
| 编译超时 | 系统资源 | 增加 CPU/内存 |
| 编译错误 | 日志文件 | 查看 `tmp/log/` |
| 磁盘空间不足 | 清理空间 | `bitbake -c clean` |

### 烧录问题
| 问题 | 检查项 | 解决方案 |
|------|--------|----------|
| 设备未识别 | USB 连接 | 检查线材/驱动 |
| 烧录失败 | Flash 状态 | 检查硬件 |
| 烧录变砖 | 救砖方法 | USB 强制烧录 |

### BMC 运行问题
| 问题 | 检查项 | 解决方案 |
|------|--------|----------|
| 无法访问 | 网络配置 | 检查 IP/网段 |
| 登录失败 | 密码重置 | 恢复出厂设置 |
| 功能异常 | 服务状态 | 重启 BMC |

---

## 📝 文档检查

- [ ] `README_OPENBMC.md` - 已阅读
- [ ] `QUICKSTART.md` - 已了解
- [ ] `hardware_spec.txt` - 已参考
- [ ] `VALIDATION_REPORT.md` - 已查看

---

## 🎯 最终确认

### 编译成功 ✓
- [ ] OpenBMC 固件已编译完成
- [ ] 所有镜像文件已生成
- [ ] 构建清单已生成

### 烧录成功 ✓
- [ ] 固件已成功烧录到设备
- [ ] BMC 正常启动
- [ ] 所有 LED 指示正常

### 功能正常 ✓
- [ ] Web 界面可访问
- [ ] IPMI 功能正常
- [ ] Redfish API 可用
- [ ] SSH 可登录
- [ ] 传感器数据正常

### 文档完整 ✓
- [ ] 所有文档已阅读
- [ ] 配置已记录
- [ ] 使用方法已掌握

---

## 📞 遇到问题？

### 自助解决
1. 查看 `README_OPENBMC.md` 故障排查章节
2. 检查编译日志: `openbmc_workspace/build/tmp/log/`
3. 查看 BMC 日志: Web UI → Maintenance → Logs

### 寻求帮助
1. 查看 [OpenBMC Issues](https://github.com/openbmc/openbmc/issues)
2. 查看 [Firefly 论坛](https://www.t-firefly.com/forum/)
3. 联系技术支持

---

## ✅ 编译完成！

如果所有检查项都已通过，恭喜你！OpenBMC 编译和部署已成功完成！

**下一步**: 开始使用 BMC 管理你的 ROC-RK3568-PC 主板！

---

*检查清单版本: 1.0*  
*最后更新: $(date '+%Y-%m-%d')*
