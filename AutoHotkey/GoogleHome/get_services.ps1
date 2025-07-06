$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$baseUrl = "http://192.168.4.219:8123/api/services"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Get -Headers $headers
    Write-Host "Available Services:"
    Write-Host "=================="
    
    # Filter for TV-related services
    $tvServices = $response | Where-Object { 
        $_.domain -like "*remote*" -or 
        $_.domain -like "*media_player*" -or 
        $_.domain -like "*androidtv*" -or
        $_.domain -like "*sony*" -or
        $_.domain -like "*bravia*"
    }
    
    $tvServices | ForEach-Object {
        Write-Host "`nDomain: $($_.domain)"
        Write-Host "Services:"
        $_.services | Get-Member -MemberType NoteProperty | ForEach-Object {
            Write-Host "- $($_.Name)"
            $serviceDetails = $tvServices.services."$($_.Name)"
            if ($serviceDetails.fields) {
                Write-Host "  Fields:"
                $serviceDetails.fields.PSObject.Properties | ForEach-Object {
                    Write-Host "    $($_.Name): $($_.Value.description)"
                }
            }
        }
        Write-Host "------------------------"
    }

} catch {
    Write-Host "Error getting services:"
    Write-Host $_.Exception.Message
    Write-Host $_.Exception.Response.StatusCode.Value__
    Write-Host $_.ErrorDetails.Message
}
