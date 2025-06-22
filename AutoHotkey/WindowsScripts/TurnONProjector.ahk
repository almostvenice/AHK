#Requires AutoHotkey v2.0
#SingleInstance Force

; Play continuous tone to establish Bluetooth connection
SoundPlay("*-1", 1)  ; Play default system sound
Sleep(500)  ; Give time for Bluetooth to connect

; Play turnON audio and wait for completion
SoundPlay("TurnONProjector.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
