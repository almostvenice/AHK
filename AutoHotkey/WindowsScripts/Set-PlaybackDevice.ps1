param(
    [ValidateSet('ON', 'OFF', 'TEST')]
    [string]$Action = 'TEST',
    [switch]$DryRun,
    [string]$LogFile
)

if ($Action -eq 'TEST') {
    $DryRun = $true
}

function Write-Log([string]$Message) {
    $line = '{0} - {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    if ($LogFile) {
        Add-Content -LiteralPath $LogFile -Value $line
    }
}

$audioHelper = @'
using System;
using System.Runtime.InteropServices;

[ComImport]
[Guid("F8679F50-850A-41CF-9C72-430F290290C8")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IPolicyConfigWin7 {
    [PreserveSig] int Unused1();
    [PreserveSig] int Unused2();
    [PreserveSig] int Unused3();
    [PreserveSig] int Unused4();
    [PreserveSig] int Unused5();
    [PreserveSig] int Unused6();
    [PreserveSig] int Unused7();
    [PreserveSig] int Unused8();
    [PreserveSig] int Unused9();
    [PreserveSig] int Unused10();
    [PreserveSig] int SetDefaultEndpoint([MarshalAs(UnmanagedType.LPWStr)] string wszDeviceId, int role);
    [PreserveSig] int Unused12();
}

[ComImport]
[Guid("568B9108-44BF-40B4-9006-86AFE5B5A620")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IPolicyConfigVista {
    [PreserveSig] int Unused1();
    [PreserveSig] int Unused2();
    [PreserveSig] int Unused3();
    [PreserveSig] int Unused4();
    [PreserveSig] int Unused5();
    [PreserveSig] int Unused6();
    [PreserveSig] int Unused7();
    [PreserveSig] int Unused8();
    [PreserveSig] int Unused9();
    [PreserveSig] int Unused10();
    [PreserveSig] int SetDefaultEndpoint([MarshalAs(UnmanagedType.LPWStr)] string wszDeviceId, int role);
    [PreserveSig] int Unused12();
}

public static class PlaybackPolicy {
    public static string SetDefault(string deviceId) {
        Guid clsidWin7 = new Guid("870AF99C-171D-4F9E-AF0D-E63DF40C2BC9");
        Guid clsidVista = new Guid("294935CE-F637-4E7C-A41B-AB255460B695");
        object obj = null;
        Type t = Type.GetTypeFromCLSID(clsidWin7, true);
        try {
            obj = Activator.CreateInstance(t);
            IPolicyConfigWin7 cfg = (IPolicyConfigWin7)obj;
            int hr = cfg.SetDefaultEndpoint(deviceId, 0);
            if (hr < 0) Marshal.ThrowExceptionForHR(hr);
            hr = cfg.SetDefaultEndpoint(deviceId, 1);
            if (hr < 0) Marshal.ThrowExceptionForHR(hr);
            hr = cfg.SetDefaultEndpoint(deviceId, 2);
            if (hr < 0) Marshal.ThrowExceptionForHR(hr);
            return "IPolicyConfigWin7";
        } catch (InvalidCastException) {
            obj = Activator.CreateInstance(Type.GetTypeFromCLSID(clsidVista, true));
            IPolicyConfigVista cfg = (IPolicyConfigVista)obj;
            int hr = cfg.SetDefaultEndpoint(deviceId, 0);
            if (hr < 0) Marshal.ThrowExceptionForHR(hr);
            hr = cfg.SetDefaultEndpoint(deviceId, 1);
            if (hr < 0) Marshal.ThrowExceptionForHR(hr);
            hr = cfg.SetDefaultEndpoint(deviceId, 2);
            if (hr < 0) Marshal.ThrowExceptionForHR(hr);
            return "IPolicyConfigVista";
        }
    }
}
'@

if (-not $DryRun) {
    Add-Type -Language CSharp -TypeDefinition $audioHelper -ErrorAction Stop
}

function Get-RenderPlaybackDevices {
    $root = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
    $devices = @()
    if (-not (Test-Path $root)) {
        return $devices
    }
    Get-ChildItem $root | ForEach-Object {
        $guid = $_.PSChildName
        $props = Join-Path $_.PSPath 'Properties'
        $state = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).DeviceState
        $name = $null
        if (Test-Path $props) {
            $p = Get-ItemProperty $props -ErrorAction SilentlyContinue
            $name = $p.'{b3f8fa53-0004-438e-9003-51a46e139bfc},6'
            if (-not $name) {
                $name = $p.'{a45c254e-df1c-4efd-8020-67d146a850e0},2'
            }
        }
        $id = '{0.0.0.00000000}.' + $guid
        [pscustomobject]@{
            Name  = $name
            Id    = $id
            State = $state
        }
    }
}

function Find-PlaybackMatch([string]$Match) {
    $devs = Get-RenderPlaybackDevices | Where-Object { $_.Name -and ($_.Name -match $Match) }
    if (-not $devs) {
        return $null
    }
    $hit = $devs | Where-Object { $_.State -eq 1 } | Select-Object -First 1
    if (-not $hit) {
        $hit = $devs | Where-Object { $_.State -eq 8 } | Select-Object -First 1
    }
    if (-not $hit) {
        $hit = $devs | Select-Object -First 1
    }
    return $hit
}

function Set-DefaultByNameMatch([string]$Match) {
    $hit = Find-PlaybackMatch -Match $Match
    if (-not $hit) {
        return $null
    }
    if ($DryRun) {
        Write-Log ("DRY RUN would set default to {0} ({1}) state={2}" -f $hit.Name, $hit.Id, $hit.State)
        return $hit.Name
    }
    $iface = [PlaybackPolicy]::SetDefault($hit.Id)
    Write-Log ("SetDefault via {0}: {1} ({2}) state={3}" -f $iface, $hit.Name, $hit.Id, $hit.State)
    return $hit.Name
}

function Connect-NamedBluetooth([string]$Match) {
    $devs = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object {
        $_.FriendlyName -and ($_.FriendlyName -match $Match)
    }
    foreach ($d in $devs) {
        Write-Log ("Bluetooth/PnP match: {0} [{1}] {2}" -f $d.FriendlyName, $d.Status, $d.InstanceId)
        if ($DryRun) {
            continue
        }
        if ($d.Status -ne 'OK') {
            try {
                Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false -ErrorAction Stop
                Write-Log ("Enabled device {0}" -f $d.FriendlyName)
            } catch {
                Write-Log ("Could not enable {0}: {1}" -f $d.FriendlyName, $_.Exception.Message)
            }
        }
    }
    return $devs
}

Write-Log ("Set-PlaybackDevice Action={0} DryRun={1} ptr={2}" -f $Action, $DryRun, [IntPtr]::Size)
$listed = @(Get-RenderPlaybackDevices)
if ($listed) {
    foreach ($d in $listed) {
        Write-Log ("Render: {0} | {1} | DeviceState={2}" -f $d.Name, $d.Id, $d.State)
    }
} else {
    Write-Log 'No MMDevices Render keys found.'
}

function Test-OnMatch {
    Connect-NamedBluetooth -Match 'Bose|Soundbar'
    if (-not $DryRun) {
        Start-Sleep -Seconds 2
    }
    $set = $null
    try { $set = Set-DefaultByNameMatch -Match 'Bose' } catch { Write-Log ("SetDefault Bose failed: {0}" -f $_.Exception.Message) }
    if (-not $set) {
        try { $set = Set-DefaultByNameMatch -Match 'Soundbar' } catch { Write-Log ("SetDefault Soundbar failed: {0}" -f $_.Exception.Message) }
    }
    if ($set) {
        Write-Log ("ON target: {0}" -f $set)
    } else {
        Write-Log 'ON: no Bose/Soundbar Windows playback device on this PC. Google Assistant can still turn the Bose on.'
    }
}

function Test-OffMatch {
    $set = $null
    try { $set = Set-DefaultByNameMatch -Match 'Realtek' } catch { Write-Log ("SetDefault Realtek failed: {0}" -f $_.Exception.Message) }
    if (-not $set) {
        try { $set = Set-DefaultByNameMatch -Match 'Speakers' } catch { Write-Log ("SetDefault Speakers failed: {0}" -f $_.Exception.Message) }
    }
    if ($set) {
        Write-Log ("OFF target: {0}" -f $set)
    } else {
        Write-Log 'OFF: no Realtek/Speakers playback device on this PC.'
    }
}

if ($Action -eq 'TEST') {
    Test-OnMatch
    Test-OffMatch
} elseif ($Action -eq 'ON') {
    Test-OnMatch
} else {
    Test-OffMatch
}
