#Requires AutoHotkey v2.0
#NoEnv

repoPath := "C:\Users\David\AppData\Roaming\espanso"
gitPath := "C:\Program Files\Git\bin\git.exe"

; Check if Git is installed
if !FileExist(gitPath) {
    MsgBox("Git is not installed! Please install Git for Windows.")
    ExitApp()
}

; Run Git Pull in Hidden CMD
try {
    RunWait(Format('cmd.exe /c cd /d "{}" && "{}" pull origin main', repoPath, gitPath), , "Hide")
    MsgBox("Espanso repo updated successfully!")
} catch {
    MsgBox("Error: Failed to update the Espanso repo.")
}

ExitApp()
