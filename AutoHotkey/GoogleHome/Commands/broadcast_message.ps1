param(
    [Parameter(Mandatory=$true)]
    [string]$message
)

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

Write-Host "=== Debug Info ==="
Write-Host "URL: $url"
Write-Host "Command: $broadcastCommand"
Write-Host "Headers:" ($headers | ConvertTo-Json)
Write-Host "Body:" $body
Write-Host ""

try {
    Write-Host "Attempting to send broadcast..."
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -Verbose
    Write-Host "Broadcast sent successfully!"
    Write-Host "Message: $message"
    Write-Host "Response:"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error broadcasting message:"
    Write-Host "Exception Type: " $_.Exception.GetType().FullName
    Write-Host "Message: " $_.Exception.Message
    Write-Host "Response Status Code: " $_.Exception.Response.StatusCode
    Write-Host "Response Status Description: " $_.Exception.Response.StatusDescription
}

Write-Host "`nPress Enter to exit..."
$null = Read-Host
