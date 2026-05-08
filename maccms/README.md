# MacCMS 后台管理系统

基于 PHP 的轻量级视频内容管理系统后台 API。

## 功能特性

- 管理员登录认证
- 视频内容管理（增删改查）
- 分类管理
- 数据统计
- RESTful API 设计

## 目录结构

```
maccms/
├── api/              # API 核心文件
│   ├── Database.php  # 数据库操作类
│   ├── Router.php    # 路由处理
│   └── Response.php  # 响应处理
├── config/           # 配置文件
│   ├── app.php       # 应用配置
│   └── database.php  # 数据库配置
├── database/         # 数据库文件
│   └── schema.sql    # 数据库结构
└── public/           # 公共访问目录
    └── index.php     # 入口文件
```

## 安装配置

### 1. 环境要求

- PHP >= 7.4
- MySQL >= 5.7
- PDO 扩展

### 2. 数据库配置

复制并修改数据库配置文件：

```bash
cd maccms
```

编辑 `config/database.php`，设置数据库连接信息：

```php
return [
    'hostname' => 'localhost',
    'database' => 'quicktv',
    'username' => 'root',
    'password' => 'your_password',
    'hostport' => '3306',
];
```

### 3. 导入数据库

```bash
mysql -u root -p quicktv < database/schema.sql
```

### 4. 配置 Web 服务器

#### Apache

确保 `.htaccess` 文件存在并启用 `mod_rewrite`。

#### Nginx

```nginx
location /maccms {
    try_files $uri $uri/ /maccms/public/index.php?$query_string;
}
```

#### PHP 内置服务器（开发环境）

```bash
cd public
php -S localhost:8080
```

## API 接口

### 管理员接口

#### 登录
```
POST /api/admin/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password"
}
```

#### 获取管理员信息
```
GET /api/admin/info
Authorization: Bearer {token}
```

### 视频管理

#### 获取视频列表
```
GET /api/videos?page=1&pageSize=20&keyword=关键词&type_id=1
```

#### 获取单个视频
```
GET /api/videos/{id}
```

#### 创建视频
```
POST /api/videos
Content-Type: application/json

{
  "type_id": 1,
  "vod_name": "视频名称",
  "vod_pic": "封面图片URL",
  "vod_content": "视频简介",
  "vod_play_url": "播放地址"
}
```

#### 更新视频
```
PUT /api/videos/{id}
Content-Type: application/json

{
  "vod_name": "新的视频名称"
}
```

#### 删除视频
```
DELETE /api/videos/{id}
```

### 分类管理

#### 获取分类列表
```
GET /api/categories
```

#### 创建分类
```
POST /api/categories
Content-Type: application/json

{
  "type_name": "分类名称",
  "type_sort": 1
}
```

#### 更新分类
```
PUT /api/categories/{id}
```

#### 删除分类
```
DELETE /api/categories/{id}
```

### 统计数据

#### 获取统计信息
```
GET /api/stats
```

## 默认账号

- 用户名: `admin`
- 密码: `password`

## 安全建议

1. 修改默认管理员密码
2. 配置环境变量存储敏感信息
3. 启用 HTTPS
4. 实施 IP 白名单
5. 定期备份数据库

## 开发说明

### 添加新路由

在 `api/Router.php` 的 `registerRoutes()` 方法中添加：

```php
$this->routes['GET /api/your-route'] = 'handleYourRoute';
```

然后实现对应的处理方法：

```php
private function handleYourRoute() {
    Response::success(['data' => 'your data']);
}
```

## License

MIT
