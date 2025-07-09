#Requires AutoHotkey v2.0
; This script broadcasts clipboard content to all Google Home devices
; if !A_IsAdmin {
;     try Run '*RunAs "' A_ScriptFullPath '"'
;     ExitApp
; }
; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Get clipboard content
message := A_Clipboard

; Run the PowerShell script with the clipboard content
try {
    RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\broadcast_message.ps1`" -message `"" message "`""
} catch Error as e {
    MsgBox "Error running broadcast script: " e.Message
    ExitApp
}

ExitApp
