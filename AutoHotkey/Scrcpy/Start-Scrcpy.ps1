# Installs adb and scrcpy when they are missing, connects to the phone, then opens the mirror.
# Another PC only needs Windows with winget. The phone must already be listening on port 5555.
param(
    [string]$Device = ''
)

. "$PSScriptRoot\Common.ps1"

try {
    $Device = Resolve-Device $Device
    Ensure-Command -Name 'adb' -WingetId 'Google.PlatformTools'
    Ensure-Command -Name 'scrcpy' -WingetId 'Genymobile.scrcpy'
    Connect-AdbDevice -Device $Device

    Write-Host 'Starting scrcpy. Alt+B is Back. Alt+H is Home. Alt+S is Recent apps.'
    & scrcpy -s $Device
    exit $LASTEXITCODE
}
catch {
    Exit-ScrcpyError $_.Exception.Message
}
