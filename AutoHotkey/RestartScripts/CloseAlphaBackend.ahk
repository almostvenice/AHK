#Requires AutoHotkey v2.0

appExe := "Alpha-Backend.exe"

while ProcessExist(appExe) {
    ProcessClose(appExe)
    Sleep(1000)
}
