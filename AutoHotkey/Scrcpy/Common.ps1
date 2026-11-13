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

function Get-NativeCpuArchitecture {
    if (-not ('CpuArch' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class CpuArch {
    [StructLayout(LayoutKind.Sequential)]
    public struct SYSTEM_INFO {
        public ushort wProcessorArchitecture;
        public ushort wReserved;
        public uint dwPageSize;
        public IntPtr lpMinimumApplicationAddress;
        public IntPtr lpMaximumApplicationAddress;
        public IntPtr dwActiveProcessorMask;
        public uint dwNumberOfProcessors;
        public uint dwProcessorType;
        public uint dwAllocationGranularity;
        public ushort wProcessorLevel;
        public ushort wProcessorRevision;
    }

    [DllImport("kernel32.dll")]
    public static extern void GetNativeSystemInfo(out SYSTEM_INFO lpSystemInfo);

    public static string Native() {
        SYSTEM_INFO info;
        GetNativeSystemInfo(out info);
        if (info.wProcessorArchitecture == 12) return "ARM64";
        if (info.wProcessorArchitecture == 9) return "x64";
        if (info.wProcessorArchitecture == 0) return "x86";
        return "unknown";
    }
}
'@
    }

    return [CpuArch]::Native()
}

function Get-PeMachine {
    param([Parameter(Mandatory)][string]$Path)

    $stream = $null
    $reader = $null
    try {
        $stream = [System.IO.File]::Open($Path, 'Open', 'Read', 'ReadWrite')
        $reader = New-Object System.IO.BinaryReader($stream)
        [void]$stream.Seek(0x3C, 'Begin')
        $peOffset = $reader.ReadInt32()
        [void]$stream.Seek($peOffset + 4, 'Begin')
        switch ($reader.ReadUInt16()) {
            0xAA64 { return 'ARM64' }
            0x8664 { return 'x64' }
            0x014C { return 'x86' }
            default { return 'unknown' }
        }
    }
    finally {
        if ($reader) { $reader.Dispose() }
        elseif ($stream) { $stream.Dispose() }
    }
}

function Find-ScrcpyExecutable {
    param([Parameter(Mandatory)][string]$Architecture)

    $candidates = @()
    $localRoot = Join-Path $env:LOCALAPPDATA 'Scrcpy'
    $wingetRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'

    if (Test-Path -LiteralPath $localRoot) {
        $candidates += @(Get-ChildItem -LiteralPath $localRoot -Recurse -Filter 'scrcpy.exe' -ErrorAction SilentlyContinue)
    }
    if (Test-Path -LiteralPath $wingetRoot) {
        $candidates += @(Get-ChildItem -LiteralPath $wingetRoot -Directory -Filter 'Genymobile.scrcpy*' -ErrorAction SilentlyContinue |
            ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Recurse -Filter 'scrcpy.exe' -ErrorAction SilentlyContinue })
    }

    Update-SessionPath
    $command = Get-Command -Name 'scrcpy' -ErrorAction SilentlyContinue
    if ($command) {
        $candidates += @(Get-Item -LiteralPath $command.Source -ErrorAction SilentlyContinue)
    }

    foreach ($candidate in $candidates) {
        if (-not $candidate) { continue }
        try {
            if ((Get-PeMachine -Path $candidate.FullName) -eq $Architecture) {
                return $candidate.FullName
            }
        }
        catch {
            continue
        }
    }

    return $null
}

function Install-ScrcpyWithWinget {
    param([Parameter(Mandatory)][string]$Architecture)

    $wingetArch = switch ($Architecture) {
        'ARM64' { 'arm64' }
        'x64' { 'x64' }
        'x86' { 'x86' }
        default { throw "No scrcpy installer is available for $Architecture." }
    }

    if (-not (Get-Command -Name 'winget' -ErrorAction SilentlyContinue)) {
        return
    }

    Write-Host "Installing scrcpy for $wingetArch ..."
    & winget install --exact --id Genymobile.scrcpy --architecture $wingetArch --accept-package-agreements --accept-source-agreements --disable-interactivity
    Update-SessionPath
}

function Install-ScrcpyFromRelease {
    param([Parameter(Mandatory)][string]$Architecture)

    $releases = @{
        ARM64 = @{
            Name = 'scrcpy-winarm64-v5.0.1'
            Url = 'https://github.com/Genymobile/scrcpy/releases/download/v5.0.1/scrcpy-winarm64-v5.0.1.zip'
            Sha256 = '16c3fc2068df64946f670e3504b4752073ebae47a416a45b46e79a5ab19c689b'
        }
        x64 = @{
            Name = 'scrcpy-win64-v5.0.1'
            Url = 'https://github.com/Genymobile/scrcpy/releases/download/v5.0.1/scrcpy-win64-v5.0.1.zip'
            Sha256 = 'b12a2c4ee8be317422451fc7dcf8ee20a71b5ea7ef9ad73ddd825a25316227a5'
        }
    }

    $release = $releases[$Architecture]
    if (-not $release) {
        throw "No official scrcpy build is available for $Architecture."
    }

    $destRoot = Join-Path $env:LOCALAPPDATA 'Scrcpy'
    $exe = Join-Path (Join-Path $destRoot $release.Name) 'scrcpy.exe'
    if ((Test-Path -LiteralPath $exe) -and ((Get-PeMachine -Path $exe) -eq $Architecture)) {
        return $exe
    }

    Write-Host "Downloading $($release.Name) ..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $zip = Join-Path $env:TEMP "$($release.Name).zip"
    Invoke-WebRequest -Uri $release.Url -OutFile $zip -UseBasicParsing
    $hash = (Get-FileHash -Algorithm SHA256 -Path $zip).Hash
    if ($hash.ToLowerInvariant() -ne $release.Sha256) {
        Remove-Item -LiteralPath $zip -Force
        throw 'The downloaded scrcpy archive did not match its checksum.'
    }

    New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $destRoot -Force
    Remove-Item -LiteralPath $zip -Force

    if (-not (Test-Path -LiteralPath $exe)) {
        throw "scrcpy.exe was not found at $exe after extracting the archive."
    }

    return $exe
}

function Use-ScrcpyInstall {
    param([Parameter(Mandatory)][string]$ScrcpyExe)

    $directory = Split-Path -Parent $ScrcpyExe
    $adb = Join-Path $directory 'adb.exe'
    if (-not (Test-Path -LiteralPath $adb)) {
        throw "adb.exe is missing beside $ScrcpyExe."
    }

    $script:ScrcpyPath = $ScrcpyExe
    $script:AdbPath = $adb
    $env:ADB = $adb
    if (-not $env:Path.StartsWith("$directory;", [System.StringComparison]::OrdinalIgnoreCase)) {
        $env:Path = "$directory;$env:Path"
    }
}

function Ensure-ScrcpyTools {
    $architecture = Get-NativeCpuArchitecture
    Write-Host "CPU architecture: $architecture"

    $scrcpy = Find-ScrcpyExecutable -Architecture $architecture
    if (-not $scrcpy) {
        Install-ScrcpyWithWinget -Architecture $architecture
        $scrcpy = Find-ScrcpyExecutable -Architecture $architecture
    }
    if (-not $scrcpy) {
        $scrcpy = Install-ScrcpyFromRelease -Architecture $architecture
    }

    Use-ScrcpyInstall -ScrcpyExe $scrcpy
    Write-Host "Using $script:ScrcpyPath"
    Write-Host "Using $script:AdbPath"
}

function Get-AdbPath {
    if ($script:AdbPath -and (Test-Path -LiteralPath $script:AdbPath)) {
        return $script:AdbPath
    }
    if ($env:ADB -and (Test-Path -LiteralPath $env:ADB)) {
        return $env:ADB
    }

    $command = Get-Command -Name 'adb' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw 'adb was not found. Run Start-Scrcpy.ps1 once so the matching scrcpy build can be installed.'
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
    $adb = Get-AdbPath
    $running = @(Get-CimInstance Win32_Process -Filter "Name = 'adb.exe'" -ErrorAction SilentlyContinue)
    $foreign = @($running | Where-Object { $_.ExecutablePath -and ($_.ExecutablePath -ne $adb) })
    if ($foreign.Count -gt 0) {
        Write-Host 'Closing a different adb server so the native one can start...'
        Stop-AdbProcesses
        Start-Sleep -Seconds 1
    }

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
    $adb = Get-AdbPath
    Write-Host "Connecting to $Device ..."
    $connectOutput = & $adb connect $Device 2>&1 | Out-String
    Write-Host $connectOutput.Trim()

    if ($connectOutput -match 'failed to connect|cannot connect|unable to connect') {
        throw "Could not connect to $Device. On the phone, turn on Wireless debugging and confirm this IP and port."
    }

    $listing = & $adb devices 2>&1 | Out-String
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
