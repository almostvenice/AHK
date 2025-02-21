#Requires AutoHotkey v2.0

repoPath := "C:\Users\David\AppData\Roaming\espanso"
gitPath := "C:\Program Files\Git\bin\git.exe"
logFile := "C:\Users\David\update_log.txt"

; Clear previous logs
FileDelete(logFile)

; Log script start
FileAppend("Script started`n", logFile, "UTF-8")

; Check if Git is installed
if !FileExist(gitPath) {
    FileAppend("Git not found!`n", logFile, "UTF-8")
    MsgBox("Error: Git is not installed!")
    ExitApp()
}

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
