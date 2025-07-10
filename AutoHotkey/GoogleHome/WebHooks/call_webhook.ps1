param(
    [Parameter(Mandatory=$true)]
    [string]$webhookUrl
)

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Headers $headers
    Write-Host "Webhook called successfully: $webhookUrl"
} catch {
    Write-Host "Error calling webhook:"
    Write-Host $_.Exception.Message
}
