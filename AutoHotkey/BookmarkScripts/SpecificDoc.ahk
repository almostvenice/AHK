#Requires AutoHotkey v2.0
#SingleInstance Force

; Create GUI for logging
MyGui := Gui()
MyGui.SetFont("s10", "Consolas")
LogBox := MyGui.Add("Edit", "r10 w600 ReadOnly vLogBox")
MyGui.Title := "URL Debug Log"
MyGui.Show()

; Check if we're running in AHK v2
if (SubStr(A_AhkVersion, 1, 1) != "2") {
    MsgBox("This script requires AutoHotkey v2. You are running version " . A_AhkVersion . ".`n`nPlease run this script with AutoHotkey v2.", "Version Error", 16)
    ExitApp
}

; Configuration
docId := "1NyhqufOJqxWjPV-d_IUHMUgqPR0WKcoEXAh4lTrvkXA"  ; Document ID
tabId := "t.37w06j8r7o47"  ; Tab ID - change this to switch tabs

; Function to launch Google Docs
LaunchGoogleDocs(docId := "", tabId := "") {
    ; Build the URL
    baseUrl := "https://docs.google.com"
    url := docId ? baseUrl . "/document/d/" . docId . "/edit" : baseUrl
    
    ; Add tab parameter if specified
    if (tabId)
        url .= "?tab=" . tabId
    
    ; Try to find existing PWA window for this specific doc
    windowTitle := "Technology tracker - Google Docs"
    
    ; First try to find a PWA window
    SetTitleMatchMode(2)  ; Partial match
    if (existingWindow := WinExist(windowTitle . " ahk_exe chrome.exe")) {
        ; Check if it's a PWA window
        windowStyle := WinGetStyle("ahk_id " existingWindow)
        
        ; Get process info
        pid := WinGetPID("ahk_id " existingWindow)
        title := WinGetTitle("ahk_id " existingWindow)
        
        ; Log basic window info
        LogBox.Value := "Window Info:`n"
        LogBox.Value .= "Title: " title "`n"
        LogBox.Value .= "PID: " pid "`n"
        LogBox.Value .= "Style: 0x" Format("{:X}", windowStyle) "`n"
        LogBox.Value .= "URL: " url "`n"
        
        ; Get process command line using PowerShell
        tempFile := A_Temp "\chrome_info.txt"
        RunWait(Format("powershell -Command `"Get-CimInstance Win32_Process -Filter 'ProcessId = {1}' | Select-Object CommandLine | ConvertTo-Json > '{2}'`"", pid, tempFile), , "Hide")
        
        if FileExist(tempFile) {
            cmdLine := FileRead(tempFile)
            LogBox.Value .= "Command Line: " cmdLine "`n"
            FileDelete(tempFile)
        }
        LogBox.Value .= "---`n"
        
        ; Check if it's a PWA window
        if (windowStyle & 0x800000) {  ; WS_BORDER style indicates PWA window
            ; Log window state
            LogBox.Value .= "Window state: " WinGetMinMax("ahk_id " existingWindow) "`n"
            
            ; If minimized, restore it
            if WinGetMinMax("ahk_id " existingWindow) = -1 {
                LogBox.Value .= "Restoring minimized window...`n"
                WinRestore("ahk_id " existingWindow)
            }
            
            ; Activate the window
            LogBox.Value .= "Activating window...`n"
            WinActivate("ahk_id " existingWindow)
            Sleep(100)  ; Give it a moment
            
            ; Verify activation
            if WinActive("ahk_id " existingWindow)
                LogBox.Value .= "Window successfully activated`n"
            else
                LogBox.Value .= "Failed to activate window`n"
            
            return
        }
    }
    
    ; No existing window found, launch new one
    chromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if !FileExist(chromePath) {
        MsgBox("Could not find Google Chrome. Please make sure Chrome is installed.", "Error", 16)
        return
    }
    
    ; Try to launch Chrome in PWA mode
    Run('"' chromePath '" --app="' . url . '"')
    
    ; Wait for the window to appear and activate it
    if WinWait(windowTitle . " ahk_exe chrome.exe", , 10) {  ; Wait up to 10 seconds
        Sleep(500)  ; Give the window a moment to fully initialize
        WinActivate(windowTitle . " ahk_exe chrome.exe")
    } else {
        MsgBox("Failed to detect new window after launch", "Error", 16)
    }
}

; Launch with configured document ID and tab
LaunchGoogleDocs(docId, tabId)

/*
How to get a document ID:
1. Open your Google Doc in Chrome
2. Look at the URL, it will be like:
   https://docs.google.com/document/d/1234567890abcdef/edit
3. Copy the ID part (1234567890abcdef in this example)
4. Paste it as the docId value at the top of this script
*/
