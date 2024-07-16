$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$roamingAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ErrorActionPreference= 'silentlycontinue'
$ProgressPreference = 'silentlycontinue'

function betterPause {
    param (
        [string]$Message,
        [string]$Color="Red"
    )
    if ($Message -ne $null) {
        Write-Host -ForegroundColor $Color $Message
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
Clear-Host
Write-Host "Windows Defender needs Admin to add exclusion paths."
Add-MpPreference -ExclusionPath (Join-Path $localAppData "Celery")
Add-MpPreference -ExclusionPath (Join-Path $roamingAppData "Celery")
Start-Sleep -Seconds 2
Write-Host -ForegroundColor Green "Added Windows Defender exclusions."

Stop-Process -Name "Roblox" -Force
Stop-Process -Name "RobloxApp" -Force
Stop-Process -Name "Roblox Game Client" -Force
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
Remove-FolderWithRetry -FolderPath (Join-Path $localAppData "Celery") -MaxAttempts 5

powershell.exe -File (Join-Path $scriptDir "\install.ps1")