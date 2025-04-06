#Requires AutoHotkey v2.0
#SingleInstance Force

; Hook keyboard input
#HotIf true

; Function to check for autosuggest window
CheckAutosuggest() {
    try {
        windows := WinGetList()
        for hwnd in windows {
            try {
                if (WinGetProcessName("ahk_id " hwnd) = "PhraseExpander.exe" 
                    && InStr(WinGetTitle("ahk_id " hwnd), "Autosuggest")) {
                    return true
                }
            }
        }
    }
    return false
}

; Function to handle double character triggers
HandleDoubleTrigger(char) {
    static lastTime := Map()
    thisTime := A_TickCount

    ; Initialize the time for this character if not exists
    if !lastTime.Has(char)
        lastTime[char] := 0
    
    ; Check if this character was typed within 3000ms AND the last key was also the same character
    if (thisTime - lastTime[char] < 3000 && A_PriorKey = char) {
        ; Two identical characters detected, give PhraseExpander a moment
        Sleep(1000)
        
        ; First check for autosuggest
        if (!CheckAutosuggest()) {
            ; Remove the previously typed characters
            Send("{Backspace 2}")
            ; Type characters with a space and check again
            Send(" " char char)
            Sleep(100)  ; Wait for autosuggest
            
            ; Second check for autosuggest
            if (!CheckAutosuggest()) {
                ; If still no autosuggest, remove the space and characters
                Send("{Backspace 3}")
                ; Retype the characters
                Send(char char)
            }
        }
    }
    
    ; Update last time for this character
    lastTime[char] := thisTime
}

; Hotkeys for each trigger
~x::HandleDoubleTrigger("x")
~z::HandleDoubleTrigger("z")
