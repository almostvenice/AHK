#Requires AutoHotkey v2.0

; if !A_IsAdmin {
;     try Run('*RunAs "' A_ScriptFullPath '"')
;     ExitApp
; }

tdExe := "Tobii.Service.exe"

; Kill all instances just in case
while ProcessExist(tdExe) {
    ProcessClose(tdExe)
    Sleep(1000)
}

Sleep(3000)
Run(tdExe)
