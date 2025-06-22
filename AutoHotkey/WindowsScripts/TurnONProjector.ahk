#Requires AutoHotkey v2.0
#SingleInstance Force

; Initialize sound system with a silent beep
SoundBeep(60, 1)
Sleep(100)

; Longer delay to ensure system is ready
Sleep(3000)

; Play turnON audio and wait for completion
SoundPlay("TurnONProjector.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
