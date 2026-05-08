# Docker Desktop 迁移到 D 盘脚本

Write-Host "=== Docker Desktop 迁移到 D 盘 ===" -ForegroundColor Green

# 1. 停止 Docker Desktop
Write-Host "`n1. 停止 Docker Desktop..." -ForegroundColor Yellow
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# 2. 关闭 WSL
Write-Host "`n2. 关闭 WSL..." -ForegroundColor Yellow
wsl --shutdown

# 3. 创建目标目录
Write-Host "`n3. 创建目标目录..." -ForegroundColor Yellow
$targetPath = "D:\Docker\wsl"
New-Item -ItemType Directory -Force -Path $targetPath | Out-Null

# 4. 导出 docker-desktop
Write-Host "`n4. 导出 docker-desktop..." -ForegroundColor Yellow
wsl --export docker-desktop "$targetPath\docker-desktop.tar"

# 5. 导出 docker-desktop-data
Write-Host "`n5. 导出 docker-desktop-data..." -ForegroundColor Yellow
wsl --export docker-desktop-data "$targetPath\docker-desktop-data.tar"

# 6. 注销原有的 WSL 发行版
Write-Host "`n6. 注销原有的 WSL 发行版..." -ForegroundColor Yellow
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# 7. 导入到新位置
Write-Host "`n7. 导入到 D 盘..." -ForegroundColor Yellow
wsl --import docker-desktop "$targetPath\docker-desktop" "$targetPath\docker-desktop.tar" --version 2
wsl --import docker-desktop-data "$targetPath\docker-desktop-data" "$targetPath\docker-desktop-data.tar" --version 2

# 8. 清理临时文件
Write-Host "`n8. 清理临时文件..." -ForegroundColor Yellow
Remove-Item "$targetPath\docker-desktop.tar" -Force
Remove-Item "$targetPath\docker-desktop-data.tar" -Force

Write-Host "`n=== 迁移完成！===" -ForegroundColor Green
Write-Host "Docker 数据已迁移到: $targetPath" -ForegroundColor Cyan
Write-Host "现在可以启动 Docker Desktop 了" -ForegroundColor Cyan
