#Requires AutoHotkey v2.0
#SingleInstance Force

; Read environment variables from .env file
envFile := A_ScriptDir "\..\\.env"
apiKey := ""
voiceID := ""

if FileExist(envFile) {
    Loop Read, envFile {
        ; Skip comments and empty lines
        if (RegExMatch(A_LoopReadLine, "^\s*#") || A_LoopReadLine = "")
            continue
            
        ; Match "KEY = VALUE" pattern, ignoring spaces and comments
        if RegExMatch(A_LoopReadLine, "^API_KEY\s*=\s*([^#\s]+)", &match)
            apiKey := match[1]
        else if RegExMatch(A_LoopReadLine, "^VOICE_ID\s*=\s*([^#\s]+)", &match)
            voiceID := match[1]
    }
    
    ; ; Show debug message with loaded values
    ; MsgBox Format("Loaded environment variables:`nAPI Key: {1}`nVoice ID: {2}", 
    ;     SubStr(apiKey, 1, 8) "..." SubStr(apiKey, -8),  ; Show first 8 and last 8 chars of API key
    ;     voiceID)
}

if (apiKey = "" || voiceID = "") {
    MsgBox "Error: API_KEY and VOICE_ID must be set in .env file"
    ExitApp
}

global lastAudioFile := ""  ; Track the last played audio file
maxAudioFiles := 100  ; Maximum number of audio files to keep

; Create audio directory if it doesn't exist
audioDir := A_ScriptDir "\audio"
if !DirExist(audioDir)
    DirCreate(audioDir)

; CSV file for tracking recordings
csvFile := A_ScriptDir "\elevenlabsRecordings.csv"
if !FileExist(csvFile) {
    ; Create CSV with headers if it doesn't exist
    FileAppend("Text,Timestamp,AudioFile,Hash`n", csvFile)
}

; Function to normalize text for consistent comparison
NormalizeText(text) {
    ; Trim whitespace and normalize line endings
    text := Trim(text, " `t`r`n")
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    return text
}

; Function to get MD5 hash of text (for comparison)
GetMD5Hash(text) {
    ; Normalize text before hashing
    text := NormalizeText(text)
    
    static MD5_CTX := Buffer(104, 0)
    static MD5_DIGEST := Buffer(16, 0)
    DllCall("advapi32\MD5Init", "Ptr", MD5_CTX)
    DllCall("advapi32\MD5Update", "Ptr", MD5_CTX, "AStr", text, "UInt", StrLen(text))
    DllCall("advapi32\MD5Final", "Ptr", MD5_CTX)
    hash := ""
    Loop 16
        hash .= Format("{:02x}", NumGet(MD5_CTX, A_Index - 1, "UChar"))
    return hash
}

; Function to find existing audio file for text
FindExistingAudio(text) {
    textHash := GetMD5Hash(text)
    if !FileExist(csvFile)
        return ""
        
    ; Read CSV and look for matching hash
    Loop Read, csvFile {
        if (A_Index = 1)  ; Skip header
            continue
        fields := StrSplit(A_LoopReadLine, ",")
        if (fields.Length >= 4 && fields[4] = textHash) {
            audioFile := fields[3]
            if FileExist(audioFile)
                return audioFile
        }
    }
    return ""
}

; Function to add new recording to CSV
AddToCSV(text, audioFile, timestamp) {
    ; Normalize text before saving
    text := NormalizeText(text)
    textHash := GetMD5Hash(text)
    
    ; Escape any remaining commas in text for CSV
    text := StrReplace(text, ",", "&#44;")
    
    FileAppend(Format("{1},{2},{3},{4}`n", 
        text,  ; Already normalized
        timestamp,
        audioFile,
        textHash
    ), csvFile)
}

; Clean up old audio files, keeping only the most recent ones
CleanupAudioFiles() {
    global audioDir, maxAudioFiles, lastAudioFile
    audioFiles := []
    
    ; Get all MP3 files and their modification times
    Loop Files, audioDir "\*.mp3" {
        audioFiles.Push({ path: A_LoopFileFullPath, time: FileGetTime(A_LoopFileFullPath, "M") })
    }
    
    ; Sort by modification time (newest first)
    audioFiles := SortByTime(audioFiles)
    
    ; Delete older files beyond the limit
    if (audioFiles.Length > maxAudioFiles) {
        Loop audioFiles.Length - maxAudioFiles {
            FileDelete(audioFiles[maxAudioFiles + A_Index].path)
        }
    }
    
    ; Update lastAudioFile if it's not set
    if (!lastAudioFile && audioFiles.Length > 0) {
        lastAudioFile := audioFiles[1].path
    }
}

; Helper function to sort files by time
SortByTime(files) {
    sorted := []
    for file in files
        sorted.Push(file)
    
    ; Bubble sort implementation (simple but effective for small arrays)
    n := sorted.Length
    Loop n {
        i := 1
        Loop n - A_Index {
            if (sorted[i].time < sorted[i + 1].time) {
                temp := sorted[i]
                sorted[i] := sorted[i + 1]
                sorted[i + 1] := temp
            }
            i++
        }
    }
    return sorted
}

; Create debug GUI with dark mode
debugGui := Gui("+AlwaysOnTop", "ElevenLabs TTS Debug")
debugGui.BackColor := "0x2D2D2D"  ; Dark background
debugGui.SetFont("s10 cWhite", "Segoe UI")

; Add controls with dark mode colors
debugGui.Add("Text",, "Status:").Opt("Background" . debugGui.BackColor)
statusText := debugGui.Add("Text", "w400 h20", "Starting...")
statusText.Opt("Background" . debugGui.BackColor)

debugGui.Add("Text",, "Last Request:").Opt("Background" . debugGui.BackColor)
requestText := debugGui.Add("Edit", "r4 w400 ReadOnly -E0x200", "")  ; -E0x200 removes white background
requestText.Opt("+Background0x3D3D3D")  ; Slightly lighter than background
requestText.SetFont("cWhite")

debugGui.Add("Text",, "Last Response:").Opt("Background" . debugGui.BackColor)
responseText := debugGui.Add("Edit", "r4 w400 ReadOnly -E0x200", "")
responseText.Opt("+Background0x3D3D3D")
responseText.SetFont("cWhite")

; Add buttons with dark styling
processBtn := debugGui.Add("Button", "x10 y+10 w100 h30", "Process Text")
processBtn.OnEvent("Click", ProcessTTS)
processBtn.Opt("+Background0x4D4D4D")  ; Dark button color
processBtn.SetFont("cWhite")

replayBtn := debugGui.Add("Button", "x+10 w100 h30", "Replay (ALT+S)")
replayBtn.OnEvent("Click", ReplayAudio)
replayBtn.Opt("+Background0x4D4D4D")
replayBtn.SetFont("cWhite")

; Add button for exiting
exitBtn := debugGui.Add("Button", "x+10 w100 h30", "Exit (ALT+E)")
exitBtn.OnEvent("Click", (*) => ExitApp())
exitBtn.Opt("+Background0x4D4D4D")
exitBtn.SetFont("cWhite")

debugGui.Show()

; Main function to process text-to-speech
ProcessTTS(*) {
    text := A_Clipboard  ; Get text from clipboard
    if (StrLen(Trim(text)) = 0) {
        statusText.Value := "Error: Clipboard is empty!"
        return
    }
    
    ; Normalize text early
    text := NormalizeText(text)
    
    statusText.Value := "Checking for existing audio..."
    
    ; Check if we already have this text
    if (existingFile := FindExistingAudio(text)) {
        statusText.Value := "Found existing audio, playing..."
        global lastAudioFile := existingFile
        SoundPlay(existingFile)
        responseText.Value := "Using cached audio file:`n" existingFile
        statusText.Value := "Done! Ready for next request."
        return
    }
    
    statusText.Value := "Preparing request..."
    url := Format("https://api.elevenlabs.io/v1/text-to-speech/{1}", voiceID)
    
    ; Properly escape the text for JSON
    jsonText := StrReplace(text, "\", "\\")
    jsonText := StrReplace(jsonText, "`"", "\`"")
    jsonText := StrReplace(jsonText, "`n", "\n")
    jsonText := StrReplace(jsonText, "`t", "\t")
    
    jsonData := "{`"text`":`"" jsonText "`"}"
    requestText.Value := "URL: " url "`nData: " jsonData
    
    ; Call ElevenLabs API
    timestamp := FormatTime(A_Now, "yyyyMMddHHmmss")
    tempFile := audioDir "\tts_" timestamp ".mp3"  ; Use formatted timestamp
    try {
        statusText.Value := "Sending request to ElevenLabs..."
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", url, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.SetRequestHeader("xi-api-key", apiKey)
        http.Send(jsonData)
        
        if (http.Status != 200) {
            statusText.Value := "Error: API request failed!"
            responseText.Value := "Status: " http.Status "`nResponse: " http.ResponseText
            return
        }
        
        ; Save audio file
        statusText.Value := "Saving audio file..."
        if FileExist(tempFile)
            FileDelete(tempFile)
            
        ; Get response as ADO Stream
        adoStream := ComObject("ADODB.Stream")
        adoStream.Type := 1  ; Binary
        adoStream.Open()
        adoStream.Write(http.ResponseBody)
        adoStream.SaveToFile(tempFile)
        adoStream.Close()
        
        ; Add to CSV and play the audio
        AddToCSV(text, tempFile, timestamp)  ; Pass the same timestamp
        
        statusText.Value := "Playing audio..."
        responseText.Value := "Success! Audio file saved to:`n" tempFile
        global lastAudioFile := tempFile
        SoundPlay(tempFile)
        statusText.Value := "Done! Ready for next request."
    } catch as err {
        statusText.Value := "Error: " err.Message
        responseText.Value := "Exception details:`n" err.Message
    }
}

; Function to replay last audio file
ReplayAudio(*) {
    global lastAudioFile
    if (lastAudioFile && FileExist(lastAudioFile)) {
        statusText.Value := "Replaying last audio..."
        SoundPlay(lastAudioFile)
        statusText.Value := "Done! Ready for next request."
    } else {
        statusText.Value := "No audio file available to replay!"
        responseText.Value := "Last audio file: " lastAudioFile "`nExists: " (FileExist(lastAudioFile) ? "Yes" : "No")
    }
}

; Hotkeys
!s::ReplayAudio()  ; Alt + S to replay
!e::ExitApp  ; Alt + E to exit

; Run the process immediately when script starts
ProcessTTS()

Persistent  ; Keep script running
