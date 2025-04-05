#Requires AutoHotkey v2.0
#SingleInstance Force

; Select text up to the previous period, handling multi-line sentences
; Store the clipboard's current content
ClipSaved := A_Clipboard

; Initialize selection
Send "+{Left}"
A_Clipboard := ""
Send "^c"
try ClipWait(1)
catch {
    A_Clipboard := ClipSaved
    return
}

; Keep selecting until we find a period
while (!InStr(A_Clipboard, ". ")) {
    Send "+{Left}"
    A_Clipboard := ""
    Send "^c"
    try ClipWait(1)
    catch {
        A_Clipboard := ClipSaved
        return
    }
    
    ; If we're at the start of a line, select up
    if SubStr(A_Clipboard, 1, 1) = "`n" {
        Send "+{Up}"
    }
}

Send "+{Right}"

; Restore original clipboard
A_Clipboard := ClipSaved
