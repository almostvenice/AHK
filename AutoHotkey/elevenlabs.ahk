#Requires AutoHotkey v2.0
; Standalone ElevenLabs v3 text-to-speech script.
; Same API and model (eleven_v3) as elevenlabs.ts / app ElevenLabsService.
;
; Usage:
;   elevenlabs.ahk "Text to speak"
;   elevenlabs.ahk "Text" --voice-id <id> --output speech.mp3
;   elevenlabs.ahk  (uses clipboard if no args)
;
; Config: .env in script dir with API_KEY and VOICE_ID (or parent .env)

#SingleInstance Force

BASE_URL := "https://api.elevenlabs.io/v1"
DEFAULT_MODEL_ID := "eleven_v4"
DEFAULT_VOICE_ID := ""
apiKey := ""
voiceID := ""

; ========== Configuration ==========
; Prefer .env in script dir, then parent (project root)
envFile := FileExist(A_ScriptDir "\.env") ? A_ScriptDir "\.env" : A_ScriptDir "\..\.env"
if FileExist(envFile) {
    Loop Read, envFile {
        if (RegExMatch(A_LoopReadLine, "^\s*#") || A_LoopReadLine = "")
            continue
        if RegExMatch(A_LoopReadLine, "i)^\s*API_KEY\s*=\s*([^#\s]+)", &m)
            apiKey := Trim(m[1])
        else if RegExMatch(A_LoopReadLine, "i)^\s*VITE_ELEVENLABS_API_KEY\s*=\s*([^#\s]+)", &m)
            apiKey := Trim(m[1])
        else if RegExMatch(A_LoopReadLine, "i)^\s*VOICE_ID\s*=\s*([^#\s]+)", &m)
            voiceID := Trim(m[1])
        else if RegExMatch(A_LoopReadLine, "i)^\s*VITE_ELEVENLABS_VOICE_ID\s*=\s*([^#\s]+)", &m)
            voiceID := Trim(m[1])
        else if RegExMatch(A_LoopReadLine, "i)^\s*ELEVENLABS_VOICE_ID\s*=\s*([^#\s]+)", &m)
            voiceID := Trim(m[1])
    }
}
; Env vars override .env
envVal := EnvGet("ELEVENLABS_API_KEY")
if (envVal = "")
    envVal := EnvGet("VITE_ELEVENLABS_API_KEY")
if (envVal != "")
    apiKey := envVal
envVal := EnvGet("ELEVENLABS_VOICE_ID")
if (envVal = "")
    envVal := EnvGet("VITE_ELEVENLABS_VOICE_ID")
if (envVal != "")
    voiceID := envVal

; ========== Parse args ==========
; text = first non-flag arg; --voice-id, --model-id, --output
text := ""
modelId := DEFAULT_MODEL_ID
customOutput := ""
args := A_Args
i := 1
while (i <= args.Length) {
    arg := args[i]
    if (arg = "--voice-id" && i < args.Length) {
        voiceID := args[++i]
    } else if (arg = "--model-id" && i < args.Length) {
        modelId := args[++i]
    } else if (arg = "--output" && i < args.Length) {
        customOutput := args[++i]
    } else if (SubStr(arg, 1, 2) != "--") {
        if (text = "")
            text := arg
        else
            text .= " " arg
    }
    i++
}

; No text: try clipboard
if (text = "")
    text := Trim(A_Clipboard)

if (text = "") {
    MsgBox "Usage: elevenlabs.ahk `"Text to speak`" [--voice-id <id>] [--model-id <id>] [--output file.mp3]`nOr set text in clipboard and run with no args."
    ExitApp 1
}

audioDir := A_ScriptDir "\audio"
csvFiles := [A_ScriptDir "\elevenlabsRecordings.csv", A_ScriptDir "\ElevenLabs\elevenlabsRecordings.csv"]
csvFile := csvFiles[1]
if !DirExist(audioDir)
    DirCreate(audioDir)
if !FileExist(csvFile)
    FileAppend("Text,Timestamp,AudioFile,Hash`n", csvFile)

text := NormalizeText(text)
if (existingFile := FindExistingAudio(text)) {
    SoundPlay(existingFile, 1)
    ExitApp
}

if (apiKey = "" || apiKey = "undefined" || apiKey = "null") {
    MsgBox "Error: API_KEY must be set in .env or ELEVENLABS_API_KEY / VITE_ELEVENLABS_API_KEY"
    ExitApp 1
}
if (voiceID = "" || voiceID = "undefined" || voiceID = "null") {
    MsgBox "Error: VOICE_ID must be set in .env or ELEVENLABS_VOICE_ID / VITE_ELEVENLABS_VOICE_ID (or --voice-id)"
    ExitApp 1
}

; ========== ElevenLabs v3 TTS ==========
NormalizeText(text) {
    text := Trim(text, " `t`r`n")
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    return text
}

GetMD5Hash(text) {
    text := NormalizeText(text)
    static MD5_CTX := Buffer(104, 0)
    DllCall("advapi32\MD5Init", "Ptr", MD5_CTX)
    DllCall("advapi32\MD5Update", "Ptr", MD5_CTX, "AStr", text, "UInt", StrLen(text))
    DllCall("advapi32\MD5Final", "Ptr", MD5_CTX)
    hash := ""
    Loop 16
        hash .= Format("{:02x}", NumGet(MD5_CTX, A_Index - 1, "UChar"))
    return hash
}

FindExistingAudio(text) {
    textHash := GetMD5Hash(text)
    for csv in csvFiles {
        if !FileExist(csv)
            continue
        Loop Read, csv {
            if (A_Index = 1)
                continue
            fields := StrSplit(A_LoopReadLine, ",")
            if (fields.Length >= 4 && fields[4] = textHash) {
                audioFile := fields[3]
                if FileExist(audioFile)
                    return audioFile
            }
        }
    }
    return ""
}

AddToCSV(text, audioFile, timestamp) {
    savedText := StrReplace(NormalizeText(text), ",", "&#44;")
    FileAppend(Format("{1},{2},{3},{4}`n", savedText, timestamp, audioFile, GetMD5Hash(text)), csvFile)
}

EscapeJson(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, "`"", "\`"")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`t", "\t")
    return s
}

url := BASE_URL "/text-to-speech/" voiceID
jsonText := EscapeJson(text)
; v3 body: text, model_id, voice_settings (stability, similarity_boost)
jsonBody := '{"text":"' jsonText '","model_id":"' modelId '","voice_settings":{"stability":0.5,"similarity_boost":0.75}}'

try {
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.Open("POST", url, false)
    http.SetRequestHeader("Content-Type", "application/json")
    http.SetRequestHeader("xi-api-key", apiKey)
    http.SetRequestHeader("Accept", "audio/mpeg")
    http.Send(jsonBody)

    if (http.Status != 200) {
        MsgBox "ElevenLabs API error: " http.Status "`n" SubStr(http.ResponseText, 1, 300)
        ExitApp 1
    }

    timestamp := FormatTime(A_Now, "yyyyMMddHHmmss")
    output := customOutput != "" ? customOutput : audioDir "\tts_" timestamp ".mp3"
    if FileExist(output)
        FileDelete(output)
    adoStream := ComObject("ADODB.Stream")
    adoStream.Type := 1
    adoStream.Open()
    adoStream.Write(http.ResponseBody)
    adoStream.SaveToFile(output, 2)  ; 2 = adSaveCreateOverwrite
    adoStream.Close()

    AddToCSV(text, output, timestamp)
    SoundPlay(output, 1)
} catch as err {
    MsgBox "Error: " err.Message
    ExitApp 1
}
