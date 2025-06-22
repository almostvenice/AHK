#Requires AutoHotkey v2.0
#SingleInstance Force

; Make window title matching more lenient
SetTitleMatchMode(2)  ; Match anywhere in the title

; Define your bookmarks here
bookmarks := Map(
    "Google", "https://www.google.com",
    "GitHub", "https://github.com",
    "YouTube", "https://www.youtube.com",
    "Reddit", "https://www.reddit.com"
    ; Add more bookmarks as needed
)

; Create array of bookmark names for the ListBox
bookmarkNames := []
for name, url in bookmarks
    bookmarkNames.Push(name)

; Create the main GUI
myGui := Gui("+Resize", "Bookmark Selector")
myGui.SetFont("s18 bold")
myGui.Add("Text", "h60", "Bookmark Selector")
myGui.SetFont("s16")
bookmarkList := myGui.Add("ListBox", "vSelectedBookmark w300 h400", bookmarkNames)
myGui.SetFont("s14")
myGui.Add("Button", "w150 h50", "Open Selected").OnEvent("Click", OpenSelectedBookmark)
myGui.Add("Button", "x+10 w130 h50", "Refresh List").OnEvent("Click", RefreshList)

; Show the GUI
myGui.Show()

; Handle keyboard input
#HotIf WinActive("Bookmark Selector")
Enter::OpenSelectedBookmark()
#HotIf

FindChromeTab(searchText) {
    ; Get all Chrome windows
    chromeWindows := WinGetList("ahk_class Chrome_WidgetWin_1")
    
    ; First try the active window's title (this is most reliable)
    activeHwnd := WinGetID("A")
    if (activeHwnd) {
        activeTitle := WinGetTitle("ahk_id " activeHwnd)
        if (InStr(activeTitle, searchText) && InStr(activeTitle, "- Google Chrome")) {
            return true  ; Already on the right tab
        }
    }
    
    ; Then try each Chrome window
    for hwnd in chromeWindows {
        ; Get all window titles
        title := WinGetTitle("ahk_id " hwnd)
        
        ; Skip empty titles and Chrome's own UI windows
        if (title = "" || !InStr(title, "- Google Chrome"))
            continue
            
        ; Activate each window briefly to get its real title
        WinActivate("ahk_id " hwnd)
        Sleep(100)  ; Give Chrome time to update the title
        updatedTitle := WinGetTitle("ahk_id " hwnd)
        
        ; Check if this window contains our search text
        if InStr(updatedTitle, searchText) {
            WinActivate("ahk_id " hwnd)
            return true
        }
    }
    
    return false
}

OpenSelectedBookmark(*) {
    ; Get selected item
    selectedIndex := bookmarkList.Value
    
    if !selectedIndex {
        return
    }
    
    ; Get the bookmark name from the array using the index
    selectedName := bookmarkNames[selectedIndex]
    url := bookmarks[selectedName]
    
    ; Try to open URL in Chrome
    try {
        ; Check if Chrome is running
        if WinExist("ahk_class Chrome_WidgetWin_1") {
            ; Extract domain from URL for matching
            urlDomain := RegExReplace(url, "^https?://(www\.)?([^/]+).*", "$2")
            
            ; Try to find existing tab by domain or name
            if FindChromeTab(urlDomain) || FindChromeTab(selectedName) {
                ; Tab was found and activated
            } else {
                ; No existing tab found, open in new tab
                Run("chrome.exe --new-tab " url)
            }
        } else {
            ; Chrome not running, open in new window
            Run("chrome.exe " url)
        }
        
        ; Close the GUI
        myGui.Destroy()
    } catch Error as e {
        MsgBox("Error opening bookmark: " e.Message)
    }
}

RefreshList(*) {
    ; Refresh the list of bookmarks
    bookmarkNames := []
    for name, url in bookmarks
        bookmarkNames.Push(name)
    bookmarkList.Delete()
    for name in bookmarkNames
        bookmarkList.Add(name)
}

myGui.OnEvent("Close", (*) => ExitApp())
