# Docker 镜像源配置脚本
# 自动配置国内镜像源以解决网络问题

Write-Host "=== 配置 Docker 镜像源 ===" -ForegroundColor Cyan

$dockerConfigPath = "$env:USERPROFILE\.docker"
$daemonJsonPath = "$dockerConfigPath\daemon.json"

# 创建配置目录
if (-not (Test-Path $dockerConfigPath)) {
    New-Item -ItemType Directory -Path $dockerConfigPath -Force | Out-Null
}

# 配置内容
$config = @{
    "registry-mirrors" = @(
        "https://docker.m.daocloud.io",
        "https://docker.1panel.live",
        "https://hub.rat.dev"
    )
    "insecure-registries" = @()
    "debug" = $false
    "experimental" = $false
}

# 写入配置
$config | ConvertTo-Json -Depth 10 | Set-Content -Path $daemonJsonPath -Encoding UTF8

Write-Host "配置文件已创建: $daemonJsonPath" -ForegroundColor Green
Write-Host ""
Write-Host "请重启 Docker Desktop 以应用配置" -ForegroundColor Yellow
Write-Host ""
Write-Host "重启后运行: .\trae-manager.ps1 start" -ForegroundColor Cyan
