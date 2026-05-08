# MacCMS 自动安装脚本
Write-Host "开始 MacCMS 自动安装..." -ForegroundColor Green

Write-Host "`n启动 Docker 容器..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "`n等待 MySQL 启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`n检查 MySQL 连接..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$connected = $false

while (-not $connected -and $retryCount -lt $maxRetries) {
    try {
        $result = docker exec quicktv-mysql mysql -uroot -proot -e "SELECT 1;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $connected = $true
            Write-Host "MySQL 已就绪！" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "等待 MySQL 准备就绪... ($retryCount/$maxRetries)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        $retryCount++
    }
    
    if (-not $connected) {
        Start-Sleep -Seconds 2
        $retryCount++
    }
}

if (-not $connected) {
    Write-Host "无法连接到 MySQL，请检查容器状态" -ForegroundColor Red
    exit 1
}

Write-Host "`n检查数据库表..." -ForegroundColor Yellow
$tableCheck = docker exec quicktv-mysql mysql -uroot -proot maccms10 -e "SHOW TABLES;" 2>&1

if ($tableCheck -match "mac_admin") {
    Write-Host "数据库已经初始化" -ForegroundColor Green
} else {
    Write-Host "初始化数据库..." -ForegroundColor Yellow
    Get-Content "maccms-official\application\install\sql\install.sql" | docker exec -i quicktv-mysql mysql -uroot -proot maccms10
    Write-Host "数据库初始化完成！" -ForegroundColor Green
}

Write-Host "`n创建管理员账号..." -ForegroundColor Yellow
$adminPassword = "admin123"
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
$hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($adminPassword)))
$adminPasswordMd5 = $hash.Replace("-", "").ToLower()

$adminSql = @"
INSERT INTO mac_admin (admin_id, admin_name, admin_pwd, admin_random, admin_status, admin_auth, admin_login_time, admin_login_ip, admin_login_num) 
VALUES (1, 'admin', '$adminPasswordMd5', '', 1, '', UNIX_TIMESTAMP(), '', 0)
ON DUPLICATE KEY UPDATE admin_pwd='$adminPasswordMd5';
"@

docker exec quicktv-mysql mysql -uroot -proot maccms10 -e $adminSql

Write-Host "`n配置系统设置..." -ForegroundColor Yellow
$systemSql = @"
INSERT INTO mac_website (website_id, website_name, website_title, website_url, website_logo, website_status) 
VALUES (1, 'QuickTV', 'QuickTV视频管理系统', 'http://localhost:8080', '', 1)
ON DUPLICATE KEY UPDATE website_name='QuickTV';
"@

docker exec quicktv-mysql mysql -uroot -proot maccms10 -e $systemSql 2>$null

Write-Host "`n删除安装锁定文件..." -ForegroundColor Yellow
docker exec quicktv-maccms rm -f /var/www/html/application/data/install/install.lock 2>$null

Write-Host "`n" -NoNewline
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "MacCMS 自动安装完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "访问地址：" -ForegroundColor Yellow
Write-Host "  前台: " -NoNewline -ForegroundColor White
Write-Host "http://localhost:8080/" -ForegroundColor Cyan
Write-Host "  后台: " -NoNewline -ForegroundColor White
Write-Host "http://localhost:8080/admin.php" -ForegroundColor Cyan
Write-Host ""
Write-Host "管理员账号：" -ForegroundColor Yellow
Write-Host "  用户名: " -NoNewline -ForegroundColor White
Write-Host "admin" -ForegroundColor Green
Write-Host "  密码: " -NoNewline -ForegroundColor White
Write-Host "admin123" -ForegroundColor Green
Write-Host ""
Write-Host "数据库信息：" -ForegroundColor Yellow
Write-Host "  主机: mysql" -ForegroundColor White
Write-Host "  数据库: maccms10" -ForegroundColor White
Write-Host "  用户: root" -ForegroundColor White
Write-Host "  密码: root" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
