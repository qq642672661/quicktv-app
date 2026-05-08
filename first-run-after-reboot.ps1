# 重启后自动配置脚本

Write-Host "=== Docker Desktop 首次启动配置 ===" -ForegroundColor Cyan
Write-Host ""

# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 启动 Docker Desktop
Write-Host "启动 Docker Desktop..." -ForegroundColor Yellow
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

Write-Host "等待 Docker Desktop 初始化（这可能需要 3-5 分钟）..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# 等待 Docker 就绪
$maxRetries = 60
$retryCount = 0
$dockerReady = $false

while (-not $dockerReady -and $retryCount -lt $maxRetries) {
    try {
        $result = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dockerReady = $true
            Write-Host "✓ Docker Desktop 已就绪！" -ForegroundColor Green
        }
    } catch {
    }
    
    if (-not $dockerReady) {
        $retryCount++
        if ($retryCount % 6 -eq 0) {
            Write-Host "仍在等待... ($retryCount/$maxRetries)" -ForegroundColor Gray
        }
        Start-Sleep -Seconds 5
    }
}

if (-not $dockerReady) {
    Write-Host ""
    Write-Host "✗ Docker Desktop 启动超时" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "1. WSL 2 需要手动配置" -ForegroundColor White
    Write-Host "2. 虚拟化未在 BIOS 中启用" -ForegroundColor White
    Write-Host "3. Docker Desktop 需要接受许可协议" -ForegroundColor White
    Write-Host ""
    Write-Host "请手动打开 Docker Desktop 并完成初始配置" -ForegroundColor Cyan
    pause
    exit 1
}

# 启动 MacCMS 后台
Write-Host ""
Write-Host "启动 MacCMS 后台服务..." -ForegroundColor Yellow

try {
    Set-Location "D:\GitCangku2\quicktv-app-project"
    
    Write-Host "拉取 Docker 镜像..." -ForegroundColor Gray
    docker compose pull
    
    Write-Host "启动容器..." -ForegroundColor Gray
    docker compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=== MacCMS 后台启动成功！===" -ForegroundColor Green
        Write-Host ""
        Write-Host "服务信息：" -ForegroundColor Cyan
        Write-Host "  API 地址: http://localhost:8080" -ForegroundColor White
        Write-Host "  管理员账号: admin" -ForegroundColor White
        Write-Host "  管理员密码: password" -ForegroundColor White
        Write-Host ""
        
        Start-Sleep -Seconds 10
        
        Write-Host "容器状态：" -ForegroundColor Cyan
        docker compose ps
        
        Write-Host ""
        Write-Host "测试 API..." -ForegroundColor Yellow
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -UseBasicParsing
            Write-Host "✓ API 响应正常" -ForegroundColor Green
        } catch {
            Write-Host "⚠ API 可能还在启动中" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host ""
    Write-Host "✗ 启动失败: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
pause
