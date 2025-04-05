#Requires AutoHotkey v2.0
#SingleInstance Force

; Select text up to the next period, handling multi-line sentences
; Store the clipboard's current content
ClipSaved := A_Clipboard

; Initialize selection
Send "+{Right}"
A_Clipboard := ""
Send "^c"
try ClipWait(1)
catch {
    A_Clipboard := ClipSaved
    return
}

; Keep selecting until we find a period
while (!InStr(A_Clipboard, ".")) {
    Send "+{Right}"
    A_Clipboard := ""
    Send "^c"
    try ClipWait(1)
    catch {
        A_Clipboard := ClipSaved
        return
    }
    
    ; If we're at the end of a line, select down
    if SubStr(A_Clipboard, -1) = "`n" {
        Send "+{Down}"
    }
}

; Restore original clipboard
A_Clipboard := ClipSaved
