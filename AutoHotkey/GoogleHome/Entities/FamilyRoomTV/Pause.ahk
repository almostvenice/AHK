#Requires AutoHotkey v2.0
; This script sends the Pause command to the Family Room TV

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Run the PowerShell command
RunWait "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command `"& 'C:\Users\pyjoh\Documents\Espanso-AHK\AutoHotkey\GoogleHome\send_command.ps1' -entity_id 'remote.sony_xbr_65a8h' -command 'Pause'`""

ExitApp
