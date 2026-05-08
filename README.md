# QuickTV - 智能电视快应用

QuickTV 是一款基于快应用框架开发的智能电视应用，支持 MacCMS 视频点播和直播功能。

## 功能特性

- 📺 **视频点播**: 支持 MacCMS API 接口，提供丰富的影视资源
- 🎬 **视频播放**: 内置视频播放器，支持多种视频格式
- 📡 **直播频道**: 支持 M3U 格式直播源，观看电视直播
- 🔍 **搜索功能**: 快速搜索视频和直播频道
- 📱 **分类浏览**: 按类型、地区、年份等分类浏览内容
- ⚙️ **后台管理**: 配置 API 地址和直播源

## 技术栈

- 快应用框架 (Quick App)
- JavaScript ES6+
- MacCMS API
- M3U 直播源

## 目录结构

```
quicktv-app/
├── src/
│   ├── pages/              # 页面文件
│   │   ├── Home.ux        # 首页
│   │   ├── VideoDetail.ux # 视频详情
│   │   ├── Live.ux        # 直播列表
│   │   ├── LivePlayer.ux  # 直播播放
│   │   └── Admin.ux       # 后台管理
│   ├── services/          # 服务层
│   │   └── api.js         # API 接口
│   ├── common/            # 公共资源
│   │   └── logo.png       # 应用图标
│   ├── app.ux             # 应用入口
│   └── manifest.json      # 应用配置
├── package.json           # 项目配置
├── build.sh              # 打包脚本
└── README.md             # 说明文档
```

## 快速开始

### 环境要求

- Node.js >= 12.0.0
- npm >= 6.0.0
- 快应用调试器

### 安装依赖

```bash
npm install
```

### 开发调试

```bash
npm run dev
```

### 构建打包

```bash
npm run build
# 或使用打包脚本
chmod +x build.sh
./build.sh
```

构建完成后，RPK 包将生成在 `dist/` 目录下。

## 配置说明

### MacCMS API 配置

1. 打开应用，进入"管理"页面
2. 使用默认账号登录（用户名: admin, 密码: admin123）
3. 在"API配置"中输入 MacCMS API 地址
4. 点击"测试连接"验证配置
5. 点击"保存配置"

API 地址格式示例：
```
http://your-maccms-site.com/api.php/provide/vod/
```

### 直播源配置

1. 在"管理"页面选择"直播源管理"
2. 输入 M3U 格式的直播源地址
3. 点击"导入直播源"

M3U 格式示例：
```
#EXTM3U
#EXTINF:-1,CCTV1
http://example.com/cctv1.m3u8
#EXTINF:-1,CCTV2
http://example.com/cctv2.m3u8
```

## 页面说明

### 首页 (Home.ux)
- 展示视频分类和推荐内容
- 支持搜索和分类筛选
- 点击视频进入详情页

### 视频详情 (VideoDetail.ux)
- 显示视频信息（海报、简介、演员等）
- 选集播放
- 内置视频播放器

### 直播列表 (Live.ux)
- 按分类展示直播频道
- 支持频道搜索
- 点击频道进入播放页

### 直播播放 (LivePlayer.ux)
- 全屏播放直播流
- 显示频道信息

### 后台管理 (Admin.ux)
- 管理员登录
- API 配置
- 直播源管理
- 应用信息

## API 接口

### MacCMS API

应用使用 MacCMS 标准 API 接口：

- 获取视频列表: `/api.php/provide/vod/`
- 获取视频详情: `/api.php/provide/vod/?ac=detail&ids={id}`
- 搜索视频: `/api.php/provide/vod/?wd={keyword}`
- 按分类获取: `/api.php/provide/vod/?t={type_id}`

### 直播源

支持标准 M3U 格式的直播源文件。

## 安全说明

- 默认管理员账号仅用于演示，生产环境请修改
- API 地址和直播源地址存储在本地
- 不会收集或上传用户数据

## 常见问题

### 1. 视频无法播放？
- 检查 API 地址是否正确
- 确认视频源地址有效
- 检查网络连接

### 2. 直播无法观看？
- 确认直播源地址格式正确
- 检查直播源是否可用
- 尝试更换其他直播源

### 3. 如何更换 API 源？
- 进入后台管理页面
- 在 API 配置中修改地址
- 保存并测试连接

## 开发说明

### 添加新页面

1. 在 `src/pages/` 目录创建 `.ux` 文件
2. 在 `manifest.json` 中注册路由
3. 使用 `router.push()` 进行页面跳转

### 修改样式

所有样式使用快应用 CSS 语法，支持：
- Flexbox 布局
- 基础 CSS 属性
- 焦点状态 (`:focus`)

### API 扩展

在 `src/services/api.js` 中添加新的 API 方法。

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎反馈。

---

**注意**: 本应用仅供学习交流使用，请遵守相关法律法规，不得用于商业用途。
