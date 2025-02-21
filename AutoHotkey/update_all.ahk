#Requires AutoHotkey v2.0

repoPath := "C:\Users\David\AppData\Roaming\espanso"
gitPath := "C:\Program Files\Git\cmd\git.exe"
logFile := "C:\Users\David\update_log.txt"

; Ensure Git exists
if !FileExist(gitPath) {
    MsgBox("Error: Git not found at " gitPath)
    ExitApp()
}

; Create log file if missing
if !FileExist(logFile) {
    FileAppend("", logFile, "UTF-8")
}

; Log script start
FileAppend("Script started`n", logFile, "UTF-8")

; Run Git Pull
try {
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" pull origin main', repoPath, gitPath), , "Hide")
    FileAppend("Git pull successful!`n", logFile, "UTF-8")
    MsgBox("Espanso repo updated successfully!")
} catch {
    FileAppend("Git pull failed!`n", logFile, "UTF-8")
    MsgBox("Error: Failed to update the Espanso repo.")
}

ExitApp()
