# Contributing to WritingFlow

Thank you for your interest in contributing to WritingFlow! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on GitHub with:

1. A clear, descriptive title
2. Steps to reproduce the issue
3. Expected behavior vs actual behavior
4. Your macOS version
5. Any relevant error messages or logs

### Suggesting Features

Feature requests are welcome! Please open an issue with:

1. A clear description of the feature
2. The problem it would solve
3. Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear, descriptive messages
6. Push to your fork
7. Open a Pull Request

#### PR Guidelines

- Keep changes focused and atomic
- Follow the existing code style
- Update documentation if needed
- Test on macOS 13.0+ before submitting

## Development Setup

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/[username]/WritingFlow.git
   cd WritingFlow
   ```

2. Open `WritingFlow.xcodeproj` in Xcode

3. Add the Swift Package dependency:
   - File → Add Package Dependencies
   - Enter: `https://github.com/sindresorhus/KeyboardShortcuts`
   - Click "Add Package"

4. Build and run (⌘R)

### Testing

Before submitting a PR:

1. Build the project successfully
2. Test the hotkey functionality
3. Verify text capture and replacement works
4. Test with at least one LLM provider

## Code Style

- Follow Swift naming conventions
- Use meaningful variable and function names
- Keep functions focused and small
- Add comments for complex logic
- Use SwiftUI best practices

## Questions?

Feel free to open an issue for any questions about contributing.
