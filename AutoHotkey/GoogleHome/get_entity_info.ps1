param(
    [Parameter(Mandatory=$true)]
    [string]$entity_id
)

$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$url = "http://192.168.4.219:8123/api/states/$entity_id"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    Write-Host "Entity Information:"
    Write-Host "==================="
    Write-Host "State: $($response.state)"
    Write-Host "`nAttributes:"
    $response.attributes | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error getting entity information:"
    Write-Host $_.Exception.Message
}
