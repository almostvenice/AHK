#Requires AutoHotkey v2.0

; Define paths dynamically
repoPath := A_ScriptDir "\.."  ; Go up one directory from the script location
gitPath := GetGitPath()  ; Get Git executable dynamically
logFile := A_Desktop "\update_log.txt"  ; Store log on Desktop for easier access
branch := "main"  ; Change this if using a different branch

; Ensure Git exists
if !FileExist(gitPath) {
    MsgBox("Error: Git not found. Please install Git or set the correct path in the script.")
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
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" log -1 --pretty=format:"Latest commit: %%h - %%s (%%cr)" > "%TEMP%\commit_info.txt"', repoPath, gitPath), , "Hide")
    if FileExist(A_Temp "\commit_info.txt") {
        commitInfo := FileRead(A_Temp "\commit_info.txt")
        FileDelete(A_Temp "\commit_info.txt")
    }

    if (oldHash != newHash) {
        FileAppend("Git pull successful - Updated from " oldHash " to " newHash " at " A_Now "`n", logFile, "UTF-8")
        MsgBox("Updates pulled successfully!`n" commitInfo)
    } else {
        FileAppend("Git pull completed - Already up to date at " A_Now "`n", logFile, "UTF-8")
        MsgBox("Already up to date!`n" commitInfo)
    }
} catch {
    FileAppend("Git pull failed at " A_Now "`n", logFile, "UTF-8")
    MsgBox("Error: Failed to update the Espanso repo.")
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
