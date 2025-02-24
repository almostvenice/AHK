#Hotstring EndChars `n `t
Hotstring(":*:!upd", (*) => RunUpdateScript())

RunUpdateScript() {
    scriptPath := A_ScriptDir "\update_all.ahk"  ; Get the path of update_all.ahk in the same folder
    if FileExist(scriptPath) {
        Run(A_AhkPath ' "' scriptPath '"')  ; Run the script using AutoHotkey v2
    } else {
        MsgBox("update_all.ahk not found!", "Error", 48)
    }
}
