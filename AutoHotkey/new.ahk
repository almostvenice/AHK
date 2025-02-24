#Hotstring EndChars `n `t
Hotstring(":*:!new", (*) => TypeOut(":espanso"))

TypeOut(text) {
    for char in StrSplit(text) {
        Send(char)
        Sleep(50)  ; Adjust the delay between key presses (50ms per key)
    }
}
