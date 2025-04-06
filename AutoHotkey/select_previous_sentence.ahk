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
while (true) {
    ; If we have more than 5 characters selected, check for period
    if (StrLen(A_Clipboard) < 5 && InStr(A_Clipboard, ". ")) {
        Send "{Left}"  ; Move left to exclude the period
    }
    if (StrLen(A_Clipboard) > 5 && InStr(A_Clipboard, ".")) {
        break
    }
    
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

; Copy the final selection to clipboard
Send "^c"
try ClipWait(1)

; Run the text-to-speech script
Run A_ScriptDir "\textToElevenlabs.ahk"

; No need to restore original clipboard since we want to keep the selection
