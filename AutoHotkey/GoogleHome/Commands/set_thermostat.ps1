param(
    [Parameter(Mandatory = $true)]
    [string]$location,

    [Parameter(Mandatory = $true)]
    [ValidateSet("heat", "cool")]
    [string]$hvacMode,

    [Parameter(Mandatory = $true)]
    [int]$temperature
)

$configPath = Join-Path $PSScriptRoot "..\config.json" | Resolve-Path
$config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $config.thermostat_entities) {
    Write-Host "config.json is missing `"thermostat_entities`". See list_climate_entities.ps1 in GoogleHome folder."
    exit 1
}

$map = $config.thermostat_entities
$entity_id = $map.PSObject.Properties[$location].Value
if ([string]::IsNullOrWhiteSpace($entity_id)) {
    Write-Host "No entity_id for location `"$location`". Edit thermostat_entities in config.json"
    exit 1
}

$hassUrl = $config.hass_url.TrimEnd("/")
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxZTc4MDNkMzdhM2E0MjA0OTZmNzI3NzhkYjhhMDUyMSIsImlhdCI6MTc1MTc1Mzk3NiwiZXhwIjoyMDY3MTEzOTc2fQ.4QgMaT2KzeOUwK0TFS8e7CEr72Sv6BWQ-c5gAF4ECTk"
$baseUrl = "$hassUrl/api"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

try {
    $bodyMode = @{
        entity_id = $entity_id
        hvac_mode = $hvacMode
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$baseUrl/services/climate/set_hvac_mode" -Method Post -Headers $headers -Body $bodyMode

    $bodyTemp = @{
        entity_id   = $entity_id
        temperature = $temperature
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$baseUrl/services/climate/set_temperature" -Method Post -Headers $headers -Body $bodyTemp

    Write-Host "Thermostat set: $location ($entity_id) -> $hvacMode $temperature"
} catch {
    Write-Host "Error setting thermostat:"
    Write-Host $_.Exception.Message
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message
    }
    exit 1
}
