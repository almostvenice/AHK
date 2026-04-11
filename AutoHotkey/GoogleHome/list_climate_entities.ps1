# Lists climate.* entities from Home Assistant (for thermostat_entities in config.json).
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$configPath = Join-Path $PSScriptRoot "config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "Missing config.json at $configPath"
    exit 1
}
$hassUrl = ((Get-Content $configPath -Raw | ConvertFrom-Json).hass_url).TrimEnd("/")
$headers = @{ "Authorization" = "Bearer $token" }

try {
    $states = Invoke-RestMethod -Uri "$hassUrl/api/states" -Method Get -Headers $headers
    Write-Host "Climate entities (copy entity_id into config.json -> thermostat_entities):`n"
    $climate = $states | Where-Object { $_.entity_id -like "climate.*" } | Sort-Object entity_id
    if (-not $climate) {
        Write-Host "(none found - check token, URL, or integrations)"
        exit 0
    }
    foreach ($s in $climate) {
        $name = $s.attributes.friendly_name
        if ($name) {
            Write-Host "$($s.entity_id)  |  $name"
        } else {
            Write-Host "$($s.entity_id)"
        }
    }
} catch {
    Write-Host "Error:"
    Write-Host $_.Exception.Message
    exit 1
}
