#SingleInstance Force
#Requires AutoHotkey v2.0

; Get screen dimensions and calculate sizes
screenWidth := A_ScreenWidth
screenHeight := A_ScreenHeight
halfHeight := Floor(screenHeight / 2)  ; Ensure we get a clean integer division

; Initialize the GUI with specific options
MainGui := Gui("+AlwaysOnTop +Border")
MainGui.Title := "Window Manager"

; Set initial window position and size
MainGui.Move(0, 0, screenWidth, halfHeight)

; Add controls info text
MainGui.SetFont("s18 bold")  ; Set larger, bold font for controls text
MainGui.Add("Text", "h120", "Enter - Activate Window`nShift+Enter - Close Window`nCtrl+R - Refresh List`n")


; Set font for ListView
MainGui.SetFont("s16")  ; Slightly smaller than controls text, but still larger than default
LV := MainGui.Add("ListView", "w" screenWidth - 20 " h" halfHeight - 600, ["#", "Open", "Close", "Window Title", "Process Name", "Window ID"])

; Set font back to normal for buttons
MainGui.SetFont("s10")
MainGui.Add("Button", , "Refresh List").OnEvent("Click", RefreshList)
MainGui.Add("Button", "x+10", "Activate Selected").OnEvent("Click", ActivateSelected)
MainGui.Add("Button", "x+10", "Close Selected").OnEvent("Click", CloseSelected)

; Show the GUI
MainGui.Show("x0 y0")

; Initial population of the list
RefreshList()

; Add hotkeys
#HotIf WinActive("Window Manager")
Enter::
{
    ActivateSelected()
}
+Enter::CloseSelected()  ; Shift+Enter
^r::RefreshList()       ; Ctrl+R

; Quick activation hotkeys (Alt + 1-9) for 1-9
!1::ActivateByNumber(1)
!2::ActivateByNumber(2)
!3::ActivateByNumber(3)
!4::ActivateByNumber(4)
!5::ActivateByNumber(5)
!6::ActivateByNumber(6)
!7::ActivateByNumber(7)
!8::ActivateByNumber(8)
!9::ActivateByNumber(9)

; Quick activation hotkeys (Shift + 1-9) for 10-18
+1::ActivateByNumber(10)
+2::ActivateByNumber(11)
+3::ActivateByNumber(12)
+4::ActivateByNumber(13)
+5::ActivateByNumber(14)
+6::ActivateByNumber(15)
+7::ActivateByNumber(16)
+8::ActivateByNumber(17)
+9::ActivateByNumber(18)

; Quick close hotkeys (Ctrl + 1-9) for 1-9
^1::CloseByNumber(1)
^2::CloseByNumber(2)
^3::CloseByNumber(3)
^4::CloseByNumber(4)
^5::CloseByNumber(5)
^6::CloseByNumber(6)
^7::CloseByNumber(7)
^8::CloseByNumber(8)
^9::CloseByNumber(9)

; Quick close hotkeys (Ctrl + Shift + 1-9) for 10-18
^+1::CloseByNumber(10)
^+2::CloseByNumber(11)
^+3::CloseByNumber(12)
^+4::CloseByNumber(13)
^+5::CloseByNumber(14)
^+6::CloseByNumber(15)
^+7::CloseByNumber(16)
^+8::CloseByNumber(17)
^+9::CloseByNumber(18)
#HotIf

RefreshList(*) {
    LV.Delete()
    windows := WinGetList()
    rowNum := 1
    for winId in windows {
        title := WinGetTitle(winId)
        procName := WinGetProcessName(winId)
        if (title != "") { ; Only add windows with titles
            if (rowNum <= 9) {
                openShortcut := "Alt+" . rowNum
                closeShortcut := "Ctrl+" . rowNum
            } else if (rowNum <= 18) {
                openShortcut := "Shift+" . (rowNum - 9)
                closeShortcut := "Ctrl+Shift+" . (rowNum - 9)
            } else {
                openShortcut := "-"
                closeShortcut := "-"
            }
            LV.Add(, rowNum++, openShortcut, closeShortcut, title, procName, "ahk_id " . winId)
        }
    }
    Loop LV.GetCount("Col")
        LV.ModifyCol(A_Index, "AutoHdr")
}

ActivateSelected(*) {
    if (row := LV.GetNext()) {
        winId := LV.GetText(row, 6)
        try {
            WinActivate(winId)
            MainGui.Hide()  ; Hide the GUI after activating a window
        } catch as err {
            MsgBox("Could not activate window: " . err.Message)
        }
    }
}

CloseSelected(*) {
    if (row := LV.GetNext()) {
        winId := LV.GetText(row, 6)
        try {
            WinClose(winId)
            RefreshList()
        } catch as err {
            MsgBox("Could not close window: " . err.Message)
        }
    }
}

ActivateByNumber(num) {
    if (num <= LV.GetCount()) {
        winId := LV.GetText(num, 6)
        try {
            WinActivate(winId)
            MainGui.Hide()  ; Hide the GUI after activating a window by number
        } catch as err {
            MsgBox("Could not activate window: " . err.Message)
        }
    }
}

CloseByNumber(num) {
    if (num <= LV.GetCount()) {
        winId := LV.GetText(num, 6)
        try {
            WinClose(winId)
            RefreshList()
        } catch as err {
            MsgBox("Could not close window: " . err.Message)
        }
    }
}

MainGui.OnEvent("Close", (*) => ExitApp())
