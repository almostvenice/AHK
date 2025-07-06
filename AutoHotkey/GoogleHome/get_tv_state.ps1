$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$baseUrl = "http://192.168.4.219:8123/api"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Try both remote and media_player entities
$entities = @(
    "remote.sony_xbr_65a8h",
    "media_player.sony_xbr_65a8h"
)

foreach ($entity_id in $entities) {
    try {
        Write-Host "`nChecking entity: $entity_id"
        Write-Host "=========================="
        
        $response = Invoke-RestMethod -Uri "$baseUrl/states/$entity_id" -Method Get -Headers $headers
        Write-Host "State: $($response.state)"
        Write-Host "`nAttributes:"
        $response.attributes | ConvertTo-Json -Depth 10
        
    } catch {
        Write-Host "Error getting state for $entity_id"
        Write-Host $_.Exception.Message
    }
}

# Also check for any Sony-related entities
try {
    Write-Host "`nChecking for all Sony-related entities:"
    Write-Host "================================="
    
    $response = Invoke-RestMethod -Uri "$baseUrl/states" -Method Get -Headers $headers
    $sonyEntities = $response | Where-Object { 
        $_.entity_id -like "*sony*" -or 
        ($_.attributes.PSObject.Properties.Name -contains "friendly_name" -and
         $_.attributes.friendly_name -like "*sony*")
    }
    
    foreach ($entity in $sonyEntities) {
        Write-Host "`nEntity ID: $($entity.entity_id)"
        Write-Host "Friendly Name: $($entity.attributes.friendly_name)"
        Write-Host "State: $($entity.state)"
        Write-Host "Domain: $($entity.entity_id.Split('.')[0])"
        if ($entity.attributes.supported_features) {
            Write-Host "Supported Features: $($entity.attributes.supported_features)"
        }
        Write-Host "-----------------"
    }
    
} catch {
    Write-Host "Error getting Sony entities:"
    Write-Host $_.Exception.Message
}
