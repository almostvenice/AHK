Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Phone that is already listening for wireless debugging.
$script:DefaultDevice = '192.168.4.85:5555'

function Update-SessionPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Test-CommandAvailable {
    param([Parameter(Mandatory)][string]$Name)
    Update-SessionPath
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$CommandName
    )

    if (-not (Get-Command -Name 'winget' -ErrorAction SilentlyContinue)) {
        throw 'winget is not available. Install App Installer from the Microsoft Store, then run this again.'
    }

    Write-Host "Installing $Id ..."
    & winget install --exact --id $Id --accept-package-agreements --accept-source-agreements --disable-interactivity
    $installExit = $LASTEXITCODE
    Update-SessionPath

    if (Test-CommandAvailable $CommandName) {
        return
    }

    throw "winget could not install $Id (exit $installExit), and $CommandName is still not on PATH."
}

function Ensure-Command {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$WingetId
    )

    if (Test-CommandAvailable $Name) {
        return
    }

    Install-WingetPackage -Id $WingetId -CommandName $Name
}

function Resolve-Device {
    param([string]$Device)

    if ([string]::IsNullOrWhiteSpace($Device)) {
        return $script:DefaultDevice
    }

    return $Device.Trim()
}

function Stop-AdbProcesses {
    Get-Process -Name 'adb' -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
}

function Start-AdbServerOnce {
    param(
        [Parameter(Mandatory)][string]$AdbPath,
        [Parameter(Mandatory)][int]$TimeoutSeconds
    )

    # adb hangs on Windows when its first start inherits a redirected console.
    # ShellExecute gives the server its own console so startup can finish.
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $AdbPath
    $startInfo.Arguments = 'start-server'
    $startInfo.UseShellExecute = $true
    $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $startInfo
    [void]$proc.Start()

    if (-not $proc.WaitForExit($TimeoutSeconds * 1000)) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        return $false
    }

    return ($proc.ExitCode -eq 0)
}

function Start-AdbServer {
    $adb = (Get-Command -Name 'adb' -ErrorAction Stop).Source

    if (Start-AdbServerOnce -AdbPath $adb -TimeoutSeconds 15) {
        return
    }

    Write-Host 'adb server did not finish starting. Closing stuck adb and trying again...'
    Stop-AdbProcesses
    Start-Sleep -Seconds 1

    if (-not (Start-AdbServerOnce -AdbPath $adb -TimeoutSeconds 15)) {
        Stop-AdbProcesses
        throw 'adb is stuck starting its server on port 5037. In Task Manager, end every adb.exe, allow adb through Windows Firewall if a prompt is open, then run this again.'
    }
}

function Connect-AdbDevice {
    param([Parameter(Mandatory)][string]$Device)

    Start-AdbServer
    Write-Host "Connecting to $Device ..."
    $connectOutput = & adb connect $Device 2>&1 | Out-String
    Write-Host $connectOutput.Trim()

    if ($connectOutput -match 'failed to connect|cannot connect|unable to connect') {
        throw "Could not connect to $Device. On the phone, turn on Wireless debugging and confirm this IP and port."
    }

    $listing = & adb devices 2>&1 | Out-String
    $pattern = '(?m)^' + [regex]::Escape($Device) + '\s+device\s*$'
    if ($listing -notmatch $pattern) {
        Write-Host $listing.Trim()
        throw "Device $Device is not online."
    }

    Write-Host "Connected: $Device"
}

function Exit-ScrcpyError {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host $Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'Press Enter to close.'
    [void](Read-Host)
    exit 1
}
