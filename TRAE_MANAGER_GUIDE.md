# QuickTV MacCMS 后台管理系统

## 🎯 Trae 统一管理

所有操作都通过 `trae-manager.ps1` 脚本统一管理，无需手动操作。

## 📋 快速开始

### 1. 查看系统状态
```powershell
.\trae-manager.ps1 status
```

### 2. 安装 Docker（如果未安装）
```powershell
.\trae-manager.ps1 install
```

### 3. 启动 MacCMS 后台
```powershell
.\trae-manager.ps1 start
```

### 4. 访问后台
- **API 地址**：http://localhost:8080
- **管理员账号**：admin
- **管理员密码**：password

## 🛠️ 管理命令

| 命令 | 说明 |
|------|------|
| `.\trae-manager.ps1 status` | 查看系统和服务状态 |
| `.\trae-manager.ps1 start` | 启动 MacCMS 后台服务 |
| `.\trae-manager.ps1 stop` | 停止服务 |
| `.\trae-manager.ps1 restart` | 重启服务 |
| `.\trae-manager.ps1 logs` | 查看服务日志 |
| `.\trae-manager.ps1 install` | 安装 Docker Desktop |
| `.\trae-manager.ps1 config` | 查看配置信息 |

## 📁 项目结构

```
quicktv-app-project/
├── trae-manager.ps1          # 主管理脚本（Trae 统一管理）
├── docker-compose.yml         # Docker 编排配置
├── .env                       # 环境变量配置
├── maccms/                    # MacCMS 后台代码
│   ├── api/                   # API 接口
│   ├── config/                # 配置文件
│   ├── database/              # 数据库结构
│   └── public/                # 公共访问目录
├── src/                       # 快应用源码
│   ├── Admin/                 # 管理页面
│   ├── Home/                  # 首页
│   ├── Live/                  # 直播
│   ├── config/                # 配置
│   │   └── testSources.js     # 测试源配置
│   └── services/              # 服务层
└── dist/                      # 构建输出
    └── com.maccms.quicktv.debug.rpk
```

## 🔧 配置说明

### 环境变量（.env）
```env
DB_HOST=mysql
DB_NAME=quicktv
DB_USER=quicktv
DB_PASS=quicktv123
DB_PORT=3306
```

### 测试源配置
- **直播源**：10个频道（央视+卫视）
- **M3U 源**：3个公共直播源
- **MacCMS API**：5个视频资源站
- **点播测试**：5个测试视频

配置文件：`src/config/testSources.js`

## 📡 API 接口

### 管理员接口
- `POST /api/admin/login` - 登录
- `GET /api/admin/info` - 获取信息

### 视频管理
- `GET /api/videos` - 获取列表
- `GET /api/videos/{id}` - 获取详情
- `POST /api/videos` - 创建视频
- `PUT /api/videos/{id}` - 更新视频
- `DELETE /api/videos/{id}` - 删除视频

### 分类管理
- `GET /api/categories` - 获取列表
- `POST /api/categories` - 创建分类

### 统计信息
- `GET /api/stats` - 获取统计

## 🚀 部署流程

### 首次部署

1. **安装 Docker**
   ```powershell
   .\trae-manager.ps1 install
   ```

2. **重启电脑**（Docker 安装后必须重启）

3. **启动服务**
   ```powershell
   .\trae-manager.ps1 start
   ```

### 日常使用

```powershell
# 查看状态
.\trae-manager.ps1 status

# 查看日志
.\trae-manager.ps1 logs

# 重启服务
.\trae-manager.ps1 restart
```

## 📱 快应用部署

### 构建 RPK
```powershell
npm run build
```

### 安装到电视盒子
```powershell
adb install -r dist/com.maccms.quicktv.debug.rpk
```

### 测试数据查看
1. 打开快应用
2. 进入"管理"页面
3. 登录：admin / admin123
4. 点击"测试数据"查看统计

## 🔍 故障排除

### Docker Desktop 无法启动
```powershell
# 检查 WSL 状态
wsl --status

# 如果 WSL 未安装，需要重启电脑完成配置
```

### 端口被占用
```powershell
# 检查端口
netstat -ano | findstr "8080"

# 修改 docker-compose.yml 中的端口
```

### 容器启动失败
```powershell
# 查看详细日志
.\trae-manager.ps1 logs

# 重新构建
docker compose down
docker compose up -d --build
```

## 📊 监控和日志

### 实时日志
```powershell
.\trae-manager.ps1 logs
```

### 容器状态
```powershell
docker compose ps
```

### 资源使用
```powershell
docker stats
```

## 🔐 安全建议

1. **修改默认密码**
   - 编辑 `.env` 文件
   - 修改数据库密码
   - 重启服务

2. **生产环境配置**
   - 使用 HTTPS
   - 配置防火墙
   - 限制 API 访问

3. **数据备份**
   ```powershell
   # 备份数据库
   docker compose exec mysql mysqldump -uroot -prootpassword quicktv > backup.sql
   ```

## 📝 开发说明

### 修改代码后重启
```powershell
.\trae-manager.ps1 restart
```

### 查看 PHP 错误
```powershell
docker compose logs maccms
```

### 进入容器调试
```powershell
docker compose exec maccms bash
```

## 🎉 完成检查清单

- [ ] Docker Desktop 已安装
- [ ] 容器已启动
- [ ] API 可访问（http://localhost:8080）
- [ ] 管理员可登录
- [ ] 数据库可连接
- [ ] 快应用已构建
- [ ] 测试源已配置

## 📞 支持

所有操作都通过 `trae-manager.ps1` 统一管理，如有问题：

1. 运行 `.\trae-manager.ps1 status` 查看状态
2. 运行 `.\trae-manager.ps1 logs` 查看日志
3. 运行 `.\trae-manager.ps1 config` 查看配置
