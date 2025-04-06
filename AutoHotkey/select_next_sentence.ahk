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
while (true) {
    ; If we have less than 5 characters selected, check for period
    if (StrLen(A_Clipboard) < 5 && InStr(A_Clipboard, ".")) {
        Send "{Right}"  ; Move right to exclude the period
    }
    if (StrLen(A_Clipboard) > 5 && InStr(A_Clipboard, ".")) {
        break
    }
    
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

; Copy the final selection to clipboard
Send "^c"
try ClipWait(1)

; Run the text-to-speech script
Run A_ScriptDir "\textToElevenlabs.ahk"
; No need to restore original clipboard since we want to keep the selection
