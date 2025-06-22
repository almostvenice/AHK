#Requires AutoHotkey v2.0
#SingleInstance Force

; Play silent audio to keep Bluetooth active
Loop 5 {
    SoundBeep(20, 50)  ; Very low frequency, barely audible
    Sleep(50)
}

; Play turnOFF audio and wait for completion
SoundPlay("TurnOFFProjector.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
