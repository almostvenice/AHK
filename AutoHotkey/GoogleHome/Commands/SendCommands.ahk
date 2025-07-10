#Requires AutoHotkey v2.0
; This script sends clipboard content as a command to Google Assistant
; if !A_IsAdmin {
;     try Run '*RunAs "' A_ScriptFullPath '"'
;     ExitApp
; }
; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Get clipboard content
command := A_Clipboard

; Handle special fireplace commands
if (command = "Turn Fireplace ON") {
    RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\triple_press_fireplace_increase.ps1"'
} else if (command = "Turn Fireplace OFF") {
    RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\..\WebHooks\triple_press_fireplace_decrease.ps1"'
} else {
    ; For all other commands, use the regular send_text_command script
    RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\send_text_command.ps1`" -command `"" command "`""
}

ExitApp
