#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration
docId := "1NyhqufOJqxWjPV-d_IUHMUgqPR0WKcoEXAh4lTrvkXA"  ; Document ID

; Function to close all Google Docs PWA windows
CloseDocsWindows() {
    ; Get all Chrome windows
    SetTitleMatchMode(2)  ; Partial match
    windowList := WinGetList("ahk_exe chrome.exe")
    
    ; Check each window
    for hwnd in windowList {
        ; Get window info
        title := WinGetTitle("ahk_id " hwnd)
        windowStyle := WinGetStyle("ahk_id " hwnd)
        
        ; Only close Google Docs PWA windows
        if (windowStyle & 0x800000) && InStr(title, "Google Docs") {
            WinClose("ahk_id " hwnd)
            Sleep(100)  ; Give it a moment to close
        }
    }
}

; Function to launch Google Docs and create new tab
LaunchGoogleDocsNewTab(docId := "") {
    ; First close any existing Google Docs windows
    CloseDocsWindows()
    Sleep(500)  ; Give windows time to close
    
    ; Build the URL
    baseUrl := "https://docs.google.com"
    url := docId ? baseUrl . "/document/d/" . docId . "/edit" : baseUrl
    
    ; Launch Chrome in PWA mode with the URL
    chromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if !FileExist(chromePath) {
        MsgBox("Could not find Google Chrome. Please make sure Chrome is installed.", "Error", 16)
        return
    }
    
    ; Launch new window and wait for it
    Run('"' chromePath '" --app="' url '"')
    
    ; Wait for the window to appear with the document title
    SetTitleMatchMode(2)  ; Partial match
    if WinWait("Google Docs ahk_exe chrome.exe", , 10) {  ; Wait up to 10 seconds
        Sleep(2000)  ; Give Chrome more time to fully initialize
        
        ; Try multiple times to activate and send shortcut
        maxAttempts := 5
        success := false
        
        Loop maxAttempts {
            try {
                ; Try to activate the window
                WinActivate("ahk_exe chrome.exe")
                Sleep(1000)  ; Longer wait between activation and sending keys
                
                ; Make sure window is active before sending keys
                if WinActive("ahk_exe chrome.exe") {
                    ; Send the shortcut once
                    Send("+{F11}")
                    Sleep(500)  ; Wait to see if it worked
                    success := true
                    break
                }
            } catch as err {
                ; If this attempt failed, wait and try again
                Sleep(500)
                continue
            }
        }
        
        if !success {
            MsgBox("Failed to create new tab after " maxAttempts " attempts", "Error", 16)
        }
    }
}

; Launch with configured document ID and create new tab
LaunchGoogleDocsNewTab(docId)
