# Docker Desktop 安装指南（安装到 D 盘）

## 方案一：全新安装到 D 盘

### 1. 下载安装程序

下载地址：https://www.docker.com/products/docker-desktop/

### 2. 使用命令行安装

以**管理员身份**运行 PowerShell，执行：

```powershell
# 假设安装程序下载到了 Downloads 目录
cd $env:USERPROFILE\Downloads

# 安装到 D 盘
.\Docker Desktop Installer.exe install --installation-dir="D:\Docker"
```

### 3. 配置 WSL 2 数据位置

创建配置文件 `%USERPROFILE%\.wslconfig`：

```ini
[wsl2]
# 限制内存使用
memory=4GB
# 限制处理器数量
processors=2
# 设置交换文件大小
swap=2GB
# 设置交换文件位置到 D 盘
swapfile=D:\\Docker\\wsl\\swap.vhdx
```

## 方案二：已安装后迁移到 D 盘

### 自动迁移脚本

我已经为你创建了自动迁移脚本：`move-docker-to-d.ps1`

**使用方法**：

1. 以**管理员身份**运行 PowerShell
2. 执行脚本：

```powershell
cd D:\GitCangku2\quicktv-app-project
.\move-docker-to-d.ps1
```

### 手动迁移步骤

如果脚本执行失败，可以手动操作：

#### 1. 停止 Docker Desktop

关闭 Docker Desktop 应用程序

#### 2. 关闭 WSL

```powershell
wsl --shutdown
```

#### 3. 导出 WSL 发行版

```powershell
# 创建目标目录
mkdir D:\Docker\wsl

# 导出 docker-desktop
wsl --export docker-desktop D:\Docker\wsl\docker-desktop.tar

# 导出 docker-desktop-data
wsl --export docker-desktop-data D:\Docker\wsl\docker-desktop-data.tar
```

#### 4. 注销原有发行版

```powershell
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data
```

#### 5. 导入到新位置

```powershell
wsl --import docker-desktop D:\Docker\wsl\docker-desktop D:\Docker\wsl\docker-desktop.tar --version 2
wsl --import docker-desktop-data D:\Docker\wsl\docker-desktop-data D:\Docker\wsl\docker-desktop-data.tar --version 2
```

#### 6. 清理临时文件

```powershell
del D:\Docker\wsl\docker-desktop.tar
del D:\Docker\wsl\docker-desktop-data.tar
```

#### 7. 启动 Docker Desktop

重新启动 Docker Desktop 应用程序

## 验证安装

```powershell
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker compose version

# 检查 WSL 发行版位置
wsl --list --verbose
```

## 配置 Docker 镜像存储位置

在 Docker Desktop 设置中：

1. 打开 Docker Desktop
2. 点击设置图标（齿轮）
3. 选择 "Resources" -> "Advanced"
4. 修改 "Disk image location" 到 D 盘

## 启动 QuickTV 后台

安装完成后，在项目目录执行：

```powershell
cd D:\GitCangku2\quicktv-app-project

# 启动服务
docker compose up -d

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f
```

## 访问后台

- **API 地址**：http://localhost:8080
- **数据库**：localhost:3306
- **默认账号**：admin / password

## 常见问题

### WSL 2 未启用

如果提示需要 WSL 2，执行：

```powershell
# 启用 WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 启用虚拟机平台
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 重启电脑后，设置 WSL 2 为默认版本
wsl --set-default-version 2
```

### 虚拟化未启用

需要在 BIOS 中启用：
- Intel: VT-x
- AMD: AMD-V

### 端口被占用

如果 8080 端口被占用，修改 `docker-compose.yml`：

```yaml
services:
  maccms:
    ports:
      - "8081:80"  # 改为其他端口
```

## 卸载（如需要）

```powershell
# 停止并删除容器
docker compose down -v

# 卸载 Docker Desktop
# 在控制面板中卸载

# 删除 WSL 发行版
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# 删除数据目录
Remove-Item -Recurse -Force D:\Docker
```
