# Closes the mirror window and disconnects adb from the phone.
param(
    [string]$Device = ''
)

. "$PSScriptRoot\Common.ps1"

try {
    $Device = Resolve-Device $Device

    $mirror = Get-Process -Name 'scrcpy' -ErrorAction SilentlyContinue
    if ($mirror) {
        $mirror | Stop-Process -Force
        Write-Host 'Closed scrcpy.'
    }
    else {
        Write-Host 'scrcpy is not running.'
    }

    # Stopping adb drops the phone connection, including a server stuck on port 5037.
    $adb = Get-Process -Name 'adb' -ErrorAction SilentlyContinue
    if ($adb) {
        Stop-AdbProcesses
        Write-Host "Disconnected $Device."
    }
    else {
        Write-Host "No adb server was running for $Device."
    }
}
catch {
    Exit-ScrcpyError $_.Exception.Message
}
