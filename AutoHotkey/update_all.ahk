#NoEnv
SetBatchLines, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

; Define repo path
repoPath := "C:\Users\David\AppData\Roaming\espanso"

; Check if Git is installed
If !FileExist("C:\Program Files\Git\bin\git.exe") {
    MsgBox, Git is not installed! Please install Git for Windows.
    ExitApp
}

; Open a hidden command prompt to update the repo
Run, %ComSpec% /c cd "%repoPath%" && git pull origin main,, Hide

MsgBox, Espanso repo updated successfully!
ExitApp
