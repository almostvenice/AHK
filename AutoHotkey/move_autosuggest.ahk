#Requires AutoHotkey v2.0
#SingleInstance Force

; Create a tiny GUI to keep the script running
persistentGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
persistentGui.BackColor := "FFFFFF"  ; White background
persistentGui.Show("w1 h1 x0 y0")  ; Show as a tiny 1x1 pixel window

; Define Windows event constants
EVENT_SYSTEM_FOREGROUND := 0x0003
EVENT_OBJECT_SHOW := 0x8002
EVENT_OBJECT_LOCATIONCHANGE := 0x800B

; Set up window event hooks
windowMoveHook := SetWinEventHook(EVENT_OBJECT_LOCATIONCHANGE)
windowShowHook := SetWinEventHook(EVENT_OBJECT_SHOW)
windowForegroundHook := SetWinEventHook(EVENT_SYSTEM_FOREGROUND)

; Clean up hooks when script exits
OnExit(Cleanup)

Cleanup(*) {
    global windowMoveHook, windowShowHook, windowForegroundHook
    DllCall("UnhookWinEvent", "Ptr", windowMoveHook)
    DllCall("UnhookWinEvent", "Ptr", windowShowHook)
    DllCall("UnhookWinEvent", "Ptr", windowForegroundHook)
}

HandleWindowEvent(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    static lastMoveTime := 0
    
    if !hwnd  ; Ignore null windows
        return
        
    try {
        processName := WinGetProcessName("ahk_id " hwnd)
        windowTitle := WinGetTitle("ahk_id " hwnd)
    } catch {
        return  ; Window was destroyed before we could get its info
    }
    
    if processName != "PhraseExpander.exe"
        return
    
    if !InStr(windowTitle, "Autosuggest")
        return
        
    ; Throttle moves to prevent fighting with PhraseExpander
    currentTime := A_TickCount
    if (currentTime - lastMoveTime < 100)  ; Don't move more often than every 100ms
        return
    lastMoveTime := currentTime
        
    ; Get the current window position and size
    try {
        WinGetPos(&x, &y, &width, &height, "ahk_id " hwnd)
        
        ; Get the primary monitor's work area (excludes taskbar)
        MonitorGetWorkArea(MonitorGetPrimary(), &monitorLeft, &monitorTop, &monitorRight, &monitorBottom)
        
        ; Calculate new position (centered horizontally at the top of the screen with a small margin)
        newX := (monitorRight - monitorLeft - width) / 1.1 + monitorLeft ; 4.5Left, 2Center, 1.3Right
        newY := monitorTop + 150  ; 100 pixel margin from top
        
        ; Only move if position has changed significantly
        if (Abs(x - newX) > 10 || Abs(y - newY) > 10) {
            ; Move the window and force it to stay there
            WinMove(newX, newY, , , "ahk_id " hwnd)
            Sleep(10)  ; Small delay to let the window settle
            WinMove(newX, newY, , , "ahk_id " hwnd)  ; Move again to ensure position
        }
    } catch {
        return  ; Window manipulation failed
    }
}

SetWinEventHook(event) {
    callback := CallbackCreate(HandleWindowEvent)
    hook := DllCall("SetWinEventHook"
        , "UInt", event  ; eventMin
        , "UInt", event  ; eventMax
        , "Ptr", 0  ; hmodWinEventProc
        , "Ptr", callback  ; lpfnWinEventProc
        , "UInt", 0  ; idProcess
        , "UInt", 0  ; idThread
        , "UInt", 0x0002 | 0x0000)  ; WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
    
    if !hook {
        return 0
    }
    
    return hook
}
