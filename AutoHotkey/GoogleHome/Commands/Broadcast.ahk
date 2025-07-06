#Requires AutoHotkey v2.0
; This script broadcasts clipboard content to all Google Home devices

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Get clipboard content
message := A_Clipboard

; Run the PowerShell script with the clipboard content
RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"C:\Users\pyjoh\Documents\Espanso-AHK\AutoHotkey\GoogleHome\Commands\broadcast_message.ps1`" -message `"" message "`""

ExitApp
