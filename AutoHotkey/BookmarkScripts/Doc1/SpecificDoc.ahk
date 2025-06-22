#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration
docId := "1NyhqufOJqxWjPV-d_IUHMUgqPR0WKcoEXAh4lTrvkXA"  ; Document ID
tabId := "t.37w06j8r7o47"  ; Tab ID - change this to switch tabs

; Function to close all Google Docs PWA windows
CloseDocsWindows() {
    ; Get all Chrome windows
    SetTitleMatchMode(2)  ; Partial match
    
    ; Try multiple times to ensure all PWA windows are closed
    maxAttempts := 3
    Loop maxAttempts {
        ; First try normal window closing
        windowList := WinGetList("ahk_exe chrome.exe")
        windowsClosed := false
        
        for hwnd in windowList {
            title := WinGetTitle("ahk_id " hwnd)
            if InStr(title, "Google Docs") && !InStr(title, " - Google Chrome") {
                WinClose("ahk_id " hwnd)
                windowsClosed := true
            }
        }
        
        ; Then forcefully kill any remaining PWA processes
        RunWait("powershell.exe -NoProfile -Command `"Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -like '*--app=https://docs.google.com*'} | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }`"",, "Hide")
        
        ; Check if any Google Docs windows still exist
        if !WinExist("Google Docs ahk_exe chrome.exe") {
            break  ; All windows closed successfully
        }
        
        Sleep(1000)  ; Wait before next attempt
    }
    
    ; Final sleep to ensure everything is closed
    Sleep(1000)
}

; Function to launch Google Docs
LaunchGoogleDocs(docId := "", tabId := "") {
    ; First close any existing Google Docs windows
    CloseDocsWindows()
    Sleep(500)  ; Give windows time to close
    
    ; Build the URL
    baseUrl := "https://docs.google.com"
    url := docId ? baseUrl . "/document/d/" . docId . "/edit" : baseUrl
    if (tabId)
        url .= "?tab=" tabId
    
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
        Sleep(1000)  ; Give Chrome time to fully initialize
        WinActivate("ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe")
    }
}

; Launch with configured document ID and tab
LaunchGoogleDocs(docId, tabId)
