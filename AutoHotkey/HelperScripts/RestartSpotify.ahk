#Requires AutoHotkey v2.0

; Check if Spotify is running
if ProcessExist("Spotify.exe") {
    ; Close Spotify
    ProcessClose("Spotify.exe")
    ; Wait a moment for Spotify to fully close
    Sleep(2000)
}

; Start Spotify
Run("Spotify.exe")
