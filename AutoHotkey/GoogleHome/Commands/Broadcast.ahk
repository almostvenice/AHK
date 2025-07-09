#Requires AutoHotkey v2.0
; This script broadcasts clipboard content to all Google Home devices

; Create a log file in the script directory
logFile := A_ScriptDir "\broadcast.log"
FileAppend "=== New Broadcast Attempt ===`nTime: " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "`n", logFile

; Log system info
FileAppend "AHK Version: " A_AhkVersion "`nScript Path: " A_ScriptFullPath "`n", logFile

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Get clipboard content
message := A_Clipboard
FileAppend "Clipboard Content: " message "`n", logFile

; Run the PowerShell script with the clipboard content
try {
    psCommand := "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File `"" A_ScriptDir "\broadcast_message.ps1`" -message `"" message "`""
    FileAppend "Running Command: " psCommand "`n", logFile
    
    RunWait psCommand
    FileAppend "PowerShell script completed successfully`n", logFile
} catch Error as e {
    errorMsg := "Error running broadcast script: " e.Message
    FileAppend "Error: " errorMsg "`n", logFile
    MsgBox errorMsg
    ExitApp
}

FileAppend "=== Broadcast Attempt Complete ===`n`n", logFile
ExitApp
