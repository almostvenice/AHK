# Connects adb to the phone. Installs platform-tools first when adb is missing.
param(
    [string]$Device = ''
)

. "$PSScriptRoot\Common.ps1"

try {
    $Device = Resolve-Device $Device
    Ensure-Command -Name 'adb' -WingetId 'Google.PlatformTools'
    Connect-AdbDevice -Device $Device
}
catch {
    Exit-ScrcpyError $_.Exception.Message
}
