#Requires AutoHotkey v2.0
#SingleInstance Force

; Play continuous tone to establish Bluetooth connection
Loop 3 {
    SoundPlay("*-1", 1)  ; Play default system sound multiple times
    Sleep(200)
}
Sleep(1000)  ; Full second to ensure connection is stable

; Play turnOFF audio and wait for completion
SoundPlay("TurnOFFProjector.mp3", 1)  ; 1 = wait for completion

ExitApp  ; Explicitly exit the script when done
