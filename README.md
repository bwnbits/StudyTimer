# StudyTimer

A quiet, focused macOS timer for turning study time into a visible block of progress.

StudyTimer keeps the important number large and the rest close at hand: a countdown, session presets, custom durations, laps, tasks, reminders, and a menu-bar companion that stays available while you work.

## Features

- Large, minimal countdown display
- `15m`, `25m`, and `50m` focus presets
- Custom session length in minutes
- Start, pause, reset, and lap tracking
- Persistent task list with completion state
- Date and time reminders with macOS notification sounds
- Audible completion alert
- Always-available menu-bar timer
- Large macOS desktop widget
- Local persistence with no account or network required

## Run From Xcode

1. Open `StudyTimer.xcodeproj` in Xcode.
2. Select the `StudyTimer` scheme and `My Mac`.
3. Press `Cmd + R`.
4. Allow notifications when macOS asks.

The app appears in the menu bar while it is running. Click the timer there to open its compact controls.

## Add The Widget

1. Run the app once from Xcode.
2. Control-click the macOS desktop and choose **Edit Widgets**.
3. Search for **Study Timer**.
4. Add the large widget.

The widget reads the current session through the shared App Group. App Groups may require an Apple Developer account for signing.

## Build A DMG

```bash
xcodebuild -project StudyTimer.xcodeproj -scheme StudyTimer -configuration Release -sdk macosx build
mkdir -p dist
cp -R ~/Library/Developer/Xcode/DerivedData/StudyTimer-*/Build/Products/Release/StudyTimer.app dist/
hdiutil create -volname StudyTimer -srcfolder dist -ov -format UDZO StudyTimer.dmg
```

## Requirements

- macOS 14.6 or later
- Xcode 16 or later
- Swift 5

## License

Personal project. Add a license here before redistributing.
