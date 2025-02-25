#Requires AutoHotkey v2.0

:*:xx::{
    A_Clipboard := ""  ; Clear clipboard
    Send("^+{Left 10}")  ; Select last 10 characters
    Sleep(500)
    Send("^c")  ; Copy selection
    ClipWait(0.5)

    prevText := Trim(A_Clipboard)

    if (prevText != "") {
        ; Properly escape quotes for PowerShell
        command := "powershell -Command "
            . "'$wshell = New-Object -ComObject WScript.Shell; " 
            . "$wshell.SendKeys(':"
            . prevText
            . "')'"

        Run(A_ComSpec " /c " command, , "Hide")
    }
}
