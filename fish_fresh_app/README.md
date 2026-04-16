# FishCheck ZM

AI-powered fish freshness analyser for Zambia. Take or upload a photo of a fish and get an instant freshness score powered by Claude AI vision.

Runs on **Android · iOS · Web · Windows**.

---

## Quick start (3 steps)

### 1. Install Flutter
Download Flutter SDK from https://docs.flutter.dev/get-started/install
Make sure `flutter doctor` shows no critical errors.

### 2. Install dependencies
```bash
cd fish_fresh_zm
flutter pub get
```

### 3. Add your Anthropic API key
Run the app → go to **Settings** tab → paste your API key.
Get a free key at https://console.anthropic.com

---

## Running on each platform

### Android
```bash
flutter run -d android
```
Or build a release APK:
```bash
flutter build apk --release
```

### iOS (Mac only)
```bash
flutter run -d ios
```
Or build for App Store:
```bash
flutter build ipa --release
```

### Web
```bash
flutter run -d chrome
```
Or build for hosting:
```bash
flutter build web --release
# Output is in build/web/ — deploy to any static host (Netlify, Firebase Hosting, etc.)
```

### Windows
```bash
flutter run -d windows
```
Or build an exe:
```bash
flutter build windows --release
# Output is in build/windows/x64/runner/Release/
```

---

## Project structure

```
lib/
├── main.dart                        # App entry point, responsive shell
│                                    # Mobile: bottom nav bar
│                                    # Web/Windows: side rail (220px)
├── theme.dart                       # Colors, light + dark themes
├── models/
│   └── freshness_result.dart        # Data model — stores imageBytes not file path
├── platform/
│   └── image_picker_service.dart    # Cross-platform image picker
│                                    # Mobile: camera + gallery via image_picker
│                                    # Web/Windows: file picker via file_picker
├── services/
│   ├── claude_service.dart          # Anthropic API — sends bytes, parses JSON
│   └── history_service.dart         # SharedPreferences persistence
├── screens/
│   ├── scan_screen.dart             # Camera/upload + analyse button
│   ├── result_screen.dart           # Full freshness result display
│   ├── history_screen.dart          # Past scans (no dart:io — works everywhere)
│   ├── species_screen.dart          # Zambian fish directory
│   └── settings_screen.dart        # API key + preferences
└── widgets/
    └── freshness_widgets.dart       # FreshnessBadge, ScoreBar
```

---

## Platform differences

| Feature | Android | iOS | Web | Windows |
|---|---|---|---|---|
| Camera | Yes | Yes | Yes (browser) | No |
| Gallery | Yes | Yes | Yes (file upload) | Yes (file picker) |
| Share result | Yes | Yes | Yes | No (copy to clipboard) |
| Offline species directory | Yes | Yes | Yes | Yes |
| History thumbnails | Yes | Yes | Yes | Yes |

---

## Freshness levels

| Level | Score | Safe to sell? |
|---|---|---|
| Fresh | 80–100% | Yes — full price |
| Acceptable | 50–79% | Yes — sell today |
| Poor | 20–49% | Reduced price only |
| Spoiled | 0–19% | Do not sell |

---

## Zambian species covered

Kapenta · Bream (Tilapia) · Tiger fish · Mpumbu · Chessa · Vundu (Catfish)

Each entry includes local names (Nyanja/Bemba), habitat, fishing season, typical price range ZMW, and freshness indicators.

---

## API costs

Each scan sends one image to Claude Sonnet. Approximate cost: ~$0.003–0.005 per scan.
Monitor usage at https://console.anthropic.com

---

## Permissions

### Android
- `CAMERA` — take fish photos
- `READ_MEDIA_IMAGES` — gallery access
- `INTERNET` — Claude API calls

### iOS
- `NSCameraUsageDescription` — take fish photos
- `NSPhotoLibraryUsageDescription` — gallery access

### Web / Windows
- File system access via browser file picker / Windows file dialog
- Internet access for Claude API

---

Built with Flutter · Powered by Claude AI (Anthropic)
