#Requires AutoHotkey v2.0

ccPath := "C:\Program Files (x86)\Tobii Dynavox\Computer Control\Tdx.ComputerControl.exe"

if !ProcessExist("Tdx.ComputerControl.exe") {
    if FileExist(ccPath)
        Run(ccPath)
}
