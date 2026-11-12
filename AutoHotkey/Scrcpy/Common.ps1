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

function Connect-AdbDevice {
    param([Parameter(Mandatory)][string]$Device)

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
