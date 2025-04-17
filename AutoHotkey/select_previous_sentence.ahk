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

; Variables to track selection state
prevClipLen := 0
unchangedCount := 0
maxUnchangedCount := 3  ; Stop after this many attempts with no change
maxSelectionSize := 1000  ; Maximum character selection size to prevent runaway selection (About 150 words)

; Keep selecting until we find a period or beginning of paragraph
while (true) {

    ; STOP CONDITIONS - Check these first

    ; 1. Stop if we find a period after at least 5 characters
    if (StrLen(A_Clipboard) > 5 && InStr(A_Clipboard, ".")) {
        break
    }

    ; 2. Stop if we find a paragraph boundary (any newline character)
    if (InStr(A_Clipboard, "`n")) {
        break
    }

    ; 3. Stop if we're at the beginning of a paragraph (newline at start)
    if (SubStr(A_Clipboard, 1, 1) = "`n") {
        break
    }

    ; 4. Stop if selection is getting too large (safety measure)
    if (StrLen(A_Clipboard) > maxSelectionSize) {
        break
    }

    ; 5. Stop if selection hasn't changed (we might be at the beginning of text area)
    currentLen := StrLen(A_Clipboard)
    if (currentLen = prevClipLen) {
        unchangedCount++
        if (unchangedCount >= maxUnchangedCount) {
            break  ; We're probably at the beginning of the text area
        }
    } else {
        unchangedCount := 0  ; Reset counter if selection changed
    }
    prevClipLen := currentLen

    ; If we have less than 5 characters selected, check for period
    if (StrLen(A_Clipboard) < 5 && InStr(A_Clipboard, ".")) {
        Send "{Left}"  ; Move left to exclude the period
    }

    ; Continue selecting to the left
    Send "+{Left}"
    A_Clipboard := ""
    Send "^c"
    try ClipWait(1)
    catch {
        A_Clipboard := ClipSaved
        return
    }

    ; If we're at the start of a line, stop - we've reached a paragraph boundary
    if (SubStr(A_Clipboard, 1, 1) = "`n") {
        break
    }
}

; Copy the final selection to clipboard
A_Clipboard := ""
Send "^c"
try ClipWait(1)
catch {
    A_Clipboard := ClipSaved
    return
}

; Run the text-to-speech script
Run A_ScriptDir "\textToElevenlabs.ahk"

; No need to restore original clipboard since we want to keep the selection
