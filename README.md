# KeySound

macOS app that plays sound when you press keyboard keys.

## Features

- Plays sound on every keypress
- 8 system sounds: Glass, Pop, Tink, Ping, Morse, Sosumi, Funk, Hero
- Adjustable volume
- Low latency (~5-10ms)
- Menu bar + Dock icon
- Accessibility permission auto-prompt

## Requirements

- macOS 13.0+
- Accessibility permission (System Settings > Privacy & Security > Accessibility)

## Installation

1. Download `KeySound-v1.2.dmg`
2. Open DMG and drag `KeySound.app` to Applications
3. Launch KeySound
4. Grant Accessibility permission when prompted

## Build from Source

```bash
# Using Xcode
open KeyboardSound.xcodeproj
# Press ⌘R to build and run

# Using command line
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -scheme KeyboardSound -configuration Release build
```

## Keyboard Shortcuts

- `⌘,` - Open Settings
- `⌘Q` - Quit

## License

MIT
