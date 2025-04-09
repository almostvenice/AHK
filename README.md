# Accessibility AutoHotkey Scripts

A collection of AutoHotkey scripts designed to enhance productivity and accessibility for eye-gaze users, particularly when used in conjunction with PhraseExpander.

## 🎯 Purpose

This project aims to:
- Speed up text input for users with eye-gaze systems
- Provide quick access to text-to-speech capabilities
- Manage and organize bookmarks efficiently
- Automate common tasks to reduce physical input requirements

## 🚀 Key Features

### Text Expansion and Management
- **DetectTriggerInMidWord**: Handles double-character triggers (xx, zz) for text expansion
- **TextExpansion**: Provides custom text expansion shortcuts
- **Move Autosuggest**: Automatically positions PhraseExpander's autosuggest window in a convenient location

### Text-to-Speech
- **TextToElevenlabs**: Converts selected text to speech using ElevenLabs' API
- **Select Previous/Next Sentence**: Quick selection of text for speech conversion

### Navigation
- **BookmarkSelector**: Quick access to frequently visited websites
- **Update All**: Keeps scripts and configurations up to date

## 📋 Requirements

- AutoHotkey v2.0
- PhraseExpander
- Chrome (for bookmark functionality)
- ElevenLabs API key (for text-to-speech features)

## ⚙️ Setup

1. Install AutoHotkey v2.0
2. Clone this repository
3. Create a `.env` file in the root directory with your ElevenLabs credentials:
   ```
   API_KEY=your_elevenlabs_api_key
   VOICE_ID=your_voice_id
   ```
4. Run the desired scripts

## 🔑 Key Shortcuts

- `xx` or `zz`: Trigger text expansion
- `Alt + S`: Replay last audio
- `Alt + E`: Exit current script
- Enter: Select bookmark (when BookmarkSelector is active)

## 📁 Project Structure

```
.
├── AutoHotkey/
│   ├── TextExpansion.ahk          # Text expansion shortcuts
│   ├── BookmarkSelector.ahk       # Website bookmark manager
│   ├── textToElevenlabs.ahk      # Text-to-speech conversion
│   ├── DetectTriggerInMidWord.ahk # Double-character trigger handler
│   ├── move_autosuggest.ahk      # Window positioning
│   ├── select_next_sentence.ahk   # Text selection utilities
│   ├── select_previous_sentence.ahk
│   └── update_all.ahk            # Update script
├── .env                          # API credentials (not tracked)
└── README.md
```

## 🤝 Contributing

Contributions to improve accessibility features are welcome. Please feel free to submit issues and pull requests.

## 📝 License

[Your chosen license]
