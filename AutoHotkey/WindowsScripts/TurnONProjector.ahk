#Requires AutoHotkey v2.0
#SingleInstance Force

; Small delay to ensure full audio capture
Sleep(2000)

; Play turnON audio and wait for completion
SoundPlay("TurnONProjector.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
