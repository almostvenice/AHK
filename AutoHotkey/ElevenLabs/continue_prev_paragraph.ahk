#Requires AutoHotkey v2.0

; hit ESC,then the left arrow, then run select_prev_paragraph.ahk
Send "{Escape}"
Sleep 500
Send "{Left}"
Sleep 500
Run "select_prev_paragraph.ahk"
Return
