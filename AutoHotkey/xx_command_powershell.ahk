#Requires AutoHotkey v2.0

:*:xx::{
    A_Clipboard := ""  ; Clear clipboard
    Send("^+{Left 4}")  ; Select last 4 characters
    Sleep(50)
    Send("^c")  ; Copy selection
    ClipWait(0.5)

    prevText := Trim(A_Clipboard)

    if (prevText != "") {
        ; Format as :XXXX for Espanso
        command := "powershell -Command ""$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys(':" prevText "')"""
        Run(A_ComSpec " /c " command, , "Hide")
    }
}
