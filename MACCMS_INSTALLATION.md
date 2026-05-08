# MacCMS v10 自动化安装完成

## ✅ 安装状态

所有组件已成功安装并运行：
- ✅ Docker 容器已启动
- ✅ MySQL 数据库已初始化
- ✅ MacCMS 系统已配置
- ✅ 管理员账号已创建

## 🌐 访问信息

### 前台访问
- **URL**: http://localhost:8080/
- 用户可以浏览视频内容

### 后台管理
- **URL**: http://localhost:8080/admin.php
- **用户名**: `admin`
- **密码**: `admin123`

## 🗄️ 数据库信息

- **主机**: mysql (容器内) / localhost:3306 (宿主机)
- **数据库名**: maccms10
- **用户名**: root
- **密码**: root
- **备用用户**: maccms / maccms123

## 🚀 快速开始

### 启动服务
```powershell
docker-compose up -d
```

### 停止服务
```powershell
docker-compose down
```

### 重启服务
```powershell
docker-compose restart
```

### 查看日志
```powershell
# 查看所有日志
docker-compose logs

# 查看 MacCMS 日志
docker logs quicktv-maccms

# 查看 MySQL 日志
docker logs quicktv-mysql
```

## 📁 项目结构

```
quicktv-app-project/
├── maccms-official/          # MacCMS v10 官方完整代码
│   ├── admin.php            # 后台入口
│   ├── index.php            # 前台入口
│   ├── application/         # 应用代码
│   ├── static/              # 静态资源
│   └── template/            # 模板文件
├── docker-compose.yml       # Docker 编排配置
├── Dockerfile               # PHP 环境配置
└── install-maccms.ps1       # 自动化安装脚本
```

## 🔧 后台功能

MacCMS v10 提供完整的内容管理功能：

1. **视频管理**
   - 视频添加/编辑/删除
   - 批量导入
   - 分类管理
   - 播放器配置

2. **内容管理**
   - 文章管理
   - 专题管理
   - 演员管理
   - 角色管理

3. **系统管理**
   - 用户管理
   - 权限管理
   - 系统配置
   - 模板管理

4. **采集功能**
   - 资源采集
   - 自动更新
   - 定时任务

## 📝 注意事项

1. **首次登录**: 使用 admin/admin123 登录后台，建议立即修改密码
2. **数据备份**: 定期备份 MySQL 数据库
3. **安全设置**: 生产环境请修改默认密码和数据库配置
4. **端口冲突**: 如果 8080 或 3306 端口被占用，请修改 docker-compose.yml

## 🔄 重新安装

如需重新安装，执行以下命令：

```powershell
# 停止并删除所有容器和数据
docker-compose down -v

# 重新运行安装脚本
powershell -ExecutionPolicy Bypass -File install-maccms.ps1
```

## 📞 技术支持

- MacCMS 官方: https://github.com/magicblack/maccms10
- 官方文档: http://www.maccms.la/
- 问题反馈: 在 GitHub 仓库提交 Issue

---

**安装时间**: 2026-05-08
**版本**: MacCMS v10 (官方最新版)
**环境**: Docker + PHP 8.1 + MySQL 8.0
