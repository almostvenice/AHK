#Requires AutoHotkey v2.0

script := A_ScriptDir "\Start-Scrcpy.ps1"
Run('PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "' script '"')
