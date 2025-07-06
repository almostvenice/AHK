$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$baseUrl = "http://192.168.4.219:8123/api"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    # Get all devices
    $response = Invoke-RestMethod -Uri "$baseUrl/devices" -Method Get -Headers $headers
    Write-Host "Looking for TV device info..."
    Write-Host "============================="
    
    # Find Sony TV related devices
    $tvDevices = $response | Where-Object { 
        $_.name -like "*Sony*" -or 
        $_.model -like "*Sony*" -or 
        $_.manufacturer -like "*Sony*" -or
        $_.name -like "*TV*"
    }
    
    if ($tvDevices) {
        $tvDevices | ForEach-Object {
            Write-Host "`nDevice Found:"
            Write-Host "Name: $($_.name)"
            Write-Host "Model: $($_.model)"
            Write-Host "Manufacturer: $($_.manufacturer)"
            Write-Host "Integration: $($_.integration)"
            Write-Host "`nEntities:"
            $_.entities | ForEach-Object {
                Write-Host "- $($_.entity_id): $($_.name)"
            }
            Write-Host "------------------------"
        }
    } else {
        Write-Host "No Sony TV or TV-related devices found."
    }

} catch {
    Write-Host "Error getting device information:"
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.Response.StatusCode.Value__
    Write-Host $_.ErrorDetails.Message
}
