#Requires AutoHotkey v2.0
#SingleInstance Force

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
                triggers[trigger] := true
                ; Store first two letters as a short trigger
                shortKey := SubStr(trigger, 1, 2)
                if (StrLen(trigger) > 2)
                    shortTriggers[shortKey] := true
            }
        }
    }
    if (triggers.Count = 0) {
        MsgBox("No triggers found starting with x")
        ExitApp
    }
} catch Error as e {
    MsgBox("Error loading triggers: " e.Message)
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
    
    ; First check for all triggers and find the rightmost one
    rightmostTrigger := ""
    rightmostPos := -1
    
    for triggerKey in triggers {
        pos := InStr(currentWord, triggerKey)
        while (pos > 0) {  ; Find all occurrences
            if (pos > rightmostPos) {
                rightmostPos := pos
                rightmostTrigger := triggerKey
            }
            pos := InStr(currentWord, triggerKey, , pos + 1)
        }
    }
    
    ; If we found a trigger, process it
    if (rightmostTrigger != "") {
        ProcessTrigger(currentWord, rightmostTrigger)
        A_Clipboard := savedClip
        return
    }
    
    ; Then check for 2-letter triggers if no full trigger was found
    for shortKey in shortTriggers {
        pos := InStr(currentWord, shortKey)
        while (pos > 0) {  ; Find all occurrences
            if (pos > rightmostPos) {
                rightmostPos := pos
                rightmostTrigger := shortKey
            }
            pos := InStr(currentWord, shortKey, , pos + 1)
        }
    }
    
    ; If we found a short trigger, process it
    if (rightmostTrigger != "") {
        ProcessTrigger(currentWord, rightmostTrigger)
    }
    
    ; Restore clipboard
    A_Clipboard := savedClip
}

ProcessTrigger(currentWord, trigger) {
    Send("{Backspace " . StrLen(currentWord) . "}")  ; Delete current word
    beforeTrigger := SubStr(currentWord, 1, InStr(currentWord, trigger) - 1)  ; Text before rightmost trigger
    afterTrigger := SubStr(currentWord, InStr(currentWord, trigger) + StrLen(trigger))  ; Text after rightmost trigger
    
    if (beforeTrigger != "")
        Send(beforeTrigger)  ; Text before trigger
    Send(" " . trigger)  ; Trigger with spaces
    if (afterTrigger != "")
        Send(afterTrigger)  ; Rest of word
}
