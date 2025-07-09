param(
    [Parameter(Mandatory=$true)]
    [string]$message
)

# Setup logging
$logFile = Join-Path $PSScriptRoot "broadcast_ps.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content $logFile "`n=== PowerShell Broadcast Attempt ===`nTime: $timestamp"

# Log system info
$psVersion = $PSVersionTable.PSVersion
Add-Content $logFile "PowerShell Version: $psVersion"
Add-Content $logFile "Execution Policy: $(Get-ExecutionPolicy)"

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$url = "http://192.168.4.219:8123/api/services/google_assistant_sdk/send_text_command"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Format the message as a broadcast command
$broadcastCommand = "broadcast $message"

$body = @{
    command = $broadcastCommand
} | ConvertTo-Json

# Log request details
Add-Content $logFile "Message: $message"
Add-Content $logFile "URL: $url"
Add-Content $logFile "Command: $broadcastCommand"
Add-Content $logFile "Headers: $(ConvertTo-Json $headers)"
Add-Content $logFile "Body: $body"

# Test connection first
Add-Content $logFile "`nTesting connection..."
try {
    $testConnection = Test-NetConnection -ComputerName "192.168.4.219" -Port 8123
    Add-Content $logFile "Connection Test: $($testConnection.TcpTestSucceeded)"
} catch {
    Add-Content $logFile "Connection Test Error: $($_.Exception.Message)"
}

# Attempt the broadcast
Add-Content $logFile "`nAttempting broadcast..."
try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -Verbose
    Add-Content $logFile "Broadcast successful!"
    Add-Content $logFile "Response: $(ConvertTo-Json $response -Depth 10)"
    
    Write-Host "Broadcast sent successfully!"
    Write-Host "Message: $message"
    Write-Host "Response:"
    $response | ConvertTo-Json -Depth 10
} catch {
    $errorDetails = @{
        Type = $_.Exception.GetType().FullName
        Message = $_.Exception.Message
        StatusCode = $_.Exception.Response.StatusCode
        StatusDescription = $_.Exception.Response.StatusDescription
    }
    
    Add-Content $logFile "ERROR Details:"
    Add-Content $logFile (ConvertTo-Json $errorDetails -Depth 10)
    
    Write-Host "Error broadcasting message:"
    Write-Host "Exception Type: $($errorDetails.Type)"
    Write-Host "Message: $($errorDetails.Message)"
    Write-Host "Response Status Code: $($errorDetails.StatusCode)"
    Write-Host "Response Status Description: $($errorDetails.StatusDescription)"
}

Add-Content $logFile "=== Broadcast Attempt Complete ===`n"

Write-Host "`nCheck broadcast_ps.log for detailed logs"
Write-Host "Press Enter to exit..."
$null = Read-Host
