#Requires AutoHotkey v2.0

appExe := "Alpha-Backend.exe"
appPath := "C:\Users\pyjoh\AppData\Local\Programs\Alpha-Backend\Alpha-Backend.exe"

while ProcessExist(appExe) {
    ProcessClose(appExe)
    Sleep(1000)
}

Sleep(2000)

if FileExist(appPath) {
    Run(appPath)
}
