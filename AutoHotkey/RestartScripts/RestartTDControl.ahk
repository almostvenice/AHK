#Requires AutoHotkey v2.0

tdExe := "Tdx.ComputerControl.exe"
ccPath := "C:\Program Files (x86)\Tobii Dynavox\Computer Control\Tdx.ComputerControl.exe"

; Close the process if it's running
while ProcessExist(tdExe) {
    ProcessClose(tdExe)
    Sleep(1000)
}

; Wait a moment for cleanup
Sleep(2000)

; Start it back up
if FileExist(ccPath) {
    Run(ccPath)
}
