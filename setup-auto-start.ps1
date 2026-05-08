if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "需要管理员权限，正在重新启动..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-File", $MyInvocation.MyCommand.Path
    exit
}

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "配置开机自动启动 MacCMS 后台" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$taskName = "MacCMS-AutoStart"
$scriptPath = "D:\GitCangku2\quicktv-app-project\auto-start-after-reboot.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try {
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "删除现有任务..." -ForegroundColor Gray
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
    
    Write-Host "创建计划任务..." -ForegroundColor Yellow
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    
    Write-Host ""
    Write-Host "✓ 自动启动任务已配置" -ForegroundColor Green
    Write-Host ""
    Write-Host "下次登录时，MacCMS 后台将自动启动" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "管理任务：" -ForegroundColor Cyan
    Write-Host "  查看任务: Get-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host "  删除任务: Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false" -ForegroundColor Gray
    Write-Host "  立即运行: Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "是否立即测试运行？(Y/N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host ""
        Write-Host "启动任务..." -ForegroundColor Yellow
        Start-ScheduledTask -TaskName $taskName
        Write-Host "✓ 任务已启动，请查看新窗口" -ForegroundColor Green
    }
    
} catch {
    Write-Host ""
    Write-Host "✗ 配置失败: $_" -ForegroundColor Red
    exit 1
}
