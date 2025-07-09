Write-Host "=== System Information ==="
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion
Write-Host "Execution Policy:" (Get-ExecutionPolicy)
Write-Host "`n=== Testing Home Assistant Connection ==="
$url = "http://192.168.4.219:8123/api/services/google_assistant_sdk/send_text_command"
try {
    $testConnection = Test-NetConnection -ComputerName "192.168.4.219" -Port 8123
    Write-Host "Can connect to Home Assistant:" $testConnection.TcpTestSucceeded
} catch {
    Write-Host "Connection test error:" $_.Exception.Message
}

Write-Host "`nPress Enter to exit..."
$null = Read-Host
