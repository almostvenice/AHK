#Requires AutoHotkey v2.0

tdExe := "Tobii.Service.exe"

if !ProcessExist(tdExe) {
    Run(tdExe)
}
