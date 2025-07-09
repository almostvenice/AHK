# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch the script with admin privileges
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -command `"$command`"" -Verb RunAs
    exit
}

param(
    [Parameter(Mandatory=$true)]
    [string]$command
)

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$url = "http://192.168.4.219:8123/api/services/google_assistant_sdk/send_text_command"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    command = $command
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
    Write-Host "Command sent successfully!"
    Write-Host "Command: $command"
    Write-Host "Response:"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error sending command:"
    Write-Host $_.Exception.Message
}
