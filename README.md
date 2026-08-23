# StudyTimer

![StudyTimer](https://img.shields.io/badge/macOS-14.6%2B-111827?logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift&logoColor=white)
[![Latest release](https://img.shields.io/github/v/release/bwnbits/StudyTimer?display_name=tag&sort=semver)](https://github.com/bwnbits/StudyTimer/releases)
[![License](https://img.shields.io/github/license/bwnbits/StudyTimer)](LICENSE)

**A calm, native macOS timer for turning focused study into visible progress.**

StudyTimer keeps one clear number in view while the rest of your workflow stays close at hand: session presets, custom durations, laps, tasks, reminders, completion sounds, a menu-bar companion, and a desktop widget. Everything is stored locally, with no account or network connection required.

## Features

| Focus | Planning | At a glance |
| --- | --- | --- |
| `15m`, `25m`, and `50m` presets | Persistent task list | Menu-bar timer |
| Custom session length | Date and time reminders | Large desktop widget |
| Start, pause, reset, and laps | Completion state for tasks | Shared live session state |
| Custom and system alert sounds | macOS notifications | Local-only persistence |

## Install

1. Download the latest [`StudyTimer.dmg`](https://github.com/bwnbits/StudyTimer/releases/latest) from GitHub Releases.
2. Open the DMG and drag **StudyTimer** to **Applications**.
3. Launch StudyTimer from Applications.
4. Allow notifications when prompted if you want reminders and session-completion alerts.

### Add the widget

After launching StudyTimer once, Control-click the desktop, choose **Edit Widgets**, search for **Study Timer**, and add the large widget. The widget reads the current session through the shared App Group. Signing the widget from Xcode may require an Apple Developer account.

## Build from source

### Prerequisites

- macOS 14.6 or later
- Xcode 16 or later
- Swift 5.0 (included with Xcode)
- An Apple Developer account for signed distribution and App Group entitlements

### Run locally

```bash
git clone https://github.com/bwnbits/StudyTimer.git
cd StudyTimer
xcodebuild -project StudyTimer.xcodeproj -scheme StudyTimer -configuration Debug build
```

For the normal development workflow, open `StudyTimer.xcodeproj` in Xcode, select the **StudyTimer** scheme and **My Mac**, then press `Cmd + R`.

### Create a DMG

The following uses a local derived-data directory so the output path is predictable:

```bash
xcodebuild \
	-project StudyTimer.xcodeproj \
	-scheme StudyTimer \
	-configuration Release \
	-derivedDataPath .build \
	build

rm -rf dist
mkdir -p dist
cp -R .build/Build/Products/Release/StudyTimer.app dist/
hdiutil create \
	-volname StudyTimer \
	-srcfolder dist \
	-ov \
	-format UDZO \
	StudyTimer.dmg
```

The resulting `StudyTimer.dmg` is unsigned unless you configure signing in Xcode. macOS may show a security warning when opening an unsigned local build.

## Related apps

- [NetPulse](https://github.com/bwnbits/NetPulse) - a lightweight native macOS menu-bar network monitor.
- [Homebrew tap](https://github.com/bwnbits/homebrew-netpulse) - install NetPulse with `brew install --cask bwnbits/netpulse/netpulse`.
- [More from bwnbits](https://github.com/bwnbits) - other tools and projects.

## License

StudyTimer is released under the [MIT License](LICENSE).

---

## ⚠️ First-Time Opening Instructions (macOS Gatekeeper)

Since StudyTimer is an open-source build distributed outside the Mac App Store without a paid Apple Developer ID:
1. Drag **StudyTimer** to your `/Applications` folder.
2. **Right-click** (or Control-click) `StudyTimer.app` and choose **Open**.
3. Click **Open** when prompted by macOS to allow it to run.
