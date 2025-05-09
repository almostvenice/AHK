#Requires AutoHotkey v2.0

; Tech Tracker Document URL
techTrackerUrl := "https://docs.google.com/document/d/1NyhqufOJqxWjPV-d_IUHMUgqPR0WKcoEXAh4lTrvkXA/edit?tab=t.sm4hg8iffusi"

; Function to check if URL exists in Chrome tabs and activate it
CheckAndActivateTab(targetUrl) {
    ; Get all Chrome windows
    windowList := WinGetList("ahk_exe chrome.exe")
    if !windowList.Length {
        return false
    }
    
    ; Store current window to restore later if needed
    currentWindow := WinGetID("A")
    
    ; Check each Chrome window
    for hwnd in windowList {
        ; Activate window to ensure we can interact with it
        WinActivate "ahk_id " hwnd
        Sleep 100  ; Give Chrome time to respond
        
        ; Start from first tab
        Send "^1"  ; Go to first tab
        Sleep 100
        
        ; Remember first tab's URL to detect when we've gone through all tabs
        Send "^l"  ; Focus address bar
        Sleep 50
        Send "^c"  ; Copy URL
        Sleep 50
        firstTabUrl := A_Clipboard
        
        Loop 50 {  ; Check up to 50 tabs
            ; Get current tab's URL
            Send "^l"  ; Focus address bar
            Sleep 50
            Send "^c"  ; Copy URL
            Sleep 50
            currentUrl := A_Clipboard
            
            ; If we found our URL, we're done
            if (InStr(currentUrl, targetUrl)) {
                return true
            }
            
            ; Go to next tab
            Send "^{Tab}"
            Sleep 100
            
            ; Get URL after tab switch to check if we're back at the start
            Send "^l"  ; Focus address bar
            Sleep 50
            Send "^c"  ; Copy URL
            Sleep 50
            
            ; If we're back at the first tab's URL, we've checked all tabs in this window
            if (A_Index > 1 && InStr(A_Clipboard, firstTabUrl)) {
                break
            }
        }
    }
    
    ; If we get here, URL wasn't found
    return false
}

; Main script
if !ProcessExist("chrome.exe") {
    Run "chrome.exe " techTrackerUrl
    ExitApp
}

; Try to find and activate existing tab
if !CheckAndActivateTab(techTrackerUrl) {
    ; If not found, open in new tab
    Run "chrome.exe " techTrackerUrl
}

ExitApp
