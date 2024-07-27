$localAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::localApplicationData)
$roamingAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
$ErrorActionPreference= 'silentlycontinue'
$ProgressPreference = 'silentlycontinue'
Clear-Host

function betterPause {
    param (
        [string]$Message,
        [string]$Color="Red"
    )
    if ($Message -ne $null) {
        Write-Host -ForegroundColor $Color $Message
    }
    Write-Host -ForegroundColor Magenta "(Press Enter to go back)" -NoNewline
    $null = Read-Host
}

$runningOnline = $true
function powershellEmulator {
    param (
        [bool]$On=$true,
        $Directory
    )
    if ($On -eq $false) {
        Write-Host 'Currently running on Desktop, make sure to switch runningOnline to $true before publishing!' -ForegroundColor Cyan
        pause
        powershell.exe -File (Join-Path $scriptDir $Directory)
    } else {
        Invoke-RestMethod "https://bcelery.github.io/src/$Directory" | Invoke-Expression
    }
}
powershellEmulator -On $runningOnline -Directory 'modules/PATCHESFUNC.ps1'

# yall, this is a huge improvement to my old system this is automatic and easy to mod

$arrayfunc = @(
    @("Go Back","Exit"),
    # format, @ ( Text-Display , Patch-Function )
    @('"Scanning" spam',"InjectionFix1"),
    @("Failed to establish a script connection","InjectionFix1"),
    @("Deserializer cursor position mismatch","InjectionFix2"),
    @("Wrong roblox version detected","Write-Host `"This may be the result of your Roblox Channel not being on Live, or Celery hasn't been updated to support a new version.`"")
)

for (;;) {
Clear-Host
for ($i = 0; $i -lt $arrayfunc.Length; $i++) {
    Write-Host "[$($i)] $($arrayfunc[$i][0])" -ForegroundColor Yellow
}
Write-Host " "
Write-Host -ForegroundColor Cyan "FixerSelection > " -NoNewline
$hostInput = Read-Host
Write-Host " "
Invoke-Expression $arrayfunc[$hostInput][1]
Write-Host -ForegroundColor Green "Ran Patch"
betterPause
}
Exit-PSSession