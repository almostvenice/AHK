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

; Clipboard = full phrase (same idea as fireplace: GRID/Home feeds text, this script runs).
command := StrReplace(StrReplace(A_Clipboard, Chr(0x00A0), " "), "`r", "")
command := RTrim(Trim(command), " `t`r`n" Chr(34) "'")
while InStr(command, "  ")
    command := StrReplace(command, "  ", " ")
WriteLog("Script started. Command: " command)

; Thermostat: any whole-number temp; rooms Kitchen / Master Bedroom / Upstairs; Cool or Heat.
; Examples: "Hey Google, Turn Kitchen Thermostat To Cool To 72"
; Also allows Set, optional "the", optional "degrees", flexible spacing (GRID3-safe).
thermostatPat := "i)^Hey Google,\s*(?:Turn|Set)\s+(?:the\s+)?(Kitchen|Master Bedroom|Upstairs)\s+Thermostat\s+To\s+(Cool|Heat)\s+To\s+(\d+)(?:\s*degrees?)?\s*\.?\s*$"
if RegExMatch(command, thermostatPat, &tm) {
    loc := tm[1]
    mode := StrLower(tm[2])
    temp := tm[3]
    WriteLog("Thermostat - " loc " -> " mode " " temp " (set_thermostat.ps1)")
    ps1 := A_ScriptDir "\set_thermostat.ps1"
    exitCode := RunWait(Format('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{1}" -location "{2}" -hvacMode "{3}" -temperature {4}', ps1, loc, mode, temp))
    WriteLog("Thermostat script finished (exit " exitCode ")")
    WriteLog("Script ending")
    ExitApp
}

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


    ; ================================================================================
    ; HDMI_SWITCH — template (hardware arrives later)
    ; Same idea as Fireplace UP/DOWN: webhook(s) + Sleep between repeats.
    ;
    ; In Home Assistant, create Webhook automations whose IDs match the strings below
    ; (full URL = baseUrl .. slug, e.g. .../api/webhook/HDMI_Switch_Next).
    ;
    ; TEMPLATE / tune after install:
    ;   - If one IR/button press per action is enough: change loops from [1, 2] to [1].
    ;   - Tweak Sleep 850 if the switch misses commands.
    ;   - Delete or add "INPUT N" cases to match your port count.
    ; ================================================================================

    ; =================
    ; SWITCH NEXT
    ; =================
    ; Webhook slug: HDMI_Switch_Next
    case "Hey Google, Turn HDMI Switch NEXT":
        WriteLog("HDMI_Switch NEXT - Starting loop (2 iterations)")
        for i in [1, 2] {
            WriteLog("HDMI_Switch NEXT - Iteration " i " of 2 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'HDMI_Switch_Next"'
            WriteLog("HDMI_Switch NEXT - Iteration " i " of 2 - Command completed")
            if (i < 2) {
                WriteLog("HDMI_Switch NEXT - Waiting 850ms before next iteration")
                Sleep 850
            }
        }
        WriteLog("HDMI_Switch NEXT - Loop completed (all 2 iterations)")

    ; ----------------
    ; SWITCH BACK
    ; ----------------
    ; Webhook slug: HDMI_Switch_Back
    case "Hey Google, Turn HDMI Switch BACK":
        WriteLog("HDMI_Switch BACK - Starting loop (2 iterations)")
        for i in [1, 2] {
            WriteLog("HDMI_Switch BACK - Iteration " i " of 2 - Starting command")
            RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'HDMI_Switch_Back"'
            WriteLog("HDMI_Switch BACK - Iteration " i " of 2 - Command completed")
            if (i < 2) {
                WriteLog("HDMI_Switch BACK - Waiting 850ms before next iteration")
                Sleep 850
            }
        }
        WriteLog("HDMI_Switch BACK - Loop completed (all 2 iterations)")

    ; =================
    ; SWITCH INPUT 1
    ; =================
    ; Webhook slug: HDMI_Switch_Input_1
    case "Hey Google, Turn HDMI Switch To Input 1":
        WriteLog("HDMI_Switch - Input 1")
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'HDMI_Switch_Input_1"'

    ; =================
    ; SWITCH INPUT 2
    ; =================
    ; Webhook slug: HDMI_Switch_Input_2
    case "Hey Google, Turn HDMI Switch To Input 2":
        WriteLog("HDMI_Switch - Input 2")
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'HDMI_Switch_Input_2"'

    ; =================
    ; SWITCH INPUT 3
    ; =================
    ; Webhook slug: HDMI_Switch_Input_3
    case "Hey Google, Turn HDMI Switch To Input 3":
        WriteLog("HDMI_Switch - Input 3")
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'HDMI_Switch_Input_3"'

    ; =================
    ; SWITCH INPUT 4
    ; =================
    ; Webhook slug: HDMI_Switch_Input_4
    case "Hey Google, Turn HDMI Switch To Input 4":
        WriteLog("HDMI_Switch - Input 4")
        RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\call_webhook.ps1" -webhookUrl "' baseUrl 'HDMI_Switch_Input_4"'


    ; For any other commands, use the regular send_text_command script
    default:
        if InStr(StrLower(command), "thermostat")
            WriteLog("Default case - text mentions thermostat but did not match thermostat pattern; using send_text_command.ps1. Compare command line above.")
        WriteLog("Default case - Using send_text_command.ps1")
        RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\send_text_command.ps1`" -command `"" command "`""
}

WriteLog("Script ending")
ExitApp