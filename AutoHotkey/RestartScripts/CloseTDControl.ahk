#Requires AutoHotkey v2.0

tdExe := "Tobii.Service.exe"

; Kill all instances just in case
while ProcessExist(tdExe) {
    ProcessClose(tdExe)
    Sleep(1000)
}
