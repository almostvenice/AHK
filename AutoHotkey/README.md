# AHK Bookmark Manager

A simple AutoHotkey v2 script that provides a GUI interface for managing and opening bookmarks in Google Chrome.

## Features
- GUI interface with a list of bookmarks
- Keyboard navigation (Up/Down arrows)
- Open bookmarks with Enter key or double-click
- Automatically focuses Chrome if it's already open
- Creates new tab if Chrome isn't running

## Requirements
- AutoHotkey v2.0
- Google Chrome

## Usage
1. Run the `BookmarkManager.ahk` script
2. Use Up/Down arrows to navigate the bookmark list
3. Press Enter or double-click to open the selected bookmark
4. Add your own bookmarks by editing the `bookmarks` Map in the script

## Customization
To add more bookmarks, edit the `bookmarks` Map at the top of the script. Follow the format:
```autohotkey
"Bookmark Name", "https://bookmark.url"
```
