#Requires AutoHotkey v2.0

script := A_ScriptDir "\Connect-Scrcpy.ps1"
Run('PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "' script '"')
