#Requires AutoHotkey v2.0
#SingleInstance Force

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Get clipboard content
command := A_Clipboard

; Base URL for all webhooks
baseUrl := "http://192.168.4.219:8123/api/webhook/"

; Handle all commands using switch statement
switch command {
    ; Front Door Lock
    case "Turn Front Door Lock ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'lock_front_door"'
    case "Turn Front Door Lock OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'unlock_front_door"'
    
    ; Garage Door
    case "Turn Garage Door ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'lock_garage_door"'
    case "Turn Garage Door OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'unlock_garage_door"'
    
    ; Back Door Lock
    case "Turn Back Door Lock ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'lock_back_door"'
    case "Turn Back Door Lock OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'unlock_back_door"'
    
    ; Fireplace
    case "Turn Fireplace ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'triple_press_fireplace_increase"'
    case "Turn Fireplace OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'triple_press_fireplace_decrease"'
    
    ; For any other commands, use the regular send_text_command script
    default:
        RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\send_text_command.ps1`" -command `"" command "`""
}

ExitApp