# Closes the mirror window and disconnects adb from the phone.
param(
    [string]$Device = ''
)

. "$PSScriptRoot\Common.ps1"

try {
    $Device = Resolve-Device $Device

    $procs = Get-Process -Name 'scrcpy' -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force
        Write-Host 'Closed scrcpy.'
    }
    else {
        Write-Host 'scrcpy is not running.'
    }

    if (Test-CommandAvailable 'adb') {
        & adb disconnect $Device | Out-Host
        Write-Host "Disconnected $Device."
    }
    else {
        Write-Host 'adb is not installed, so there was no adb connection to close.'
    }
}
catch {
    Exit-ScrcpyError $_.Exception.Message
}
