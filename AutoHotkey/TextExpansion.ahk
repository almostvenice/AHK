#Requires AutoHotkey v2.0
#SingleInstance Force

; Function to ensure PhraseExpander is running
EnsurePhraseExpanderRunning() {
    ; Check if PhraseExpander process is running (even if minimized/in background)
    if !ProcessExist("PhraseExpander.exe") {
        ; PhraseExpander is not running, launch it
        try {
            ; Try multiple possible paths for PhraseExpander
            phraseExpanderPath := "C:\Program Files\PhraseExpander\PhraseExpander.exe"

            ; Check if the default path exists
            if FileExist(phraseExpanderPath) {
                Run(phraseExpanderPath)
            } else {
                ; Try alternative paths
                altPath1 := "C:\Program Files (x86)\PhraseExpander\PhraseExpander.exe"
                altPath2 := A_ProgramFiles "\PhraseExpander\PhraseExpander.exe"

                if FileExist(altPath1) {
                    Run(altPath1)
                } else if FileExist(altPath2) {
                    Run(altPath2)
                } else {
                    ; Last resort - try to run it without a full path
                    Run("PhraseExpander.exe")
                }
            }

            ; Wait for PhraseExpander process to start (up to 25 seconds)
            startTime := A_TickCount
            while (!ProcessExist("PhraseExpander.exe") && A_TickCount - startTime < 25000) {
                Sleep(500)
            }

            ; Give it a bit more time to fully initialize
            Sleep(2000)

            ; Try to minimize any PhraseExpander windows
            try {
                ; Try to find and minimize main window
                if WinExist("ahk_exe PhraseExpander.exe") {
                    WinActivate
                    Sleep(500)  ; Give it time to activate
                    WinMinimize  ; Use WinMinimize instead of Windows+Down
                }

                ; Also check for windows with PhraseExpander in the title
                if WinExist("PhraseExpander") {
                    WinActivate
                    Sleep(500)
                    WinMinimize
                }
            } catch {
                ; If minimizing fails, just continue
            }
        } catch as err {
            ; If there's an error launching PhraseExpander, log it but continue
            ; We don't show a message box to avoid interrupting the user
            OutputDebug("Error launching PhraseExpander: " err.Message)
        }
    }
}

; Set up timer to run at 6 AM daily
SetTimer(CheckTime, 59000)  ; Check every 59 seconds to see if it's 6 AM //! This is to prevent the script from running multiple times

CheckTime() {
    if (FormatTime(A_Now, 'HH:mm') = '06:00') {
        try {
            Run(A_ScriptDir "\update_all.ahk")
        } catch Error as e {
            MsgBox('Error running update_all: ' e.Message)
        }
    }
}

; Convert xss to Ctrl + Alt + Shift + Space
:*:xss::
{
    EnsurePhraseExpanderRunning()
    Send "^!+{Space}"
}

; Convert xzz to Ctrl + Alt + Shift + Space
:*:xzz::
{
    EnsurePhraseExpanderRunning()
    Send "^!+{Space}"
}
