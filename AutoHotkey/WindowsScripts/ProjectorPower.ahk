#Requires AutoHotkey v2.0
#SingleInstance Force

; Play turnOFF audio and wait for completion
SoundPlay("TurnOFFProjectorPower.mp3", 1)  ; 1 = wait for completion

; Wait 5 seconds
Sleep(4000)

; Play turnON audio and wait for completion
SoundPlay("TurnONProjectorPower.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
