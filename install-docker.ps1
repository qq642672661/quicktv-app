# Docker Desktop 自动安装脚本
# 请以管理员身份运行此脚本

Write-Host "=== Docker Desktop 自动安装脚本 ===" -ForegroundColor Green

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "错误：此脚本需要管理员权限！" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell，选择'以管理员身份运行'，然后再执行此脚本。" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "`n检测到管理员权限，继续安装..." -ForegroundColor Green

# 检查 Chocolatey 是否已安装
Write-Host "`n检查 Chocolatey..." -ForegroundColor Yellow
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue

if (-not $chocoInstalled) {
    Write-Host "Chocolatey 未安装，正在安装..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # 刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "Chocolatey 已安装" -ForegroundColor Green
}

# 清理可能的锁文件
Write-Host "`n清理 Chocolatey 锁文件..." -ForegroundColor Yellow
$lockFile = "C:\ProgramData\chocolatey\lib\f7305e8da17e94357fea6af6fcda055f18a81cef"
if (Test-Path $lockFile) {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
}

# 检查 Docker Desktop 是否已安装
Write-Host "`n检查 Docker Desktop..." -ForegroundColor Yellow
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue

if ($dockerInstalled) {
    Write-Host "Docker Desktop 已安装" -ForegroundColor Green
    docker --version
} else {
    Write-Host "正在安装 Docker Desktop..." -ForegroundColor Yellow
    Write-Host "这可能需要几分钟时间，请耐心等待..." -ForegroundColor Cyan
    
    # 使用 Chocolatey 安装 Docker Desktop
    choco install docker-desktop -y --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nDocker Desktop 安装成功！" -ForegroundColor Green
    } else {
        Write-Host "`nDocker Desktop 安装失败，尝试手动下载安装..." -ForegroundColor Yellow
        
        # 下载 Docker Desktop 安装程序
        $installerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
        $installerPath = "$env:TEMP\DockerDesktopInstaller.exe"
        
        Write-Host "正在下载 Docker Desktop..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
        
        Write-Host "正在安装到 D:\Docker..." -ForegroundColor Yellow
        Start-Process -FilePath $installerPath -ArgumentList "install --installation-dir=D:\Docker" -Wait
        
        Remove-Item $installerPath -Force
    }
}

# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "`n=== 安装完成 ===" -ForegroundColor Green
Write-Host "`n重要提示：" -ForegroundColor Yellow
Write-Host "1. 需要重启电脑以完成 Docker Desktop 安装" -ForegroundColor Cyan
Write-Host "2. 重启后，启动 Docker Desktop 应用程序" -ForegroundColor Cyan
Write-Host "3. 等待 Docker Desktop 完全启动（托盘图标变为绿色）" -ForegroundColor Cyan
Write-Host "4. 然后在项目目录执行：docker compose up -d" -ForegroundColor Cyan

Write-Host "`n是否现在重启电脑？(Y/N)" -ForegroundColor Yellow
$restart = Read-Host

if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "正在重启电脑..." -ForegroundColor Green
    Restart-Computer -Force
} else {
    Write-Host "请稍后手动重启电脑" -ForegroundColor Yellow
}
