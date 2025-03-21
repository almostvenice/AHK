#Requires AutoHotkey v2.0

; Define paths dynamically
repoPath := A_AppData "\espanso"
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
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" pull origin {}', repoPath, gitPath, branch), , "Hide")
    FileAppend("Git pull successful at " A_Now "`n", logFile, "UTF-8")
    MsgBox("Espanso repo updated successfully from commit on March 21st @ 1:57pm")
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
