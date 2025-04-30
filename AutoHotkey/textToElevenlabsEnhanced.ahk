#Requires AutoHotkey v2.0
#SingleInstance Force

; ========== Configuration and Setup ==========
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
}

if (apiKey = "" || voiceID = "") {
    MsgBox "Error: API_KEY and VOICE_ID must be set in .env file"
    ExitApp
}

; ========== Global Variables ==========
; History tracking (circular buffer of 5 items)
InitAudioHistory() {
    history := {}
    history.items := []
    history.currentIndex := 0
    history.maxItems := 5

    ; Load history from CSV if it exists
    if FileExist(csvFile) {
        entries := []
        Loop Read, csvFile {
            if (A_Index = 1)  ; Skip header
                continue
                
            fields := StrSplit(A_LoopReadLine, ",")
            if (fields.Length >= 6 && FileExist(fields[3])) {
                entries.Push({ file: fields[3], text: fields[1], lastPlayed: fields[6] ? fields[6] : fields[2] })
            }
        }
        
        ; Sort by LastPlayed timestamp (newest first)
        sortedEntries := []
        for entry in entries
            sortedEntries.Push(entry)
            
        ; Bubble sort (newest first)
        Loop sortedEntries.Length {
            i := A_Index
            Loop sortedEntries.Length - i {
                j := A_Index
                if (sortedEntries[j].lastPlayed < sortedEntries[j + 1].lastPlayed) {
                    temp := sortedEntries[j]
                    sortedEntries[j] := sortedEntries[j + 1]
                    sortedEntries[j + 1] := temp
                }
            }
        }
        
        ; Take up to maxItems entries
        Loop Min(sortedEntries.Length, history.maxItems) {
            history.items.Push({ file: sortedEntries[A_Index].file, text: sortedEntries[A_Index].text })
        }
        
        if (history.items.Length > 0)
            history.currentIndex := 1
            
        AddDebug("Loaded " history.items.Length " items from CSV")
    }
    
    return history
}

; Add new item to history
HistoryPush(history, audioFile, text) {
    ; Create new array with new item at start
    newItems := []
    newItems.Push({ file: audioFile, text: text })
    
    ; Add existing items, avoiding duplicates
    for item in history.items {
        if (newItems.Length < history.maxItems && item.file != audioFile)
            newItems.Push(item)
    }
    
    ; Update history
    history.items := newItems
    history.currentIndex := 1
    
    AddDebug("Added item to history. Total items: " history.items.Length)
    for i, item in history.items
        AddDebug("History item " i ": " item.text)
}

; Navigate through history
HistoryNext(history) {
    if (history.items.Length = 0)
        return false
        
    history.currentIndex := Mod(history.currentIndex, history.items.Length) + 1
    AddDebug("Moving to next item: " history.currentIndex " - " history.items[history.currentIndex].text)
    return history.items[history.currentIndex]
}

HistoryPrevious(history) {
    if (history.items.Length = 0)
        return false
        
    history.currentIndex := history.currentIndex = 1 ? history.items.Length : history.currentIndex - 1
    AddDebug("Moving to previous item: " history.currentIndex " - " history.items[history.currentIndex].text)
    return history.items[history.currentIndex]
}

HistoryCurrent(history) {
    if (history.items.Length = 0)
        return false
        
    if (history.currentIndex < 1 || history.currentIndex > history.items.Length) {
        history.currentIndex := 1
        AddDebug("Reset current index to 1")
    }
    
    AddDebug("Current item: " history.currentIndex " - " history.items[history.currentIndex].text)
    return history.items[history.currentIndex]
}

; ========== GUI Creation ==========
; Create main GUI window
global mainGui := Gui("+Resize +MinSize400x500")
mainGui.Title := "Enhanced Text-to-Speech"
mainGui.BackColor := "0x2D2D2D"  ; Dark theme

; Create debug window
global debugGui := Gui("+AlwaysOnTop +Resize")
debugGui.Title := "Debug Information"
debugGui.BackColor := "0x2D2D2D"

; Add debug log
global debugLog := debugGui.Add("Edit", "x10 y10 w600 h400 ReadOnly -E0x200", "")
debugLog.SetFont("s10 cWhite")
debugLog.Opt("+Background0x3D3D3D")

; Show debug window
debugGui.Show("w620 h420")

; Initialize global variables
global lastAudioFile := ""
global currentSequenceId := ""
global audioHistory := ""

; CSV file for tracking recordings
global csvFile := A_ScriptDir "\elevenlabsRecordings.csv"
if !FileExist(csvFile)
    FileAppend("Text,Timestamp,AudioFile,Hash,SequenceId,LastPlayed`n", csvFile)

; Initialize audio history
audioHistory := InitAudioHistory()

; ========== Directory Setup ==========
; Create required directories
audioDir := A_ScriptDir "\audio"
cacheDir := audioDir "\cache"
for dir in [audioDir, cacheDir]
    if !DirExist(dir)
        DirCreate(dir)



; ========== Utility Functions ==========
; Normalize text for consistent comparison
NormalizeText(text) {
    text := Trim(text, " `t`r`n")
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    return text
}

; Get filename from path
FileGetName(path) {
    SplitPath(path, &name)
    return name
}

; Generate MD5 hash for text comparison
GetMD5Hash(text) {
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

; ========== Cache Management ==========
; Update cache with current audio file
UpdateCache(audioFile) {
    if !FileExist(audioFile) {
        AddDebug("ERROR: Source audio file does not exist: " audioFile)
        return false
    }

    AddDebug("Source audio file exists: " audioFile)
    AddDebug("Source file size: " FileGetSize(audioFile) " bytes")

    ; Clear existing cache
    AddDebug("Clearing cache directory: " cacheDir)
    Loop Files, cacheDir "\*.*" {
        AddDebug("Deleting cached file: " A_LoopFileFullPath)
        FileDelete(A_LoopFileFullPath)
    }
    
    ; Copy file to cache
    cachePath := cacheDir "\" FileGetName(audioFile)
    AddDebug("Attempting to copy to cache: " cachePath)
    try {
        FileCopy(audioFile, cachePath, 1)  ; 1 = overwrite if exists
        if FileExist(cachePath) {
            AddDebug("Successfully copied to cache. Size: " FileGetSize(cachePath) " bytes")
            return true
        } else {
            AddDebug("ERROR: Failed to copy to cache - file doesn't exist after copy")
            return false
        }
    } catch as err {
        AddDebug("ERROR: Failed to copy to cache - " err.Message)
        return false
    }
}

; ========== Audio File Management ==========
; Find existing audio for text
FindExistingAudio(text) {
    textHash := GetMD5Hash(text)
    if !FileExist(csvFile)
        return Map("file", "", "sequenceId", "")
        
    ; Read CSV and look for matching hash
    Loop Read, csvFile {
        if (A_Index = 1)  ; Skip header
            continue
        fields := StrSplit(A_LoopReadLine, ",")
        if (fields.Length >= 5 && fields[4] = textHash) {
            audioFile := fields[3]
            if FileExist(audioFile)
                return Map("file", audioFile, "sequenceId", fields[5])
        }
    }
    return Map("file", "", "sequenceId", "")
}

; Add new recording to CSV
AddToCSV(text, audioFile, timestamp, sequenceId) {
    text := NormalizeText(text)
    textHash := GetMD5Hash(text)
    
    ; Escape commas for CSV
    text := StrReplace(text, ",", "&#44;")
    
    FileAppend(Format("{1},{2},{3},{4},{5},{6}`n", 
        text,
        timestamp,
        audioFile,
        textHash,
        sequenceId,
        ""  ; Initial LastPlayed is empty
    ), csvFile)
}

; ========== Sequence Navigation ==========
; Find next/previous audio in sequence
FindSequenceAudio(sequenceId, direction) {
    if (sequenceId = "")
        return ""
        
    currentFound := false
    previousFile := ""
    nextFile := ""
    
    Loop Read, csvFile {
        if (A_Index = 1)  ; Skip header
            continue
            
        fields := StrSplit(A_LoopReadLine, ",")
        if (fields.Length < 5)
            continue
            
        if (fields[5] = sequenceId) {
            if (currentFound) {
                nextFile := fields[3]
                if (direction = "next")
                    break
            } else if (fields[3] = lastAudioFile) {
                currentFound := true
                if (direction = "prev" && previousFile)
                    return previousFile
            }
            previousFile := fields[3]
        }
    }
    
    return direction = "next" ? nextFile : previousFile
}



; Function to add debug message
AddDebug(msg) {
    global debugLog
    debugLog.Value := FormatTime(, "[HH:mm:ss] ") msg "`n" debugLog.Value
}

; Status area
statusText := mainGui.Add("Text", "x10 y10 w380", "Ready")
statusText.SetFont("s10 cWhite")
statusText.Opt("+Background" . mainGui.BackColor)

; Current text display
mainGui.Add("Text", "x10 y+10 w380", "Current Text:").SetFont("cWhite")
currentText := mainGui.Add("Edit", "x10 y+10 w380 h60 vCurrentText", "")
currentText.SetFont("s10")
currentText.Opt("+Background0x3D3D3D cWhite")

; Add hotkeys
!e::
{
    global currentText
    currentText.Focus()
    statusText.Value := "Ready to edit. Press Alt+S to send to ElevenLabs."
}

!s::
{
    global currentText
    text := currentText.Value
    if (StrLen(Trim(text)) = 0) {
        statusText.Value := "Error: No text to send!"
        return
    }
    A_Clipboard := text  ; Set clipboard to current text
    ProcessTTS()  ; Process the text
}

; History list
mainGui.Add("Text", "x10 y+10 w380", "History:").SetFont("cWhite")
historyList := mainGui.Add("ListBox", "x10 y+5 w380 h200", [])
historyList.SetFont("s10")
historyList.Opt("+Background0x3D3D3D cWhite")
historyList.OnEvent("DoubleClick", PlaySelectedHistory)

; Response area
mainGui.Add("Text", "x10 y+10 w380", "API Response:").SetFont("cWhite")
responseText := mainGui.Add("Edit", "x10 y+5 w380 h60 ReadOnly -E0x200", "")
responseText.SetFont("s10")
responseText.Opt("+Background0x3D3D3D cWhite")

; Button row
btnY := "y+10"
CreateStyledButton(text, x, handler) {
    btn := mainGui.Add("Button", x " " btnY " w90 h30", text)
    btn.OnEvent("Click", handler)
    btn.Opt("+Background0x4D4D4D")
    btn.SetFont("cWhite")
    return btn
}

CreateStyledButton("Play (Enter)", "x10", PlayCurrentAudio)
CreateStyledButton("Open Cache (Alt+Space)", "x+10", OpenCache)
CreateStyledButton("Copy File (Alt+C)", "x+10", CopyAudioFile)
CreateStyledButton("Recent", "x+10", ShowRecentlyPlayed)

; Show the window
mainGui.Show("w400")

; ========== Main Functions ==========
; Process text-to-speech request
ProcessTTS(*) {
    global lastAudioFile  ; Ensure we can modify the global variable
    AddDebug("Starting ProcessTTS")
    text := A_Clipboard  ; Get text from clipboard
    AddDebug("Clipboard text length: " StrLen(text))
    
    ; Clear the cache directory first
    Loop Files, cacheDir "\*.*"
        FileDelete(A_LoopFileFullPath)
    if (StrLen(Trim(text)) = 0) {
        statusText.Value := "Error: Clipboard is empty!"
        return
    }
    
    text := NormalizeText(text)
    statusText.Value := "Checking for existing audio..."
    
    ; Generate or get sequence ID
    timestamp := FormatTime(A_Now, "yyyyMMddHHmmss")
    sequenceId := timestamp  ; Use timestamp as sequence ID for new sequences
    
    ; Check for existing audio
    existing := FindExistingAudio(text)
    if (existing["file"]) {
        statusText.Value := "Found existing audio. Press Enter to play."
        lastAudioFile := existing["file"]
        currentSequenceId := existing["sequenceId"]
        AddDebug("Updating cache with file: " lastAudioFile)
        UpdateCache(lastAudioFile)
        HistoryPush(audioHistory, lastAudioFile, text)
        UpdateHistoryDisplay()
        return
    }
    
    ; Prepare API request
    statusText.Value := "Preparing request..."
    url := Format("https://api.elevenlabs.io/v1/text-to-speech/{1}", voiceID)
    
    ; Escape text for JSON
    jsonText := StrReplace(text, "\", "\\")
    jsonText := StrReplace(jsonText, "`"", "\`"")
    jsonText := StrReplace(jsonText, "`n", "\n")
    jsonText := StrReplace(jsonText, "`t", "\t")
    
    jsonData := "{`"text`":`"" jsonText "`"}"
    responseText.Value := "URL: " url "`nData: " jsonData
    
    ; Call ElevenLabs API
    tempFile := audioDir "\tts_" timestamp ".mp3"
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
            
        ; Save response as audio file
        adoStream := ComObject("ADODB.Stream")
        adoStream.Type := 1  ; Binary
        adoStream.Open()
        adoStream.Write(http.ResponseBody)
        adoStream.SaveToFile(tempFile)
        AddDebug("Saved audio file: " tempFile)
        AddDebug("File size: " FileGetSize(tempFile) " bytes")
        adoStream.Close()
        
        ; Update tracking
        AddToCSV(text, tempFile, timestamp, sequenceId)
        lastAudioFile := tempFile  ; Set the global variable
        AddDebug("Set lastAudioFile to: " lastAudioFile)
        currentSequenceId := sequenceId
        
        ; Update cache and history
        if (UpdateCache(tempFile)) {
            AddDebug("Cache updated successfully")
            HistoryPush(audioHistory, tempFile, text)
            UpdateHistoryDisplay()
            statusText.Value := "Ready"
        } else {
            AddDebug("ERROR: Failed to update cache")
            statusText.Value := "Error: Failed to update cache"
        }
        
    } catch as err {
        statusText.Value := "Error: " err.Message
        responseText.Value := "Exception details:`n" err.Message
    }
}

; Play current audio file
PlayCurrentAudio(*) {
    AddDebug("Attempting to play audio...")
    
    ; Get current audio file
    current := HistoryCurrent(audioHistory)
    if (current) {
        audioFile := current.file
        AddDebug("Playing from history: " current.text)
        currentText.Value := current.text
    } else {
        audioFile := lastAudioFile
        AddDebug("Playing last audio file")
        currentText.Value := "No text available"
    }
    
    if (audioFile = "") {
        AddDebug("No audio file to play")
        statusText.Value := "No audio file available!"
        return
    }
    
    ; Check if file exists
    if !FileExist(audioFile) {
        AddDebug("Audio file not found: " audioFile)
        statusText.Value := "Audio file not found!"
        return
    }
    
    AddDebug("Audio file exists: " audioFile)
    AddDebug("File size: " FileGetSize(audioFile) " bytes")
    statusText.Value := "Playing audio..."
    
    ; Play the audio
    try {
        SoundPlay(audioFile)
        AddDebug("Started playing audio file")
        
        ; Update LastPlayed timestamp
        UpdateLastPlayed(audioFile)
        AddDebug("LastPlayed timestamp updated")
        
        AddDebug("Playback started successfully")
        statusText.Value := "Ready"
    } catch Error as e {
        AddDebug("Error playing audio: " e.Message)
        statusText.Value := "Error playing audio!"
    }
}

; Update history display
UpdateHistoryDisplay() {
    current := HistoryCurrent(audioHistory)
    if (current) {
        AddDebug("Updating history display. Items: " audioHistory.items.Length)
        currentText.Value := current.text
        
        ; Update history list
        historyItems := []
        for item in audioHistory.items {
            historyItems.Push(item.text)
        }
        historyList.Delete()
        historyList.Add(historyItems)
        
        ; Select current item
        if (audioHistory.currentIndex > 0) {
            historyList.Choose(audioHistory.currentIndex)
        }
    } else {
        currentText.Value := "No text available"
        historyList.Delete()
    }
    AddDebug("History display updated successfully")
}

; Show recently played audios
ShowRecentlyPlayed(*) {
    AddDebug("Fetching recently played items...")
    recent := GetRecentlyPlayed()
    if (recent.Length = 0) {
        AddDebug("No recent items found")
        statusText.Value := "No recently played audios found"
        return
    }
    AddDebug("Found " recent.Length " items to show in menu")
    
    ; Create menu
    recentMenu := Menu()
    global recentItems := recent  ; Store items globally for menu callback
    
    Loop recent.Length {
        entry := recent[A_Index]
        
        ; Format timestamp for display
        timestamp := SubStr(entry.lastPlayed, 1, 4) "-" SubStr(entry.lastPlayed, 5, 2) "-" SubStr(entry.lastPlayed, 7, 2)
        timestamp .= " " SubStr(entry.lastPlayed, 9, 2) ":" SubStr(entry.lastPlayed, 11, 2)
        
        ; Truncate text if too long
        displayText := StrLen(entry.text) > 30 ? SubStr(entry.text, 1, 27) "..." : entry.text
        menuText := displayText " (" timestamp ")"
        
        ; Add menu item
        recentMenu.Add(menuText, PlayFromMenu)
    }
    
    ; Show menu at mouse position
    recentMenu.Show()
}

; Handle menu item selection
PlayFromMenu(itemName, itemPos, *) {
    entry := recentItems[itemPos]
    if FileExist(entry.file) {
        lastAudioFile := entry.file
        HistoryPush(audioHistory, entry.file, entry.text)
        UpdateHistoryDisplay()
        PlayCurrentAudio()
    } else {
        statusText.Value := "Audio file not found!"
    }
}

; Play selected history item
PlaySelectedHistory(ctrl, *) {
    selected := ctrl.Value
    if (selected > 0 && selected <= audioHistory.items.Length) {
        audioHistory.currentIndex := selected
        PlayCurrentAudio()
    }
}

; Update LastPlayed timestamp in CSV
UpdateLastPlayed(audioFile) {
    if (!FileExist(csvFile) || !FileExist(audioFile))
        return

    AddDebug("Updating LastPlayed for: " audioFile)
    timestamp := FormatTime(A_Now, "yyyyMMddHHmmss")
    
    ; Read all lines
    fileContent := FileRead(csvFile)
    lines := StrSplit(fileContent, "`n", "`r")
    newContent := ""
    
    ; First ensure header has LastPlayed column
    if (lines.Length > 0) {
        headerFields := StrSplit(lines[1], ",")
        if (headerFields.Length < 6) {
            newContent := "Text,Timestamp,AudioFile,Hash,SequenceId,LastPlayed`n"
        } else {
            newContent := lines[1] "`n"
        }
    } else {
        newContent := "Text,Timestamp,AudioFile,Hash,SequenceId,LastPlayed`n"
    }
    
    ; Update matching line
    Loop lines.Length - 1 {
        if (A_Index = 1)  ; Skip header
            continue
            
        fields := StrSplit(lines[A_Index], ",")
        if (fields.Length >= 3 && fields[3] = audioFile) {
            ; Ensure all fields are present
            while (fields.Length < 5)
                fields.Push("")
                
            ; Update or add LastPlayed
            lines[A_Index] := Format("{1},{2},{3},{4},{5},{6}", 
                fields[1], 
                fields[2], 
                fields[3], 
                fields[4], 
                fields[5], 
                timestamp)
        }
        
        if (lines[A_Index] != "")
            newContent .= lines[A_Index] "`n"
    }
    
    ; Write back to file
    FileDelete(csvFile)
    FileAppend(newContent, csvFile)
    AddDebug("LastPlayed timestamp updated")
}

; Get last 5 played audios
GetRecentlyPlayed() {
    if !FileExist(csvFile) {
        AddDebug("CSV file not found")
        return []
    }
        
    ; Read all entries with LastPlayed timestamps
    entries := []
    AddDebug("Reading CSV file for recent items...")
    
    Loop Read, csvFile {
        if (A_Index = 1) {  ; Log header structure
            AddDebug("CSV Header: " A_LoopReadLine)
            continue
        }
            
        fields := StrSplit(A_LoopReadLine, ",")
        AddDebug("Processing line " A_Index ": Fields=" fields.Length ", Text='" fields[1] "'")
        
        if (fields.Length >= 6) {
            if (FileExist(fields[3])) {
                if (fields[6]) {
                    AddDebug("Found valid entry: '" fields[1] "' played at " fields[6])
                    entries.Push({ file: fields[3], text: fields[1], lastPlayed: fields[6] })
                } else {
                    AddDebug("Entry has no LastPlayed timestamp: '" fields[1] "'")
                }
            } else {
                AddDebug("Audio file not found: " fields[3])
            }
        } else {
            AddDebug("Invalid field count: " fields.Length)
        }
    }
    
    ; Sort by LastPlayed timestamp (newest first)
    sortedEntries := []
    for entry in entries
        sortedEntries.Push(entry)
        
    ; Bubble sort (newest first)
    Loop sortedEntries.Length {
        i := A_Index
        Loop sortedEntries.Length - i {
            j := A_Index
            if (sortedEntries[j].lastPlayed < sortedEntries[j + 1].lastPlayed) {
                temp := sortedEntries[j]
                sortedEntries[j] := sortedEntries[j + 1]
                sortedEntries[j + 1] := temp
            }
        }
    }
    AddDebug("Total entries found: " sortedEntries.Length)
    
    ; Return up to 5 entries
    result := []
    Loop Min(sortedEntries.Length, 5) {
        result.Push(sortedEntries[A_Index])
        AddDebug("Selected recent item " A_Index ": '" sortedEntries[A_Index].text "' played at " sortedEntries[A_Index].lastPlayed)
    }
    
    AddDebug("Returning " result.Length " recently played items")
    return result
}

; File operations
OpenCache(*) {
    Run "explorer.exe " cacheDir
}

CopyAudioFile(*) {
    current := HistoryCurrent(audioHistory)
    if (!current || !FileExist(current.file)) {
        statusText.Value := "No audio file to copy!"
        return
    }
    
    ; Clear clipboard first
    A_Clipboard := ""
    
    ; Create a FileOperation object
    psh := ComObject("Shell.Application")
    SplitPath(current.file, &name, &dir)
    ns := psh.NameSpace(dir)
    item := ns.ParseName(name)
    
    ; Copy the file to clipboard
    item.InvokeVerb("Copy")
    statusText.Value := "Audio file copied to clipboard"
}


; ========== Hotkeys ==========
; Enter to play current audio
Enter::PlayCurrentAudio()

; ESC to exit
Esc::ExitApp()

; Alt + Space to open cache
!space::OpenCache()

; Alt + C to copy file
!c::CopyAudioFile()

; Up/Down arrows for history navigation
Up::{
    if (current := HistoryPrevious(audioHistory)) {
        lastAudioFile := current.file
        UpdateCache(current.file)
        UpdateHistoryDisplay()
    }
}

Down::{
    if (current := HistoryNext(audioHistory)) {
        lastAudioFile := current.file
        UpdateCache(current.file)
        UpdateHistoryDisplay()
    }
}

; Left/Right arrows for sequence navigation
Left::{
    if (prevFile := FindSequenceAudio(currentSequenceId, "prev")) {
        lastAudioFile := prevFile
        PlayCurrentAudio()
    }
}

Right::{
    if (nextFile := FindSequenceAudio(currentSequenceId, "next")) {
        lastAudioFile := nextFile
        PlayCurrentAudio()
    }
}

; Initialize history system
ProcessTTS()

; Keep script running
Persistent
