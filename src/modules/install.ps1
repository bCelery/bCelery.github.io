
$releaseTag = (Invoke-WebRequest -Uri 'https://api.github.com/repos/bCelery/Celery/releases/latest' | ConvertFrom-Json).tag_name
$releaseUrl = "https://api.github.com/repos/bCelery/Celery/releases/tags/$releaseTag"
$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$roamingAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$ProgressPreference = 'silentlycontinue'
$ProgressPreference = 'silentlycontinue'

$wc = New-Object net.webclient
$wc.Downloadfile($video_url, $local_video_url)
mkdir (Join-Path $localAppData "Celery")
mkdir (Join-Path $roamingAppData "Celery")
mkdir (Join-Path $roamingAppData "Celery\Themes")

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

Clear-Host
Write-Host "Installing Latest Release, v$releaseTag..."
try {
    $response = Invoke-RestMethod -Uri $releaseUrl
    $assetUrl = ($response.assets | Where-Object { $_.name -like "*.zip" }).browser_download_url

    if ($assetUrl) {
        Write-Host "Downloading latest release $releasetag..."
        $outputFile = (Join-Path (Get-Item -Path ".\").Parent.FullName "release.zip")
        $wc.Downloadfile($assetUrl, $outputFile)
        Write-Host -ForegroundColor Green "Release zip file downloaded successfully."
        Expand-Archive -Path $outputFile -DestinationPath (Join-Path $localAppData "Celery") -Force
        Write-Host -ForegroundColor Green "Items extracted to %localappdata%/Celery"

        Write-Host "Writing installation data..."
        Write-Output $releaseTag > (Join-Path $localAppData "Celery\version.txt")
        Write-Output $releaseUrl >> (Join-Path $localAppData "Celery\version.txt")
        Write-Output Get-Date  >> (Join-Path $localAppData "Celery\version.txt")
        Write-Output "@shall0e on discord :)"  >> (Join-Path $localAppData "Celery\version.txt")
        Write-Host -ForegroundColor Green "Release installed successfully!"
        Remove-Item -Path $outputFile
        Write-Host -ForegroundColor Green "Deleted original zip file"
    }

    Write-Host "Downloading custom themes..."
    $outputFile = (Join-Path (Get-Item -Path ".\").Parent.FullName "Themes.zip")
    $wc.Downloadfile("https://bCelery.github.io/src/Themes.zip", $outputFile)
    Write-Host -ForegroundColor Green "Downloaded Themes.zip!"
    Expand-Archive -Path $outputFile -DestinationPath (Join-Path $roamingAppData "Celery\Themes") -Force
    Write-Host -ForegroundColor Green "Extracted themes into roaming installation!"
    Remove-Item -Path $outputFile
    Write-Host -ForegroundColor Green "Deleted Original themes.zip"

    Write-Host "Downloading custom scripts..."
    $outputFile = (Join-Path (Get-Item -Path ".\").Parent.FullName "Themes.zip")
    $wc.Downloadfile("https://bCelery.github.io/src/Scripts.zip", $outputFile)
    Write-Host -ForegroundColor Green "Downloaded Scripts.zip!"
    Expand-Archive -Path $outputFile -DestinationPath (Join-Path $localAppData "Celery\Scripts") -Force
    Write-Host -ForegroundColor Green "Extracted scripts into roaming installation!"
    Remove-Item -Path $outputFile
    Write-Host -ForegroundColor Green "Deleted Original scripts.zip"

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
powershell.exe -Command "irm bcelery.github.io/src/gui.ps1 | iex"
'@

Write-Host "Downloading icon file..."
$wc.Downloadfile("https://raw.githubusercontent.com/bCelery/bCelery.github.io/main/assets/betterCelery.ico", (Join-Path $localAppData "Celery\betterCelery.ico"))
if (Test-Path -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "betterCelery Launcher.lnk"))) {
    Remove-Item -Path ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "betterCelery Launcher.lnk")) -Force
}
Write-Host "Building launcher shortcut..."
$SourceFilePath = (Join-Path $localAppData "Celery\betterCelery.cmd")
$ShortcutLocation = ([System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "bCelery.lnk"))
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.Name
$Shortcut.TargetPath = $SourceFilePath
$Shortcut.IconLocation = (Join-Path $localAppData "Celery\betterCelery.ico")  # Change this to your icon path
$Shortcut.Description = "bCelery"  # Change this to your description
$Shortcut.Save()
Write-Host -ForegroundColor Green "Shortcut created on desktop for $SourceFilePath"

Write-Host "Windows Defender needs Admin to add exclusion paths."
Add-MpPreference -ExclusionPath (Join-Path $localAppData "Celery")
Add-MpPreference -ExclusionPath (Join-Path $roamingAppData "Celery")
Start-Sleep -Seconds 2
Write-Host -ForegroundColor Green "Added Windows Defender exclusions, no more missing DLLs!"

Write-Host -ForegroundColor Cyan "Finished!"

Write-Host ' '
Write-Host -ForegroundColor Magenta "(Press any key to go back)" -NoNewline
$null = Read-Host
