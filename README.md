# CLC Barmer

Career Launcher Classes, Barmer — coaching app.

## What's inside

- Splash + login screens, a 5-tab shell (Home, Courses, Tests, Material, Profile)
- PW-style circular quick-action row at the top of Home
- Courses with modules, lessons and sample practice tests
- Lessons use built-in interactive content (no video files needed)
- Local on-device storage (SharedPreferences) so progress, results and
  settings are remembered between launches
- Local notifications: permission is requested when the app opens, and
  Settings has a Notifications switch. Turning it on asks for permission and
  fires a welcome notification instantly so it can be tested.

## Build the APK

There is no Flutter SDK in the authoring environment — the APK is built by
GitHub Actions (`.github/workflows/build-apk.yml`):

- Push to `main`/`master` → the workflow builds the APK and uploads it as an
  artifact named `CLC-Barmer-APK`.
- Run the workflow manually (Actions → Build APK → Run workflow), or publish a
  release/tag, to also attach the APK to a GitHub Release.

The workflow generates the `android/` folder itself, configures the app label,
the notification permission and core-library desugaring, generates the launcher
icon from `assets/icon.png`, then builds with `flutter build apk --release --no-shrink`.

## Run locally

```
flutter pub get
dart run flutter_launcher_icons   # regenerate the launcher icon
flutter run
```

For the other platforms, run once locally:

```
flutter create . --platforms=ios,windows,macos,linux
```
