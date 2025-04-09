#Requires AutoHotkey v2.0
#SingleInstance Force

; Logging function
LogMessage(message) {
    static logFile := ""
    static logInitialized := false

    ; Initialize log file with a unique name based on timestamp
    if (!logInitialized) {
        ; Create a unique log file name with timestamp
        timestamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
        logFile := A_ScriptDir "\select_previous_sentence_log_" timestamp ".txt"

        try {
            FileAppend("=== Log started at " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " ===`n", logFile)
            logInitialized := true
        } catch as err {
            ; If we can't write to the log file, disable logging
            logInitialized := true  ; Prevent further attempts
            return
        }
    }

    ; Append message with timestamp
    timestamp := FormatTime(A_Now, "HH:mm:ss.fff")
    try {
        FileAppend(timestamp " - " message "`n", logFile)
    } catch {
        ; Silently fail if we can't write to the log
    }
}

; Select text up to the previous period, handling multi-line sentences
; Store the clipboard's current content
ClipSaved := A_Clipboard
LogMessage("Script started - Original clipboard: '" ClipSaved "'")

; Initialize selection
LogMessage("Initializing selection with first character")
Send "+{Left}"
A_Clipboard := ""
Send "^c"
try ClipWait(1)
catch {
    LogMessage("ERROR: Failed to get initial selection")
    A_Clipboard := ClipSaved
    return
}
LogMessage("Initial selection: '" A_Clipboard "'")

; Variables to track selection state
prevClipLen := 0
unchangedCount := 0
maxUnchangedCount := 3  ; Stop after this many attempts with no change
maxSelectionSize := 1000  ; Maximum selection size to prevent runaway selection

; Keep selecting until we find a period or beginning of paragraph
LoopCount := 0
LogMessage("Starting main selection loop")
while (true) {
    LoopCount++
    LogMessage("Loop iteration " LoopCount " - Current selection length: " StrLen(A_Clipboard))

    ; STOP CONDITIONS - Check these first

    ; 1. Stop if we find a period after at least 5 characters
    if (StrLen(A_Clipboard) > 5 && InStr(A_Clipboard, ".")) {
        LogMessage("STOP: Found period after at least 5 characters")
        break
    }

    ; 2. Stop if we find a paragraph boundary (any newline character)
    if (InStr(A_Clipboard, "`n")) {
        LogMessage("STOP: Found paragraph boundary (newline character)")
        break
    }

    ; 3. Stop if we're at the beginning of a paragraph (newline at start)
    if (SubStr(A_Clipboard, 1, 1) = "`n") {
        LogMessage("STOP: Found newline at start of selection")
        break
    }

    ; 4. Stop if selection is getting too large (safety measure)
    if (StrLen(A_Clipboard) > maxSelectionSize) {
        LogMessage("STOP: Selection too large (safety limit reached)")
        break
    }

    ; 5. Stop if selection hasn't changed (we might be at the beginning of text area)
    currentLen := StrLen(A_Clipboard)
    if (currentLen = prevClipLen) {
        unchangedCount++
        LogMessage("Selection unchanged - Count: " unchangedCount)
        if (unchangedCount >= maxUnchangedCount) {
            LogMessage("STOP: Selection hasn't changed for " unchangedCount " iterations")
            break  ; We're probably at the beginning of the text area
        }
    } else {
        unchangedCount := 0  ; Reset counter if selection changed
    }
    prevClipLen := currentLen

    ; If we have less than 5 characters selected, check for period
    if (StrLen(A_Clipboard) < 5 && InStr(A_Clipboard, ".")) {
        LogMessage("Found period in first 5 characters, moving left to exclude it")
        Send "{Left}"  ; Move left to exclude the period
    }

    ; Continue selecting to the left
    LogMessage("Continuing selection to the left")
    Send "+{Left}"
    A_Clipboard := ""
    Send "^c"
    try ClipWait(1)
    catch {
        LogMessage("ERROR: Failed to get clipboard content")
        A_Clipboard := ClipSaved
        return
    }
    LogMessage("New selection: '" A_Clipboard "'")

    ; If we're at the start of a line, stop - we've reached a paragraph boundary
    if (SubStr(A_Clipboard, 1, 1) = "`n") {
        LogMessage("STOP: Found newline at start of selection - paragraph boundary")
        break
    }
}

LogMessage("Selection loop complete, finalizing selection")
Send "+{Right}"

; Copy the final selection to clipboard
A_Clipboard := ""
Send "^c"
try ClipWait(1)
catch {
    LogMessage("ERROR: Failed to get final clipboard content")
    A_Clipboard := ClipSaved
    return
}
LogMessage("Final selection: '" A_Clipboard "'")

; Run the text-to-speech script
LogMessage("Running text-to-speech script")
Run A_ScriptDir "\textToElevenlabs.ahk"

; No need to restore original clipboard since we want to keep the selection
LogMessage("Script completed successfully")
