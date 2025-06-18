#Requires AutoHotkey v2.0
#SingleInstance Force

; Try to find existing Google Docs window
if (existingWindow := WinExist("Google Docs")) {
    ; If minimized, restore it
    if WinGetMinMax("ahk_id " existingWindow) = -1
        WinRestore("ahk_id " existingWindow)
    ; Activate the window
    WinActivate("ahk_id " existingWindow)
} else {
    ; No existing window, launch Google Docs
    try {
        Run "chrome --app=https://docs.google.com"
    } catch as err {
        ; If that fails, try with full Chrome path
        chromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
        if FileExist(chromePath) {
            try {
                Run '"' chromePath '" --app=https://docs.google.com'
            } catch as err {
                MsgBox("Error launching Google Docs: " . err.Message, "Error", 16)
            }
        } else {
            MsgBox("Could not find Google Chrome. Please make sure Chrome is installed.", "Error", 16)
        }
    }
    
    ; Wait for the window to appear and activate it
    try {
        WinWait("Google Docs", , 10)  ; Wait up to 10 seconds
        WinActivate("Google Docs")
    }
}
