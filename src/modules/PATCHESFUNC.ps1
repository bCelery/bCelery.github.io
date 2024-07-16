$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$roamingAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$ErrorActionPreference= 'silentlycontinue'
$ProgressPreference = 'silentlycontinue'

function InjectionFix1 {
    Stop-Process -Name "Celery"
    Stop-Process -Name "CeleryInject"
    Stop-Process -Name "Node.JS Javascript Runtime"
    Start-Process -FilePath (Join-Path $localAppData "Celery\Celery.exe")
    Write-Host -ForegroundColor Green ('Applied fix "'+$($arrayfunc[$hostInput][1])+'" to Celery!')
}
function InjectionFix2 {
    Stop-Process -Name "Node.JS Javascript Runtime"
    Stop-Process -Name "CeleryInject"
    Start-Process -FilePath (Join-Path $localAppData "Celery\CeleryInject.exe")
    Write-Host -ForegroundColor Green ('Applied fix "'+$($arrayfunc[$hostInput][1])+'" to Celery!')
}
