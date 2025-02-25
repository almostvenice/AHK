#Requires AutoHotkey v2.0

:*:xx::{
    A_Clipboard := ""  ; Clear clipboard
    Send("^+{Left 4}")  ; Select last 4 characters
    Sleep(50)
    Send("^c")  ; Copy selection
    ClipWait(0.5)

    prevText := Trim(A_Clipboard)

    if (prevText != "") {
        ; Escape quotes properly for PowerShell execution
        command := 'powershell -Command "' 
            . '$wshell = New-Object -ComObject WScript.Shell; ' 
            . '$wshell.SendKeys(\':"' . prevText . '"\')"'
        
        Run(A_ComSpec ' /c ' command, , "Hide")
    }
}
