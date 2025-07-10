#Requires AutoHotkey v2.0
#SingleInstance Force

; Hide any command windows that appear
DllCall("AllocConsole")
WinHide "ahk_class ConsoleWindowClass"

; Then turn off bedroom lights
RunWait 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' A_ScriptDir '\call_webhook.ps1" -webhookUrl "http://192.168.4.219:8123/api/webhook/turn_off_ceiling_fan_light"'

ExitApp
