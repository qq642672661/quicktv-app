<?php
return [
    'app_name' => 'QuickTV 管理后台',
    'app_version' => '1.0.0',
    'timezone' => 'Asia/Shanghai',
    'default_lang' => 'zh-cn',
    'session_prefix' => 'quicktv_',
    'token_name' => '__token__',
    'admin_path' => '/admin',
    'upload_path' => __DIR__ . '/../public/uploads/',
    'upload_url' => '/uploads/',
    'allowed_upload_ext' => ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'm3u8'],
    'max_upload_size' => 100 * 1024 * 1024,
];
