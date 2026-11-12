#Requires AutoHotkey v2.0

script := A_ScriptDir "\Close-Scrcpy.ps1"
Run('PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "' script '"')
