#Requires AutoHotkey v2.0
#SingleInstance Force

; Get paths
scriptPath := A_ScriptDir "\SpecificDoc.ahk"
ahkPath := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

; Check paths
if !FileExist(ahkPath) {
    MsgBox("AutoHotkey v2 not found at: " ahkPath, "Error", 16)
    ExitApp
}

if !FileExist(scriptPath) {
    MsgBox("Script not found at: " scriptPath, "Error", 16)
    ExitApp
}

; Run script with AHK v2
RunWait(Format('powershell -WindowStyle Hidden -Command "Start-Process -WindowStyle Hidden -FilePath `"{1}`" -ArgumentList `"{2}`""', ahkPath, scriptPath), , "Hide")
