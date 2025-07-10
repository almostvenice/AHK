#Requires AutoHotkey v2.0
#SingleInstance Force

if A_Args.Length < 1 {
    MsgBox "Please provide a webhook URL as an argument."
    ExitApp
}

webhookUrl := A_Args[1]

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Run the PowerShell script with the webhook URL
RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\call_webhook.ps1" -webhookUrl "' webhookUrl '"'

ExitApp
