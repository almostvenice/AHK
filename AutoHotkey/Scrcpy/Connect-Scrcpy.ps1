# Connects adb to the phone, using the adb.exe shipped with the matching scrcpy build.
param(
    [string]$Device = ''
)

. "$PSScriptRoot\Common.ps1"

try {
    $Device = Resolve-Device $Device
    Ensure-ScrcpyTools
    Connect-AdbDevice -Device $Device
}
catch {
    Exit-ScrcpyError $_.Exception.Message
}
