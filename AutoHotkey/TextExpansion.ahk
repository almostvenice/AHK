#Requires AutoHotkey v2.0
#SingleInstance Force

; Convert xxz to Ctrl + Alt + Shift + Space
:*:xss::
{
    Send "^!+{Space}"
}

;//! Convert xxz to Ctrl + Alt + Shift + Space
:*:xzz::
{
    Send "^!+{Space}"
}
