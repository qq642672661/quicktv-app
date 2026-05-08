Write-Host "Starting MacCMS Auto Installation..." -ForegroundColor Green

Write-Host "`nStarting Docker containers..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "`nWaiting for MySQL to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "`nChecking MySQL connection..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$connected = $false

while (-not $connected -and $retryCount -lt $maxRetries) {
    $result = docker exec quicktv-mysql mysql -uroot -proot -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $connected = $true
        Write-Host "MySQL is ready!" -ForegroundColor Green
    } else {
        Write-Host "Waiting for MySQL... ($retryCount/$maxRetries)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        $retryCount++
    }
}

if (-not $connected) {
    Write-Host "Cannot connect to MySQL" -ForegroundColor Red
    exit 1
}

Write-Host "`nChecking database tables..." -ForegroundColor Yellow
$tableCheck = docker exec quicktv-mysql mysql -uroot -proot maccms10 -e "SHOW TABLES;" 2>&1

if ($tableCheck -like "*mac_admin*") {
    Write-Host "Database already initialized" -ForegroundColor Green
} else {
    Write-Host "Initializing database..." -ForegroundColor Yellow
    Get-Content "maccms-official\application\install\sql\install.sql" | docker exec -i quicktv-mysql mysql -uroot -proot maccms10
    Write-Host "Database initialized!" -ForegroundColor Green
}

Write-Host "`nCreating admin account..." -ForegroundColor Yellow
$adminPassword = "admin123"
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
$hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($adminPassword)))
$adminPasswordMd5 = $hash.Replace("-", "").ToLower()

$adminSql = "INSERT INTO mac_admin (admin_id, admin_name, admin_pwd, admin_random, admin_status, admin_auth, admin_login_time, admin_login_ip, admin_login_num) VALUES (1, 'admin', '$adminPasswordMd5', '', 1, '', UNIX_TIMESTAMP(), '', 0) ON DUPLICATE KEY UPDATE admin_pwd='$adminPasswordMd5';"

docker exec quicktv-mysql mysql -uroot -proot maccms10 -e $adminSql

Write-Host "`nRemoving install lock..." -ForegroundColor Yellow
docker exec quicktv-maccms rm -f /var/www/html/application/data/install/install.lock 2>$null

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "MacCMS Installation Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:8080/" -ForegroundColor Cyan
Write-Host "  Backend:  http://localhost:8080/admin.php" -ForegroundColor Cyan
Write-Host ""
Write-Host "Admin Account:" -ForegroundColor Yellow
Write-Host "  Username: admin" -ForegroundColor Green
Write-Host "  Password: admin123" -ForegroundColor Green
Write-Host ""
Write-Host "Database Info:" -ForegroundColor Yellow
Write-Host "  Host: mysql" -ForegroundColor White
Write-Host "  Database: maccms10" -ForegroundColor White
Write-Host "  User: root" -ForegroundColor White
Write-Host "  Password: root" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan
