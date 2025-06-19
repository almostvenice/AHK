#Requires AutoHotkey v2.0
#SingleInstance Force

; Get the directory of this script
scriptDir := RegExReplace(A_ScriptDir, "\\*$")

; Path to AutoHotkey v2 executable
ahkPath := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

; Path to the main script
mainScript := scriptDir "\SpecificDoc.ahk"

; Check if AHK v2 exists
if !FileExist(ahkPath) {
    MsgBox("AutoHotkey v2 not found at: " ahkPath "`nPlease install AutoHotkey v2", "Error", 16)
    ExitApp
}

; Check if main script exists
if !FileExist(mainScript) {
    MsgBox("Main script not found at: " mainScript, "Error", 16)
    ExitApp
}

; Run the main script with AHK v2
Try {
    ; Use PowerShell to run the script and hide the window
    Run(Format('powershell.exe -WindowStyle Hidden -Command "& \"{1}\" \"{2}\""', ahkPath, mainScript),, "Hide")
} Catch as err {
    MsgBox("Failed to launch script: " err.Message, "Error", 16)
    ExitApp
}
