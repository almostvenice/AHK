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
        WriteLog("Fireplace ON - Starting loop #1 (6 iterations)")
        for i in [1, 2, 3, 4, 5, 6] {
            WriteLog("Fireplace ON - Loop #1 - Iteration " i " of 6 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'fireplace_increase"'
            WriteLog("Fireplace ON - Loop #1 - Iteration " i " of 6 - Command completed")
            if (i < 6) {
                WriteLog("Fireplace ON - Loop #1 - Waiting 850ms before next iteration")
                Sleep 850
            }
        }

        WriteLog("Fireplace ON - Loop #1 completed - Waiting 8000ms before loop #2")
        Sleep 8000

        WriteLog("Fireplace ON - Starting loop #2 (6 iterations)")
        for i in [1, 2, 3, 4, 5, 6] {
            WriteLog("Fireplace ON - Loop #2 - Iteration " i " of 6 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'fireplace_increase"'
            WriteLog("Fireplace ON - Loop #2 - Iteration " i " of 6 - Command completed")
            if (i < 6) {
                WriteLog("Fireplace ON - Loop #2 - Waiting 850ms before next iteration")
                Sleep 850
            }
        }
        WriteLog("Fireplace ON - Loop #2 completed (all done)")

    case "Hey Google, Turn Fireplace OFF":
        WriteLog("Fireplace OFF - Starting loop #1 (8 iterations)")
        for i in [1, 2, 3, 4, 5, 6, 7, 8] {
            WriteLog("Fireplace OFF - Loop #1 - Iteration " i " of 8 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'fireplace_decrease"'
            WriteLog("Fireplace OFF - Loop #1 - Iteration " i " of 8 - Command completed")
            if (i < 8) {
                WriteLog("Fireplace OFF - Loop #1 - Waiting 850ms before next iteration")
                Sleep 850
            }
        }

        WriteLog("Fireplace OFF - Loop #1 completed - Waiting 8000ms before loop #2")
        Sleep 8000

        WriteLog("Fireplace OFF - Starting loop #2 (8 iterations)")
        for i in [1, 2, 3, 4, 5, 6, 7, 8] {
            WriteLog("Fireplace OFF - Loop #2 - Iteration " i " of 8 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'fireplace_decrease"'
            WriteLog("Fireplace OFF - Loop #2 - Iteration " i " of 8 - Command completed")
            if (i < 8) {
                WriteLog("Fireplace OFF - Loop #2 - Waiting 850ms before next iteration")
                Sleep 850
            }
        }
        WriteLog("Fireplace OFF - Loop #2 completed (all done)")


    ; ================= FIREPLACE MANUAL ADJUST =================

    ; -------- TURN FIREPLACE UP (2 presses) --------
    case "Hey Google, Turn Fireplace UP":
        WriteLog("Fireplace UP - Starting loop (2 iterations)")
        for i in [1, 2] {
            WriteLog("Fireplace UP - Iteration " i " of 2 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'fireplace_increase"'
            WriteLog("Fireplace UP - Iteration " i " of 2 - Command completed")
            if (i < 2) {
                WriteLog("Fireplace UP - Waiting 850ms before next iteration")
                Sleep 850
            }
        }
        WriteLog("Fireplace UP - Loop completed (all 2 iterations)")


    ; -------- TURN FIREPLACE DOWN (2 presses) --------
    case "Hey Google, Turn Fireplace DOWN":
        WriteLog("Fireplace DOWN - Starting loop (2 iterations)")
        for i in [1, 2] {
            WriteLog("Fireplace DOWN - Iteration " i " of 2 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'fireplace_decrease"'
            WriteLog("Fireplace DOWN - Iteration " i " of 2 - Command completed")
            if (i < 2) {
                WriteLog("Fireplace DOWN - Waiting 850ms before next iteration")
                Sleep 850
            }
        }
        WriteLog("Fireplace DOWN - Loop completed (all 2 iterations)")


    ; For any other commands, use the regular send_text_command script
    default:
        WriteLog("Default case - Using send_text_command.ps1")
        RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\send_text_command.ps1`" -command `"" command "`""
}

WriteLog("Script ending")
ExitApp