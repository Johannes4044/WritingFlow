# WritingFlow

A macOS menu bar app that captures selected text via hotkey, reformats it through an LLM, and replaces the original text.

## Features

- **Global Hotkey** (⌘⇧R) - Capture and reformat text from any app
- **Multiple Modes** - Email, WhatsApp, Formal, Casual, Grammar Fix (+ custom modes)
- **Knowledge Base** - Abbreviations and names for context-aware reformatting
- **Multiple LLM Providers** - OpenAI, Anthropic Claude, Ollama, LM Studio
- **Undo Support** - Press ⌘⇧Z to revert the last reformat
- **Multi-Version Generation** - Generate multiple versions and pick your favorite

## Requirements

- macOS 13.0 (Ventura) or later
- An API key for OpenAI or Anthropic (or a local LLM setup with Ollama/LM Studio)

## Installation

### Option 1: Download DMG (Easiest)

1. Download `WritingFlow.dmg` from this repository
2. Double-click to mount, drag WritingFlow to Applications
3. See [INSTALL.md](INSTALL.md) for first-launch instructions (required for unsigned apps)

### Option 2: Build from Source

1. Clone this repository
2. Open `WritingFlow.xcodeproj` in Xcode 15+
3. Add the Swift Package dependency:
   - File → Add Package Dependencies
   - Enter: `https://github.com/sindresorhus/KeyboardShortcuts`
4. Build and run (⌘R)

## Quick Start

1. Launch WritingFlow (it appears in the menu bar)
2. Click the menu bar icon → **Settings** → **LLM**
3. Configure your preferred LLM provider (see [INSTALL.md](INSTALL.md) for details)
4. Grant accessibility permissions when prompted
5. Select text in any app and press **⌘⇧R**
6. Your text will be reformatted automatically!

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘⇧R | Capture and reformat selected text |
| ⌃⌘M | Cycle through modes |
| ⌘⇧Z | Undo last reformat |

## LLM Providers

| Provider | Type | Cost |
|----------|------|------|
| **OpenAI** | Cloud | ~$0.01-0.10 per reformat |
| **Anthropic** | Cloud | ~$0.01-0.10 per reformat |
| **Ollama** | Local | Free (requires ~4GB disk) |
| **LM Studio** | Local | Free |

See [INSTALL.md](INSTALL.md) for detailed setup instructions for each provider.

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

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT License](LICENSE)
