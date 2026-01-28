# WritingFlow Installation Guide

## Installation

1. Download `WritingFlow.dmg`
2. Double-click to mount the DMG
3. Drag **WritingFlow** to the **Applications** folder
4. Eject the DMG

## First Launch (Important!)

Since this app is not notarized with Apple, macOS will block it by default. To open it:

### Method 1: Right-click to Open
1. Go to **Applications** folder
2. **Right-click** (or Control-click) on WritingFlow
3. Select **Open** from the menu
4. Click **Open** in the dialog that appears

### Method 2: System Settings
1. Try to open the app normally (it will be blocked)
2. Go to **System Settings** → **Privacy & Security**
3. Scroll down to find "WritingFlow was blocked"
4. Click **Open Anyway**

## Grant Accessibility Permissions

WritingFlow needs accessibility permissions to capture and replace text:

1. On first launch, macOS will prompt for accessibility access
2. Click **Open System Settings**
3. Enable the toggle for **WritingFlow**
4. You may need to restart the app

## Configure an LLM Provider (Required)

WritingFlow uses AI to reformat your text. You need to configure **one** of these providers:

### Option A: OpenAI (Recommended - easiest setup)
1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Create an account and generate an API key
3. In WritingFlow, click the menu bar icon → **Settings** → **LLM**
4. Select **OpenAI** as the provider
5. Paste your API key

*Cost: ~$0.01-0.10 per reformat depending on text length*

### Option B: Anthropic Claude
1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create an account and generate an API key
3. In WritingFlow, click the menu bar icon → **Settings** → **LLM**
4. Select **Anthropic** as the provider
5. Paste your API key

### Option C: Ollama (Free - runs locally)
1. Download and install Ollama from [ollama.ai](https://ollama.ai)
2. Open Terminal and run:
   ```
   ollama pull llama3.2
   ```
3. Keep Ollama running in the background
4. In WritingFlow, click the menu bar icon → **Settings** → **LLM**
5. Select **Ollama** as the provider

*Note: Requires ~4GB disk space for the model. Works offline.*

### Option D: LM Studio (Free - runs locally)
1. Download LM Studio from [lmstudio.ai](https://lmstudio.ai)
2. Open LM Studio and download a model (e.g., Llama 3)
3. Start the local server in LM Studio
4. In WritingFlow, click the menu bar icon → **Settings** → **LLM**
5. Select **LM Studio** as the provider

## Quick Start

1. Select any text in any application
2. Press **⌘⇧R** (Cmd+Shift+R)
3. Wait a moment - your text will be reformatted automatically
4. If you don't like the result, press **⌘⇧Z** (Cmd+Shift+Z) to undo

## Usage

- **⌘⇧R** (Cmd+Shift+R) - Capture selected text and reformat
- **⌃⌘M** (Ctrl+Cmd+M) - Cycle through modes
- **⌘⇧Z** (Cmd+Shift+Z) - Undo last reformat

## Troubleshooting

### "App is damaged" error
Run this command in Terminal:
```
xattr -cr /Applications/WritingFlow.app
```

### Hotkey not working
- Ensure accessibility permissions are granted
- Check System Settings → Privacy & Security → Accessibility

## Requirements

- macOS 13.0 (Ventura) or later
