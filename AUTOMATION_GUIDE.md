# MacCMS 后台自动化部署指南

## 📋 自动化脚本说明

本项目提供了完整的自动化部署方案，无需人工干预即可完成 Docker 安装和 MacCMS 后台启动。

## 🚀 快速开始

### 方案一：一次性自动化（推荐）

1. **以管理员身份运行 PowerShell**
2. **执行安装脚本**：
   ```powershell
   cd D:\GitCangku2\quicktv-app-project
   .\install-docker.ps1
   ```
3. **安装完成后重启电脑**（脚本会提示）
4. **重启后执行**：
   ```powershell
   cd D:\GitCangku2\quicktv-app-project
   .\auto-start-after-reboot.ps1
   ```

### 方案二：配置开机自动启动

1. **以管理员身份运行**：
   ```powershell
   cd D:\GitCangku2\quicktv-app-project
   .\setup-auto-start.ps1
   ```
2. **重启电脑后，MacCMS 后台将自动启动**

## 📁 脚本文件说明

| 脚本文件 | 功能 | 需要管理员权限 |
|---------|------|--------------|
| `install-docker.ps1` | 自动安装 Docker Desktop 到 D 盘 | ✓ |
| `auto-start-after-reboot.ps1` | 等待 Docker 启动并自动启动 MacCMS | ✓ |
| `setup-auto-start.ps1` | 配置开机自动启动任务 | ✓ |
| `start-maccms.ps1` | 手动启动 MacCMS 后台 | ✓ |

## 🔧 自动化流程详解

### 1. Docker 安装阶段
```
install-docker.ps1
  ↓
检查管理员权限
  ↓
检查/安装 Chocolatey
  ↓
安装 Docker Desktop 到 D:\Docker
  ↓
提示重启电脑
```

### 2. 服务启动阶段
```
auto-start-after-reboot.ps1
  ↓
等待 Docker Desktop 启动（最多 5 分钟）
  ↓
拉取 Docker 镜像
  ↓
启动 MySQL 和 MacCMS 容器
  ↓
测试 API 连接
  ↓
显示服务信息
```

## 🎯 服务信息

### API 服务
- **地址**：http://localhost:8080
- **管理员账号**：admin
- **管理员密码**：password

### 数据库服务
- **主机**：localhost:3306
- **数据库**：maccms
- **用户名**：root
- **密码**：rootpassword

## 📊 API 端点

### 管理员接口
- `POST /api/admin/login` - 管理员登录
- `GET /api/admin/info` - 获取管理员信息

### 视频管理
- `GET /api/videos` - 获取视频列表
- `GET /api/videos/{id}` - 获取单个视频
- `POST /api/videos` - 创建视频
- `PUT /api/videos/{id}` - 更新视频
- `DELETE /api/videos/{id}` - 删除视频

### 分类管理
- `GET /api/categories` - 获取分类列表
- `POST /api/categories` - 创建分类
- `PUT /api/categories/{id}` - 更新分类
- `DELETE /api/categories/{id}` - 删除分类

### 统计信息
- `GET /api/stats` - 获取统计信息

## 🛠️ 常用命令

### 查看服务状态
```powershell
docker compose ps
```

### 查看日志
```powershell
docker compose logs -f
```

### 停止服务
```powershell
docker compose down
```

### 重启服务
```powershell
docker compose restart
```

### 查看容器资源使用
```powershell
docker stats
```

## 🔍 故障排除

### Docker Desktop 未启动
```powershell
# 检查 Docker 状态
docker info

# 如果失败，手动启动 Docker Desktop
# 从开始菜单找到 "Docker Desktop" 并启动
```

### 端口被占用
```powershell
# 检查端口占用
netstat -ano | findstr "8080"
netstat -ano | findstr "3306"

# 修改 docker-compose.yml 中的端口映射
```

### 容器启动失败
```powershell
# 查看详细日志
docker compose logs

# 重新构建并启动
docker compose down
docker compose up -d --build
```

### 数据库连接失败
```powershell
# 进入 MySQL 容器
docker compose exec mysql mysql -uroot -prootpassword

# 检查数据库
SHOW DATABASES;
USE maccms;
SHOW TABLES;
```

## 🔐 安全建议

1. **修改默认密码**：
   - 编辑 `.env` 文件
   - 修改 `ADMIN_PASSWORD` 和 `DB_PASSWORD`
   - 重启服务：`docker compose down && docker compose up -d`

2. **限制访问**：
   - 生产环境不要暴露 3306 端口
   - 使用反向代理（如 Nginx）保护 API

3. **备份数据**：
   ```powershell
   # 备份数据库
   docker compose exec mysql mysqldump -uroot -prootpassword maccms > backup.sql
   
   # 恢复数据库
   docker compose exec -T mysql mysql -uroot -prootpassword maccms < backup.sql
   ```

## 📝 开发建议

### 修改代码后重启
```powershell
docker compose restart maccms-api
```

### 查看 PHP 错误日志
```powershell
docker compose logs -f maccms-api
```

### 进入容器调试
```powershell
docker compose exec maccms-api bash
```

## 🎉 完成检查清单

- [ ] Docker Desktop 已安装
- [ ] 容器已启动（`docker compose ps` 显示 Up）
- [ ] API 可访问（http://localhost:8080）
- [ ] 管理员可登录（admin/password）
- [ ] 数据库可连接（localhost:3306）
- [ ] 快应用可以调用 API

## 📞 技术支持

如遇问题，请检查：
1. Docker Desktop 是否正常运行（托盘图标为绿色）
2. 防火墙是否阻止了端口 8080 和 3306
3. 容器日志是否有错误信息
4. `.env` 文件配置是否正确
