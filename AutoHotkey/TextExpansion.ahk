#Requires AutoHotkey v2.0
#SingleInstance Force

; Convert xxz to Ctrl + Alt + Shift + Space
:*:xxs::
{
    Send "^!+{Space}"
}

;//! Convert xxz to Ctrl + Alt + Shift + Space
:*:xxz::
{
    Send "^!+{Space}"
}
