#Requires AutoHotkey v2.0

; Check if Vysor is running
if ProcessExist("Vysor.exe") {
    ; Close Vysor
    ProcessClose("Vysor.exe")
    ; Wait a moment for Vysor to fully close
    Sleep(2000)
}

; Start Vysor
Run("C:\Users\pyjoh\AppData\Local\vysor\Vysor.exe")
