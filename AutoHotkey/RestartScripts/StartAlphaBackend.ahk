#Requires AutoHotkey v2.0

appExe := "Alpha-Backend.exe"
appPath := "C:\Users\pyjoh\AppData\Local\Programs\Alpha-Backend\Alpha-Backend.exe"

if !ProcessExist(appExe) {
    if FileExist(appPath)
        Run(appPath)
}
