#Requires AutoHotkey v2.0
#SingleInstance Force

; Play turnOFF audio and wait for completion
SoundPlay("TurnOFFProjector.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
