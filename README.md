# FirstLight 🌅 — Your Morning Universe

A Flutter Android app — dark glassmorphism morning ritual companion.

## Screens
- 🌅 **Home** — Live clock, floating pet, streak/XP/badge stats
- 🎡 **Spin Wheel** — Physics-based daily task wheel with 8 segments
- 🎰 **777 Slots** — Three-reel life category combo challenges
- ✅ **Ritual** — Morning checklist with animated progress
- 🏆 **Trophies** — Achievement badge grid with tiers

## Setup

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)

### Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on connected device / emulator
flutter run

# 3. Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Project Structure

```
lib/
├── main.dart              # App entry, shell, bottom nav, confetti
├── theme.dart             # Colors, theme
├── models/
│   └── data.dart          # All data models and static content
├── widgets/
│   └── common.dart        # GlassCard, AmbientBackground, buttons, confetti
└── screens/
    ├── home_screen.dart
    ├── spin_screen.dart
    ├── slots_screen.dart
    ├── ritual_screen.dart
    └── achievements_screen.dart
```

## Dependencies
- `google_fonts` — Syne + DM Sans fonts
- `confetti` — particle effects
- `shared_preferences` — persist streak/XP
- `intl` — date/time formatting
