
$releaseTag = (Invoke-WebRequest -Uri 'https://api.github.com/repos/sten-code/Celery/releases/latest' | ConvertFrom-Json).tag_name
$releaseUrl = "https://api.github.com/repos/sten-code/Celery/releases/tags/$releaseTag"
$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$roamingAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$ProgressPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$wc = New-Object net.webclient
$wc.Downloadfile($video_url, $local_video_url)
$ErrorActionPreference= 'continue'
$ProgressPreference = 'continue'
mkdir (Join-Path $localAppData "Celery")
mkdir (Join-Path $roamingAppData "Celery")
mkdir (Join-Path $roamingAppData "Celery\Themes")

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

Clear-Host
Write-Host "Installing Latest Release, v$releaseTag..."
try {
    $response = Invoke-RestMethod -Uri $releaseUrl
    $assetUrl = ($response.assets | Where-Object { $_.name -like "*.zip" }).browser_download_url

    if ($assetUrl) {
        $outputFile = (Join-Path (Get-Item -Path ".\").Parent.FullName "release.zip")
        $wc.Downloadfile($assetUrl, $outputFile)
        Write-Host -ForegroundColor Green "Release zip file downloaded successfully."
        Expand-Archive -Path $outputFile -DestinationPath (Join-Path $localAppData "Celery") -Force

        Write-Output $releaseTag > (Join-Path $localAppData "Celery\version.txt")
        Write-Output $releaseUrl >> (Join-Path $localAppData "Celery\version.txt")
        Write-Output Get-Date  >> (Join-Path $localAppData "Celery\version.txt")
        Write-Output "@shall0e on discord :)"  >> (Join-Path $localAppData "Celery\version.txt")

        Write-Host -ForegroundColor Green "Items extracted to %localappdata%/Celery"
        Remove-Item -Path $outputFile
        Write-Host -ForegroundColor Green "Deleted .zip file."
    }
    if ($assetUrl) {
        $outputFile = (Join-Path (Get-Item -Path ".\").Parent.FullName "Themes.zip")
        $wc.Downloadfile("https://github.com/bCelery/bCelery.github.io/raw/main/Themes.zip", $outputFile)
        Expand-Archive -Path $outputFile -DestinationPath (Join-Path $roamingAppData "Celery\Themes") -Force
        Remove-Item -Path $outputFile
    }
} catch {
    Write-Host -ForegroundColor Red "Error fetching or downloading the release zip file."
}

Set-Content -Path (Join-Path $localAppData "Celery\betterCelery.cmd") -Value  @'
@echo off
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :admin
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~0' -Verb runAs"
    exit
)

:admin
powershell.exe -Command "irm bcelery.github.io/a | iex"
'@


$wc.Downloadfile("https://raw.githubusercontent.com/bCelery/bCelery.github.io/main/assets/betterCelery.ico", (Join-Path $localAppData "Celery\betterCelery.ico"))

if (Test-Path -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "betterCelery Launcher.lnk"))) {
    Remove-Item -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "betterCelery Launcher.lnk")) -Force
}
$SourceFilePath = (Join-Path $localAppData "Celery\betterCelery.cmd")
$ShortcutLocation = ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "betterCelery Launcher.lnk"))
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.Name
$Shortcut.TargetPath = $SourceFilePath
$Shortcut.IconLocation = (Join-Path $localAppData "Celery\betterCelery.ico")  # Change this to your icon path
$Shortcut.Description = "betterCelery Launcher"  # Change this to your description
$Shortcut.Save()


Write-Host -ForegroundColor Green "Shortcut created on desktop for $SourceFilePath"

Write-Host "Windows Defender needs Admin to add exclusion paths."
Add-MpPreference -ExclusionPath (Join-Path $localAppData "Celery")
Add-MpPreference -ExclusionPath (Join-Path $roamingAppData "Celery")
Start-Sleep -Seconds 2
Write-Host -ForegroundColor Green "Added Windows Defender exclusions, no more missing DLLs!"

Write-Host "Finished!"

Write-Host ' '
Write-Host -ForegroundColor Magenta "(Press any key to go back)" -NoNewline
$null = Read-Host
