# Installs the scrcpy build that matches this PC, connects to the phone, then opens the mirror.
# A Surface Pro uses the ARM64 build. An Intel or AMD PC uses the x64 build.
# The phone must already be listening on port 5555.
param(
    [string]$Device = ''
)

. "$PSScriptRoot\Common.ps1"

try {
    $Device = Resolve-Device $Device
    Ensure-ScrcpyTools
    Connect-AdbDevice -Device $Device

    Write-Host 'Starting scrcpy. Alt+B is Back. Alt+H is Home. Alt+S is Recent apps.'
    & $script:ScrcpyPath -s $Device
    exit $LASTEXITCODE
}
catch {
    Exit-ScrcpyError $_.Exception.Message
}
