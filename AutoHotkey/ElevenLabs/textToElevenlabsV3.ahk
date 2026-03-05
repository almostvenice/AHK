#Requires AutoHotkey v2.0
; ElevenLabs TTS v3 – mirrors JS ElevenLabsService pattern.
; Config from .env / env. Errors logged to elevenlabsV3_errors.log in script dir (no fallback).
; Usage: include and call ElevenLabs_TextToSpeech({ text: "...", onAudioEnd: ()=> ... })
;        Or run script: speaks clipboard text.

; ========== Config (like ELEVENLABS_CONFIG in JS) ==========
ELEVENLABS_CONFIG := Map(
    "API_KEY", "",
    "DEFAULT_VOICE_ID", "",
    "BASE_URL", "https://api.elevenlabs.io/v1",
    "DEFAULT_MODEL_ID", "eleven_v3"
)

; Load from .env (script dir or parent or parent's parent)
_envFile := FileExist(A_ScriptDir "\.env") ? A_ScriptDir "\.env" : FileExist(A_ScriptDir "\..\.env") ? A_ScriptDir "\..\.env" : FileExist(A_ScriptDir "\..\..\.env") ? A_ScriptDir "\..\..\.env" : ""
if FileExist(_envFile) {
    Loop Read, _envFile {
        if (RegExMatch(A_LoopReadLine, "^\s*#") || A_LoopReadLine = "")
            continue
        if RegExMatch(A_LoopReadLine, "i)^\s*(API_KEY|VITE_ELEVENLABS_API_KEY)\s*=\s*([^#\s]+)", &m)
            ELEVENLABS_CONFIG["API_KEY"] := Trim(m[2])
        else if RegExMatch(A_LoopReadLine, "i)^\s*(VOICE_ID|VITE_ELEVENLABS_VOICE_ID|ELEVENLABS_VOICE_ID)\s*=\s*([^#\s]+)", &m)
            ELEVENLABS_CONFIG["DEFAULT_VOICE_ID"] := Trim(m[2])
    }
}
; Env vars override .env
v := EnvGet("ELEVENLABS_API_KEY")
if (v = "")
    v := EnvGet("VITE_ELEVENLABS_API_KEY")
if (v != "")
    ELEVENLABS_CONFIG["API_KEY"] := v
v := EnvGet("ELEVENLABS_VOICE_ID")
if (v = "")
    v := EnvGet("VITE_ELEVENLABS_VOICE_ID")
if (v != "")
    ELEVENLABS_CONFIG["DEFAULT_VOICE_ID"] := v

; ========== Helpers ==========
_EscapeJson(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, "`"", "\`"")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`t", "\t")
    return s
}

; Log error to file in script dir
_LogError(message) {
    logFile := A_ScriptDir "\elevenlabsV3_errors.log"
    line := "[" FormatTime(, "yyyy-MM-dd HH:mm:ss") "] " message "`n"
    try FileAppend(line, logFile, "UTF-8")
}

; ========== Main: TextToSpeech (same contract as JS ElevenLabsService.textToSpeech) ==========
; Args: object with keys:
;   text           – string to speak
;   voiceId        – optional (default from config)
;   modelId        – optional (default eleven_v3)
;   voice_settings – optional Map/object { stability: 0.5, similarity_boost: 0.75 }
;   onAudioEnd     – optional callback (no args) when playback finishes
ElevenLabs_TextToSpeech(args) {
    text := args.HasProp("text") ? args.text : ""
    voiceId := args.HasProp("voiceId") ? args.voiceId : ELEVENLABS_CONFIG["DEFAULT_VOICE_ID"]
    modelId := args.HasProp("modelId") ? args.modelId : ELEVENLABS_CONFIG["DEFAULT_MODEL_ID"]
    voice_settings := args.HasProp("voice_settings") ? args.voice_settings : Map("stability", 0.5, "similarity_boost", 0.75)
    onAudioEnd := args.HasProp("onAudioEnd") ? args.onAudioEnd : ""

    if (!text || Trim(text) = "") {
        if (Type(onAudioEnd) = "Func")
            onAudioEnd()
        return
    }

    apiKey := ELEVENLABS_CONFIG["API_KEY"]
    if (!apiKey || Trim(apiKey) = "" || apiKey = "undefined" || apiKey = "null") {
        _LogError("API_KEY missing or invalid")
        if (Type(onAudioEnd) = "Func")
            onAudioEnd()
        return
    }
    if (!voiceId || Trim(voiceId) = "" || voiceId = "undefined" || voiceId = "null") {
        _LogError("Voice ID missing or invalid")
        if (Type(onAudioEnd) = "Func")
            onAudioEnd()
        return
    }

    url := ELEVENLABS_CONFIG["BASE_URL"] "/text-to-speech/" voiceId
    stability := 0.5
    similarity_boost := 0.75
    if voice_settings is Map {
        if voice_settings.Has("stability")
            stability := voice_settings["stability"]
        if voice_settings.Has("similarity_boost")
            similarity_boost := voice_settings["similarity_boost"]
    } else if IsObject(voice_settings) {
        if voice_settings.HasProp("stability")
            stability := voice_settings.stability
        if voice_settings.HasProp("similarity_boost")
            similarity_boost := voice_settings.similarity_boost
    }
    jsonText := _EscapeJson(text)
    jsonBody := '{"text":"' jsonText '","model_id":"' modelId '","voice_settings":{"stability":' stability ',"similarity_boost":' similarity_boost '}}'

    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", url, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.SetRequestHeader("xi-api-key", apiKey)
        http.SetRequestHeader("Accept", "audio/mpeg")
        http.Send(jsonBody)

        if (http.Status != 200) {
            _LogError("ElevenLabs API HTTP " http.Status ": " SubStr(http.ResponseText, 1, 500))
            if (Type(onAudioEnd) = "Func")
                onAudioEnd()
            return
        }

        ; Save to temp file and play (blocking), then callback
        dir := A_ScriptDir "\audio"
        if !DirExist(dir)
            DirCreate(dir)
        tmpFile := dir "\tts_v3_" A_TickCount ".mp3"
        if FileExist(tmpFile)
            FileDelete(tmpFile)
        adoStream := ComObject("ADODB.Stream")
        adoStream.Type := 1
        adoStream.Open()
        adoStream.Write(http.ResponseBody)
        adoStream.SaveToFile(tmpFile, 2)
        adoStream.Close()

        SoundPlay(tmpFile, 1)  ; 1 = wait until finished
        try FileDelete(tmpFile)
        if (Type(onAudioEnd) = "Func")
            onAudioEnd()
    } catch as err {
        _LogError("Exception: " err.Message)
        if (Type(onAudioEnd) = "Func")
            onAudioEnd()
    }
}

; ========== Run when executed as script (speak clipboard) ==========
if (A_ScriptFullPath = A_LineFile) {
    #SingleInstance Force
    Persistent
    text := Trim(A_Clipboard)
    if (text = "") {
        MsgBox "Clipboard is empty. Copy some text and run again.", "ElevenLabs TTS v3", "Icon!"
        ExitApp
    }
    ElevenLabs_TextToSpeech({
        text: text,
        onAudioEnd: () => (ToolTip("Done"), SetTimer(() => ToolTip(), -2000))
    })
}
