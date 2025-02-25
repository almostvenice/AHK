#Requires AutoHotkey v2.0

:*:xx::{
    A_Clipboard := ""  ; Clear clipboard
    Send("^+{Left 10}")  ; Select last 10 characters
    Sleep(500)
    Send("^c")  ; Copy selection
    ClipWait(1)

    prevText := Trim(A_Clipboard)

    if (prevText != "") {
        ; Split the clipboard content by spaces and keep the last word
        words := StrSplit(prevText, " ")
        lastWord := words[words.MaxIndex()]  ; Get the last word

        if (lastWord != "") {
            ; Send each character one by one with 1 second delay
            for char in StrSplit(lastWord) {
                Send(char)  ; Send one character
                Sleep(1000)  ; Wait 1 second between characters
            }
        }
    }
}
