#Requires AutoHotkey v2.0

; Select next paragraph using Ctrl+Shift+Down
Send "{Ctrl down}{Shift down}{Down}{Shift up}{Ctrl up}"

; Wait 100ms
Sleep 100

; Copy selection
Send "^c"

; Run the text-to-speech script
Run A_ScriptDir "\textToElevenlabsEnhanced.ahk"

ExitApp
