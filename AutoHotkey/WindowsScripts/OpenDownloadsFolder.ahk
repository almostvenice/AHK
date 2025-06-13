#Requires AutoHotkey v2.0

if !A_IsAdmin {
    try Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

; Opens the Downloads folder
Run "C:\Users\pyjoh\Downloads"
