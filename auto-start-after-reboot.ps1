$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "MacCMS 后台自动启动脚本" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$maxRetries = 30
$retryCount = 0
$dockerReady = $false

Write-Host "等待 Docker Desktop 启动..." -ForegroundColor Yellow

while (-not $dockerReady -and $retryCount -lt $maxRetries) {
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dockerReady = $true
            Write-Host "✓ Docker Desktop 已就绪" -ForegroundColor Green
        } else {
            throw "Docker 未就绪"
        }
    } catch {
        $retryCount++
        Write-Host "等待中... ($retryCount/$maxRetries)" -ForegroundColor Gray
        Start-Sleep -Seconds 10
    }
}

if (-not $dockerReady) {
    Write-Host "✗ Docker Desktop 启动超时" -ForegroundColor Red
    Write-Host "请手动启动 Docker Desktop，然后运行: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "启动 MacCMS 后台服务..." -ForegroundColor Yellow

try {
    Set-Location "D:\GitCangku2\quicktv-app-project"
    
    Write-Host "拉取 Docker 镜像..." -ForegroundColor Gray
    docker compose pull
    
    Write-Host "启动容器..." -ForegroundColor Gray
    docker compose up -d
    
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "✓ MacCMS 后台启动成功！" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "服务信息：" -ForegroundColor Cyan
    Write-Host "  API 地址: http://localhost:8080" -ForegroundColor White
    Write-Host "  管理员账号: admin" -ForegroundColor White
    Write-Host "  管理员密码: password" -ForegroundColor White
    Write-Host ""
    Write-Host "数据库信息：" -ForegroundColor Cyan
    Write-Host "  主机: localhost:3306" -ForegroundColor White
    Write-Host "  数据库: maccms" -ForegroundColor White
    Write-Host "  用户名: root" -ForegroundColor White
    Write-Host "  密码: rootpassword" -ForegroundColor White
    Write-Host ""
    
    Write-Host "等待服务完全启动..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    Write-Host "测试 API 连接..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✓ API 响应正常" -ForegroundColor Green
    } catch {
        Write-Host "⚠ API 可能还在启动中，请稍后访问" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "查看容器状态：" -ForegroundColor Cyan
    docker compose ps
    
    Write-Host ""
    Write-Host "查看日志命令: docker compose logs -f" -ForegroundColor Gray
    Write-Host "停止服务命令: docker compose down" -ForegroundColor Gray
    
} catch {
    Write-Host ""
    Write-Host "✗ 启动失败: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查 Docker Desktop 是否正常运行" -ForegroundColor Yellow
    exit 1
}
