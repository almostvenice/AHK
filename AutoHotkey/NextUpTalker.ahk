;
; NextUpTalker.ahk
; Receives text from PhraseExpander and speaks it through NextUp Talker
; Format: {#run "path_to_ahk\NextUpTalker.ahk" -[param="text to speak"]#}
;

#Requires AutoHotkey v2.0
#SingleInstance Force

if A_Args.Length > 0 {
    textToSpeak := A_Args[1]
    
    ; Launch or activate NextUp Talker
    if !WinExist("ahk_exe NextUpTalker.exe") {
        Run "C:\Program Files (x86)\NextUp Talker\NextUpTalker.exe"
    }
    
    ; Wait for NextUp Talker window
    if WinWait("ahk_exe NextUpTalker.exe",, 10) {
        WinActivate
        Sleep 500  ; Give it time to fully load
        
        ; ; Focus input area
        ; Send "^!t"
        ; Sleep 100
        
        ; Select all existing text and delete it
        Send "^a"
        Sleep 50
        Send "{Delete}"
        Sleep 50
        
        ; Type the new text
        A_Clipboard := textToSpeak
        Send "^v"
        Sleep 100
        
        ; Press Alt+S for speak input
        Send "!s"
        Sleep 200
    }
}

; Example usage in PhraseExpander:
; {#run "C:\Users\pyjoh\Documents\Espanso-AHK\AutoHotkey\NextUpTalker.ahk" -[param="Three-Cough Assist Please"]#}
;
; IMPORTANT: The text should be in quotes in the param:
; CORRECT:   -[param="text here"]
; INCORRECT: -[param=text here]
