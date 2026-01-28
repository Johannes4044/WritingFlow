# Writing Flow

A macOS menu bar app that captures selected text via hotkey, reformats it through an LLM, and replaces the original text.

## Features

- **Global Hotkey** (Cmd+Shift+R) - Capture and reformat text from any app
- **Multiple Modes** - Email, WhatsApp, Formal, Casual, Grammar Fix (+ custom modes)
- **Knowledge Base** - Abbreviations and names for context-aware reformatting
- **Multiple LLM Providers** - OpenAI, Anthropic Claude, Ollama, LM Studio
- **Modern Design** - White mode with vibrant color accents

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- An API key for OpenAI or Anthropic (or a local LLM setup)

## Setup Instructions

### Option 1: Open in Xcode (Recommended)

1. Open Xcode
2. File → New → Project
3. Choose "App" under macOS
4. Set:
   - Product Name: `WritingFlow`
   - Organization Identifier: `com.writingflow`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
5. Save the project in this directory
6. Delete the auto-generated files (ContentView.swift, WritingFlowApp.swift, Item.swift)
7. Drag all files from the `WritingFlow` folder into your Xcode project
8. Add the Swift Package dependency:
   - File → Add Package Dependencies
   - Enter: `https://github.com/sindresorhus/KeyboardShortcuts`
   - Click "Add Package"
9. In project settings, set:
   - Deployment Target: macOS 13.0
   - Under "Info" tab, add the entries from `Info.plist`

### Option 2: Build with Swift Package Manager

```bash
cd "/Users/johannes/Documents/Procjects/VS Code/Writing flow"
swift build
```

Note: SPM builds may have limitations for full macOS app features.

## Project Structure

```
WritingFlow/
├── App/                    # Main app entry point
├── Models/                 # SwiftData models
├── Services/               # Business logic services
├── Views/
│   ├── MenuBar/           # Menu bar dropdown views
│   ├── Settings/          # Settings window views
│   └── Components/        # Reusable UI components
└── Resources/             # Assets and config files
```

## Usage

1. Launch the app (it will appear in the menu bar)
2. Click the menu bar icon to:
   - Select a reformatting mode
   - Access settings
3. Configure your LLM API key in Settings → LLM
4. Grant accessibility permissions when prompted
5. Select text in any app and press **Cmd+Shift+R**
6. The text will be reformatted and replaced

## Configuration

### LLM Providers

- **OpenAI**: Requires API key from platform.openai.com
- **Anthropic**: Requires API key from console.anthropic.com
- **Ollama**: Free, runs locally. Install from ollama.ai
- **LM Studio**: Free, runs locally. Install from lmstudio.ai

### Knowledge Base

Add abbreviations and names in Settings → Knowledge:

- **Abbreviations**: e.g., "MfG" → "Mit freundlichen Grüßen"
- **Names**: For correct spelling of people/companies

## License

MIT License
