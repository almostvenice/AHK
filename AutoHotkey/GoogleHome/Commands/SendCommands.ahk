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

; Run the PowerShell script with the clipboard content
RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"C:\Users\pyjoh\Documents\Espanso-AHK\AutoHotkey\GoogleHome\Commands\send_text_command.ps1`" -command `"" command "`""

ExitApp
