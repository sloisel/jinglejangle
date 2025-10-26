# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Jingle Jangle is a Flutter-based educational game app for learning Japanese characters (Hiragana and Katakana) and spelling. The app uses a tile-matching game mechanic combined with text-to-speech and audio feedback.

## Development Commands

### Build and Run
```bash
flutter run                          # Run app on connected device/simulator
flutter build ios                    # Build iOS app
flutter build android               # Build Android app
```

### Dependencies
```bash
flutter pub get                      # Install dependencies
flutter pub upgrade                 # Upgrade dependencies
```

### Testing
```bash
flutter test                         # Run tests
flutter analyze                      # Run static analysis
```

## Architecture Overview

### Core Game Modes

The app has two primary game modes, both navigable from the main Selector screen:

1. **GameBoard Mode** (`gameboard.dart`) - Tile-matching game where tiles fall with physics simulation. Players tap matching tiles based on audio/visual prompts.

2. **Spelling Mode** (`spelling.dart`) - Keyboard-based spelling game where players type answers using an on-screen keyboard.

### Key Files

- **`main.dart`** - App entry point, defines MaterialApp with route structure (`/`, `/PreGame`, `/GameBoard`, `/Win`, `/Spelling`)
- **`navigation.dart`** - Contains three main screens:
  - `Selector` - Hierarchical menu system for choosing game content
  - `PreGame` - Preview/configuration screen before starting a game
  - `Win` - Victory screen with celebration animation
- **`gameboard.dart`** - Falling tile game with physics simulation (gravity, collision detection)
- **`spelling.dart`** - Keyboard-based spelling game with hint system
- **`mysound.dart`** - Audio playback and TTS integration:
  - `Speaker` class handles text-to-speech with language detection (Japanese/English)
  - `SoundFX` class manages MP3 audio assets
  - Pre-recorded audio for Hiragana/Katakana characters in `assets/marina/`
- **`probloader.dart`** - Processes the problemset.json configuration:
  - `fixprobset2()` normalizes and enriches problem set data
  - `makeHomonyms()` manages character equivalences (e.g., じ/ぢ are treated as the same)

### Game Configuration System

The entire game content is driven by `assets/problemset.json`, which defines:
- Hierarchical menu structure (nested children)
- Character sets (`tileset` for GameBoard, `spelling` for Spelling mode)
- Font choices (supports custom Japanese fonts: Gyosyo, Kaisyo)
- Homonyms (characters that should be treated as equivalent)
- Display hints and title configurations
- Language settings for TTS

Configuration options propagate from parent to child nodes in the hierarchy:
- `fontChoices` - Available fonts for the game
- `keyboard` - Keyboard layout for spelling mode
- `titleHint` - Whether to show the question as the title
- `maxtime` - Time before hint highlight appears
- `numTiles` - Number of tiles in GameBoard mode
- `language` - TTS language ("detect", "ja-JP", "en-US")
- `decrypt` - Character substitution rules for solutions

### Scoring System

Both game modes use a weighted random selection that favors characters with lower scores:
- Probability weight = (maxScore - currentScore)²
- Correct answers increase score (with bonuses for speed in GameBoard mode)
- Errors reset the score for that character to 0
- Game ends when all characters reach maximum score (4 for GameBoard, 1 for Spelling)

### Audio System

Two audio subsystems work together:
1. **Text-to-Speech** - Flutter TTS with automatic language detection (Latin vs Japanese regex)
2. **Audio Files** - Pre-loaded MP3s for:
   - All Hiragana/Katakana characters (numbered files in `assets/marina/`)
   - Sound effects (fail-buzzer-01.mp3, joy.mp3, applause)

The system checks for exact Hiragana/Katakana matches first, falling back to TTS for other text.

### UI Components

The app uses a `makeButton()` utility that creates responsive buttons with:
- Auto-sizing text (from preset size list in `textsizes`)
- Absolute positioning within a Stack layout
- Rounded corners and borders
- Custom font family support

### State Management

All screens are StatefulWidgets with manual state management:
- Route arguments pass configuration down the navigation tree
- `setState()` triggers rebuilds, often with `SchedulerBinding.instance.addPostFrameCallback()` for animation loops
- Timer-based events for physics updates, hint timing, and auto-navigation

### Platform Support

- iOS and Android native projects in `ios/` and `android/`
- Custom fonts bundled in `fonts/` (acgyosyo.ttf, ackaisyo.ttf)
- Asset directories organized by type (`assets/images/`, `assets/marina/`)
- iOS-specific plugins: audioplayers, flutter_tts, path_provider_ios

## Dart Version

This project uses Dart 2.9 with null-safety disabled (`// @dart=2.9` annotations). All nullable types use the `?` syntax explicitly where needed.
