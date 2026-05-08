# MacCMS 后台管理系统 - Docker 部署指南

## 快速启动

### 1. 确保已安装 Docker 和 Docker Compose

检查安装：
```bash
docker --version
docker-compose --version
```

如果未安装，请访问：https://www.docker.com/get-started

### 2. 启动服务

在项目根目录执行：

```bash
# 启动所有服务（MySQL + MacCMS）
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 3. 访问后台

- **后台 API 地址**：http://localhost:8080
- **数据库地址**：localhost:3306

### 4. 初始化数据

数据库会自动导入 schema.sql，包含：
- 管理员表
- 视频表
- 分类表

### 5. 测试 API

```bash
# 测试连接
curl http://localhost:8080

# 管理员登录
curl -X POST http://localhost:8080/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'
```

## 默认账号

- **用户名**：admin
- **密码**：password

## 环境变量

配置文件：`.env`

```
DB_HOST=mysql
DB_NAME=quicktv
DB_USER=quicktv
DB_PASS=quicktv123
DB_PORT=3306
```

## 常用命令

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看 MySQL 日志
docker-compose logs mysql

# 查看 MacCMS 日志
docker-compose logs maccms

# 进入 MySQL 容器
docker-compose exec mysql mysql -u quicktv -pquicktv123 quicktv

# 进入 MacCMS 容器
docker-compose exec maccms bash

# 清理并重新构建
docker-compose down -v
docker-compose up -d --build
```

## 数据持久化

MySQL 数据存储在 Docker volume `mysql_data` 中，即使删除容器数据也不会丢失。

## 端口说明

- **8080**：MacCMS API 服务
- **3306**：MySQL 数据库

## 故障排除

### 端口被占用

如果端口被占用，修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8081:80"  # 将 8080 改为 8081
```

### 数据库连接失败

1. 检查 MySQL 容器是否启动：`docker-compose ps`
2. 查看 MySQL 日志：`docker-compose logs mysql`
3. 确认环境变量配置正确

### 重置数据库

```bash
docker-compose down -v
docker-compose up -d
```

## API 文档

详见：`maccms/README.md`
