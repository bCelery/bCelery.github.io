$roamingAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$ErrorActionPreference= 'silentlycontinue'
$ProgressPreference = 'silentlycontinue'

function betterPause {
    param (
        [string]$Message
    )

    if ($Message) {
        Write-Host -ForegroundColor Red $Message
    }
    Write-Host ' '
    Write-Host -ForegroundColor Magenta "(Press Enter to go back)" -NoNewline
    $null = Read-Host
}

function Remove-FolderWithRetry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        
        [int]$MaxAttempts = 3
    )
    $attempts = 0
    $deleted = $false
    while (-not $deleted -and $attempts -lt $MaxAttempts) {
        try {
            Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction Stop
            $deleted = $true
            Write-Host -ForegroundColor Green "Folder '$FolderPath' deleted successfully."
        }
        catch {
            $attempts++
            Start-Sleep -Seconds 1
        }
    }
    if (-not $deleted) {
        Write-Host -ForegroundColor Red "Failed to delete folder '$FolderPath' after $MaxAttempts attempts."
    }
}

# Usage example:

Clear-Host
Stop-Process -Name "Roblox" -Force
Stop-Process -Name "RobloxApp" -Force
Stop-Process -Name "Roblox Game Client" -Force
Stop-Process -Name "RobloxPlayerBeta" -Force
Stop-Process -Name "RobloxPlayerBeta.exe" -Force
Write-Host -ForegroundColor Green "Killed Roblox"

Stop-Process -Name "CefSharp.BrowserSubprocess" -Force
Stop-Process -Name "CeleryInject" -Force
Stop-Process -Name "CeleryInject" -Force
Write-Host -ForegroundColor Green "Killed Celery Injector"

Stop-Process -Name "Celery" -Force
Stop-Process -Name "CeleryApp" -Force
Stop-Process -Name "Main" -Force
Write-Host -ForegroundColor Green "Killed Celery GUI"

Stop-Process -Name "Node.js JavaScript Runtime" -Force
Write-Host -ForegroundColor Green "Killed Server Manager"

Remove-FolderWithRetry -FolderPath (Join-Path $roamingAppData "Celery") -MaxAttempts 5

Write-Host Celery Repaired!

betterPause