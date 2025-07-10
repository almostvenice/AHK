$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$url = "http://192.168.4.219:8123/api/webhook/triple_press_fireplace_decrease"
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers
    Write-Host "Fireplace decrease command sent successfully!"
    Write-Host "Response:"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error sending command:"
    Write-Host $_.Exception.Message
}
