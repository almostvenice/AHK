#Requires AutoHotkey v2.0


; if !A_IsAdmin {
;     try Run '*RunAs "' A_ScriptFullPath '"'
;     ExitApp
; }

; Open Windows Display Settings
Run "ms-settings:display"

; ; Wait for the window to open
; Sleep 2000

; ; Send 13 tabs
; Loop 13 {
;     Send "{Tab}"
;     Sleep 50  ; Small delay between tabs for reliability
; }

; ; Press spacebar
; Send "{Space}"

; ; Press down arrow 4 times
; Loop 4 {
;     Send "{Down}"
;     Sleep 50
; }

; ; Press Enter
; Send "{Enter}"

; ; Wait 2 seconds
; Sleep 2000

; ; Press Tab and Enter
; Send "{Tab}"
; Sleep 50
; Send "{Enter}"

ExitApp
