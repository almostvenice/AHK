#Requires AutoHotkey v2.0
#SingleInstance Force

; Select previous paragraph, copy it, and run textToElevenlabsEnhanced

; Select previous paragraph using Ctrl+Shift+Up
Send "{Ctrl down}{Shift down}{Up}{Shift up}{Ctrl up}"

; Wait 100ms
Sleep 100

; Copy selection
Send "^c"

; Run the text-to-speech script
Run A_ScriptDir "\textToElevenlabsEnhanced.ahk"

ExitApp
