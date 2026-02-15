#Requires AutoHotkey v2.0

tdExe := "Tdx.ComputerControl.exe"

while ProcessExist(tdExe) {
    ProcessClose(tdExe)
    Sleep(1000)
}
