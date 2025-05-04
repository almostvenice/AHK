#Requires AutoHotkey v2.0

; Check if Chrome is running
if ProcessExist("chrome.exe") {
    ; Close Chrome
    ProcessClose("chrome.exe")
    ; Wait a moment for Chrome to fully close
    Sleep(2000)
}

; Start Chrome
Run("chrome.exe")

; Wait for Chrome to start and show the restore prompt
Sleep(2500)

; Send Ctrl+Shift+T to restore previous tabs
Send("^+t")
