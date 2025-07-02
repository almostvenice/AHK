#Requires AutoHotkey v2.0

; hit ESC,then the right arrow, then run select_next_sentence.ahk
Send "{Escape}"
Sleep 500
Send "{Right}"
Sleep 500
Run "select_next_sentence.ahk"
Return
