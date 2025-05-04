#Requires AutoHotkey v2.0

; Close all Explorer windows
while WinExist("ahk_class CabinetWClass") {
    WinClose("ahk_class CabinetWClass")
}

; Wait a moment for windows to close
Sleep(1000)

; Open new Explorer window using Windows+E
Send("#e")
