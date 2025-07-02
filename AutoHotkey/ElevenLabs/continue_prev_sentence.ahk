#Requires AutoHotkey v2.0

; hit ESC,then the left arrow, then run select_previous_sentence.ahk
Send "{Escape}"
Sleep 500
Send "{Left}"
Sleep 500
Run "select_previous_sentence.ahk"
Return

