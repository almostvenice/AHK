#Requires AutoHotkey v2.0
#SingleInstance Force

; ; Create debug window
; debugGui := Gui()
; debugGui.Opt("+AlwaysOnTop +Resize")
; debugGui.SetFont("s10", "Consolas")
; debugLog := debugGui.Add("Edit", "vMyEdit w600 h400 ReadOnly")
; debugGui.Title := "Trigger Debug Log"
; debugGui.Show()

; ; Function to log debug messages
; LogDebug(message) {
;     global debugLog
;     debugLog.Value := debugLog.Value . message . "`n"
;     debugLog.Opt("0x100000")  ; Scroll to bottom
; }

; Load triggers from CSV
triggers := Map()
shortTriggers := Map()  ; Map for 2-letter triggers

try {
    Loop read "C:\Users\pyjoh\Documents\Espanso-AHK\pyjoh.csv" {
        if (A_Index = 1)  ; Skip header
            continue
            
        if (InStr(A_LoopReadLine, "[GROUP]"))  ; Skip group headers
            continue
            
        fields := StrSplit(A_LoopReadLine, ",")
        if (fields.Length >= 3 && fields[2] != "") {  ; Check if abbreviation exists
            trigger := fields[2]
            if (SubStr(trigger, 1, 1) = "x") {  ; Only store triggers starting with x
                if (StrLen(trigger) > 2) {
                    triggers[trigger] := true  ; Only add to full triggers if longer than 2 chars
                    shortKey := SubStr(trigger, 1, 2)
                    shortTriggers[shortKey] := true
                } else {
                    shortTriggers[trigger] := true  ; Add 2-letter triggers directly to short triggers
                }
            }
        }
    }

    ; Log loaded triggers
    ; LogDebug("=== Loaded Triggers (>2 chars) ===")
    triggerList := ""
    for triggerKey in triggers {
        triggerList .= triggerKey . ", "
    }
    ; LogDebug(triggerList)
    
    ; LogDebug("`n=== Short Triggers (2 chars) ===")
    shortList := ""
    for shortKey in shortTriggers {
        shortList .= shortKey . ", "
    }
    ; LogDebug(shortList)

    if (triggers.Count = 0 && shortTriggers.Count = 0) {
        ; LogDebug("`nError: No triggers found starting with x")
        ExitApp
    }
} catch Error as e {
    ; LogDebug("`nError loading triggers: " . e.Message)
    ExitApp
}

; Hook keyboard input
#HotIf true
~x::
{
    ; Wait for more input
    Sleep(3000)  ; Wait longer to see if user types more
    
    ; Get the current word
    savedClip := A_Clipboard
    A_Clipboard := ""
    
    Send("^+{Left}")  ; Select word to left
    Send("^c")  ; Copy selected text
    if !ClipWait(0.2) {  ; Wait a bit longer for clipboard
        A_Clipboard := savedClip
        return
    }
    
    currentWord := A_Clipboard
    if (StrLen(currentWord) <= 1) {  ; Ignore single characters
        A_Clipboard := savedClip
        return
    }
    
    Send("{Right}")  ; Unselect
    
    ; Find the rightmost trigger
    rightmostTrigger := ""
    rightmostPos := -1
    
    ; Check all triggers (both full and short) at once and find the rightmost one
    for triggerKey in triggers {
        pos := InStr(currentWord, triggerKey, , -1)  ; Start from the end
        if (pos > rightmostPos) {
            rightmostPos := pos
            rightmostTrigger := triggerKey
        }
    }
    
    for shortKey in shortTriggers {
        pos := InStr(currentWord, shortKey, , -1)  ; Start from the end
        if (pos > rightmostPos) {
            rightmostPos := pos
            rightmostTrigger := shortKey
        }
    }
    
    ; If we found a trigger, process it
    if (rightmostTrigger != "") {
        ProcessTrigger(currentWord, rightmostTrigger)
    }
    
    ; Restore clipboard
    A_Clipboard := savedClip
}

ProcessTrigger(currentWord, trigger) {
    ; ; Log debug message
    ; LogDebug("`nProcessing word: " . currentWord . "`nTrigger found: " . trigger . "`nPosition: " . InStr(currentWord, trigger, , -1))

    ; Delete the entire word first
    Send("{Backspace " . StrLen(currentWord) . "}")

    ; Find the position of the rightmost trigger
    triggerPos := InStr(currentWord, trigger, , -1)  ; Start from the end to find last occurrence
    
    ; Split the word into parts
    beforeTrigger := SubStr(currentWord, 1, triggerPos - 1)  ; Text before the trigger
    
    ; Reconstruct the word: text before trigger + space + trigger
    if (beforeTrigger != "")
        Send(beforeTrigger)
    Send(" " . trigger)  ; Always add a space before the trigger
}
