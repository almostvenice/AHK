#Requires AutoHotkey v2.0

; Check if Chrome is the active window
chromeWasActive := WinActive("ahk_exe chrome.exe")

; Close Grid 3
ProcessClose("Grid 3.exe")

; Wait for Grid 3 to close
Sleep(2000)

; Start Grid 3
Run("C:\Program Files (x86)\Smartbox\Grid 3\Grid 3.exe")

; Wait for Grid 3 to start
Sleep(10000)

; If Chrome was active, minimize and maximize it
if (chromeWasActive) {
    if WinExist("ahk_exe chrome.exe") {
        WinMinimize
        Sleep(500)
        WinMaximize
    }
}