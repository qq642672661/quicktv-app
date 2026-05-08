# Docker Desktop 安装后启动脚本

Write-Host "=== 启动 MacCMS 后台服务 ===" -ForegroundColor Green

# 检查 Docker 是否运行
Write-Host "`n检查 Docker 状态..." -ForegroundColor Yellow
$dockerRunning = docker info 2>$null

if (-not $dockerRunning) {
    Write-Host "Docker Desktop 未运行！" -ForegroundColor Red
    Write-Host "请先启动 Docker Desktop 应用程序，等待其完全启动后再运行此脚本。" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Docker 正在运行" -ForegroundColor Green

# 进入项目目录
$projectPath = "D:\GitCangku2\quicktv-app-project"
Set-Location $projectPath

Write-Host "`n当前目录：$projectPath" -ForegroundColor Cyan

# 停止可能存在的旧容器
Write-Host "`n停止旧容器..." -ForegroundColor Yellow
docker compose down 2>$null

# 启动服务
Write-Host "`n启动 MacCMS 后台服务..." -ForegroundColor Yellow
Write-Host "这可能需要几分钟时间（首次启动需要下载镜像）..." -ForegroundColor Cyan

docker compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== 服务启动成功！===" -ForegroundColor Green
    
    # 等待服务完全启动
    Write-Host "`n等待服务完全启动..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # 显示服务状态
    Write-Host "`n服务状态：" -ForegroundColor Cyan
    docker compose ps
    
    Write-Host "`n=== 访问信息 ===" -ForegroundColor Green
    Write-Host "后台 API 地址：http://localhost:8080" -ForegroundColor Cyan
    Write-Host "数据库地址：localhost:3306" -ForegroundColor Cyan
    Write-Host "默认账号：admin" -ForegroundColor Cyan
    Write-Host "默认密码：password" -ForegroundColor Cyan
    
    Write-Host "`n测试 API 连接..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✓ API 连接成功！" -ForegroundColor Green
    } catch {
        Write-Host "⚠ API 暂时无法访问，可能还在启动中..." -ForegroundColor Yellow
        Write-Host "请稍等片刻后访问：http://localhost:8080" -ForegroundColor Cyan
    }
    
    Write-Host "`n查看日志命令：docker compose logs -f" -ForegroundColor Yellow
    Write-Host "停止服务命令：docker compose down" -ForegroundColor Yellow
    
} else {
    Write-Host "`n服务启动失败！" -ForegroundColor Red
    Write-Host "查看错误日志：" -ForegroundColor Yellow
    docker compose logs
}

Write-Host "`n按任意键退出..." -ForegroundColor Gray
pause
