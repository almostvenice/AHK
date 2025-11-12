#Requires AutoHotkey v2.0
#SingleInstance Force

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Log file path
logFile := A_ScriptDir "\SendCommands.log"

; Function to write to log file
WriteLog(message) {
    global logFile
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend timestamp " - " message "`n", logFile
}

; Get clipboard content
command := A_Clipboard
WriteLog("Script started. Command: " command)

; Base URL for all webhooks
baseUrl := "http://192.168.4.219:8123/api/webhook/"

; Handle all commands using switch statement
switch command {
    ; Front Door Lock
    case "Hey Google, Turn Front Door Lock ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'lock_front_door"'
    case "Hey Google, Turn Front Door Lock OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'unlock_front_door"'
    
    ; Garage Door
    case "Hey Google, Turn Garage Door ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'lock_garage_door"'
    case "Hey Google, Turn Garage Door OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'unlock_garage_door"'
    
    ; Back Door Lock
    case "Hey Google, Turn Back Door Lock ON":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'lock_back_door"'
    case "Hey Google, Turn Back Door Lock OFF":
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'unlock_back_door"'
    
    ; Fireplace
    case "Hey Google, Turn Fireplace ON":
        WriteLog("Fireplace ON - Starting loop (4 iterations)")
        for i in [1, 2, 3, 4] {
            WriteLog("Fireplace ON - Iteration " i " of 4 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'triple_press_fireplace_increase"'
            WriteLog("Fireplace ON - Iteration " i " of 4 - Command completed")
            if (i < 4) {
                WriteLog("Fireplace ON - Waiting 300ms before next iteration")
                Sleep 300
            }
        }
        WriteLog("Fireplace ON - Loop completed (all 4 iterations)")
    case "Hey Google, Turn Fireplace OFF":
        WriteLog("Fireplace OFF - Starting loop (4 iterations)")
        for i in [1, 2, 3, 4] {
            WriteLog("Fireplace OFF - Iteration " i " of 4 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'triple_press_fireplace_decrease"'
            WriteLog("Fireplace OFF - Iteration " i " of 4 - Command completed")
            if (i < 4) {
                WriteLog("Fireplace OFF - Waiting 300ms before next iteration")
                Sleep 300
            }
        }
        WriteLog("Fireplace OFF - Loop completed (all 4 iterations)")
    
    ; For any other commands, use the regular send_text_command script
    default:
        WriteLog("Default case - Using send_text_command.ps1")
        RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\send_text_command.ps1`" -command `"" command "`""
}

WriteLog("Script ending")
ExitApp