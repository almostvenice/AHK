#Requires AutoHotkey v2.0

; Define paths dynamically
repoPath := A_ScriptDir "\.."  ; Go up one directory from the script location
gitPath := GetGitPath()  ; Get Git executable dynamically
logFile := A_Desktop "\update_log.txt"  ; Store log on desktop for easier access
branch := "main"  ; Change this if using a different branch

; Function to show a dark mode message box
DarkModeBox(text, title := "", timeout := 0) {
    darkGui := Gui(,title)  ; Pass title in Gui constructor
    darkGui.BackColor := "0x2D2D2D"
    darkGui.SetFont("s10 cWhite", "Segoe UI")
    
    ; Add text with word wrap
    darkGui.Add("Text", "w250 wrap", text).Opt("Background" . darkGui.BackColor)
    
    ; Add OK button with dark styling
    okBtn := darkGui.Add("Button", "x85 y+10 w80 h30 Default", "OK")
    okBtn.OnEvent("Click", (*) => darkGui.Destroy())
    okBtn.Opt("+Background0x4D4D4D")  ; Dark button color
    okBtn.SetFont("cWhite")
    
    ; Set window options
    darkGui.Opt("+AlwaysOnTop")
    
    ; Calculate position - center horizontally, fixed position from top
    screenWidth := A_ScreenWidth
    guiWidth := 270  ; Narrower width
    guiHeight := 150  ; Approximate height
    x := (screenWidth - guiWidth) / 2
    
    ; Show the GUI with specific position and size
    darkGui.Show(Format("w{1} h{2} x{3} y50", guiWidth, guiHeight, x))
    
    ; If timeout is specified, wait for the timeout
    if (timeout > 0) {
        Sleep(timeout * 1000)  ; Wait for the specified time
        darkGui.Destroy()  ; Then destroy the GUI
    }
    
    return darkGui
}

; Ensure Git exists
if !FileExist(gitPath) {
    DarkModeBox("Error: Git not found. Please install Git or set the correct path in the script.", "Update Status", 5)
    ExitApp()
}

; Create log file if missing
if !FileExist(logFile) {
    FileAppend("", logFile, "UTF-8")
}

; Log script start
FileAppend("Script started at " A_Now "`n", logFile, "UTF-8")

; Run Git Pull
try {
    ; First, get the commit hash before pull
    oldHash := ""
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" rev-parse HEAD > "%TEMP%\old_hash.txt"', repoPath, gitPath), , "Hide")
    if FileExist(A_Temp "\old_hash.txt") {
        oldHash := Trim(FileRead(A_Temp "\old_hash.txt"))
        FileDelete(A_Temp "\old_hash.txt")
    }

    ; Do the pull
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" pull origin {}', repoPath, gitPath, branch), , "Hide")
    
    ; Get new hash
    newHash := ""
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" rev-parse HEAD > "%TEMP%\new_hash.txt"', repoPath, gitPath), , "Hide")
    if FileExist(A_Temp "\new_hash.txt") {
        newHash := Trim(FileRead(A_Temp "\new_hash.txt"))
        FileDelete(A_Temp "\new_hash.txt")
    }

    ; Get the latest commit info
    commitInfo := ""
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" log -1 --pretty=format:"Latest commit: %h - %s (%cr)" > "%TEMP%\commit_info.txt"', repoPath, gitPath), , "Hide")
    if FileExist(A_Temp "\commit_info.txt") {
        commitInfo := FileRead(A_Temp "\commit_info.txt")
        FileDelete(A_Temp "\commit_info.txt")
    }

    if (oldHash != newHash) {
        FileAppend("Git pull successful - Updated from " oldHash " to " newHash " at " A_Now "`n", logFile, "UTF-8")
        
        ; Launch or activate PhraseExpander
        try {
            if !WinExist("ahk_exe PhraseExpander.exe") {
                Run('"C:\Program Files\PhraseExpander\PhraseExpander.exe"')
                Sleep(3000)  ; Wait 3 seconds
            }
            WinActivate("ahk_exe PhraseExpander.exe")
            Sleep(4000)  ; Wait 4 seconds
            Send("^{F5}")  ; Send Ctrl+F5

            Sleep(2000)  ; Wait a bit for the update to complete
            
            ; Minimize PhraseExpander window
            Send("#{Down}")  ; Press Windows+Down to minimize
        }
        
        DarkModeBox("Updates pulled successfully!`n" commitInfo, "Update Status", 5)
    } else {
        FileAppend("Git pull completed - Already up to date at " A_Now "`n", logFile, "UTF-8")
        DarkModeBox("Already up to date!`n" commitInfo, "Update Status", 5)
    }
} catch {
    FileAppend("Git pull failed at " A_Now "`n", logFile, "UTF-8")
    DarkModeBox("Error: Failed to update the Espanso repo.", "Update Status", 5)
}

; Minimize PhraseExpander window if it's open
Sleep(500)  ; Give a moment for any window operations to complete
windows := WinGetList("ahk_exe PhraseExpander.exe")
for window in windows {
    try {
        ; Activate window and ensure it's active
        WinActivate("ahk_id " window)
        WinWaitActive("ahk_id " window, , 2)  ; Wait up to 2 seconds for window to be active
        Sleep(200)  ; Additional wait to ensure window is ready
        
        ; Try Windows+Down once to minimize
        Send("#{Down}")
        Sleep(100)
        
        ; If that didn't work, try WinMinimize
        if !WinGetMinMax("ahk_id " window) {
            WinMinimize("ahk_id " window)
        }
    }
}

ExitApp()


; ==============================
; Function: GetGitPath()
; Detects Git installation path dynamically
; ==============================
GetGitPath() {
    try {
        gitPath := ""
        RunWait("where git > %TEMP%\git_path.txt", , "Hide")
        if FileExist(A_Temp "\git_path.txt") {
            FileRead(gitPath, A_Temp "\git_path.txt")
            gitPath := Trim(gitPath)
            FileDelete(A_Temp "\git_path.txt")
        }
        
        ; Check common Git installation paths if 'where' command fails
        if (gitPath = "") {
            possiblePaths := [
                "C:\\Program Files\\Git\\cmd\\git.exe",
                "C:\\Program Files (x86)\\Git\\cmd\\git.exe",
                "C:\\Program Files\\Git\\bin\\git.exe",
                "C:\\Git\\cmd\\git.exe"
            ]
            for path in possiblePaths {
                if FileExist(path) {
                    gitPath := path
                    break
                }
            }
        }
        
        return gitPath
    } catch {
        return ""  ; Return empty string if Git is not found
    }
}
