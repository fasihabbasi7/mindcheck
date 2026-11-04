# MindCheck – Release Guide

App ID: **com.mindcheck.app** (Android and iOS). Never change it after the
first release. Version: set `version:` in `pubspec.yaml`
(`1.0.0+1` means version name 1.0.0, build number 1). Increase the build
number for every upload, and keep `AppInfo.version` in
`lib/utils/constants.dart` in sync.

## Android (Google Play)

### 1. Create your upload key (once)

Run in a terminal (Windows):

```
keytool -genkey -v -keystore %USERPROFILE%\mindcheck-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Choose a strong password and **back up the .jks file and password safely**.
Losing them means you cannot update the app.

### 2. Tell the build where the key is

Create `android/key.properties` (it is already ignored by git, never share it):

```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:\\Users\\YOU\\mindcheck-upload.jks
```

`android/app/build.gradle.kts` already reads this file. Without it, release
builds use the debug key (fine for testing, not for Play).

### 3. Build

```
flutter build appbundle --release
```

Upload `build/app/outputs/bundle/release/app-release.aab` in the Google Play
Console.

### 4. Play Console notes

- **Data safety form:** MindCheck collects no data and shares no data;
  everything is stored on the device. No internet permission is used in
  release builds.
- **Health apps declaration:** describe it as a self-reflection and
  educational app, not a medical device, and that it does not diagnose.
- **Content rating:** answer the questionnaire honestly (mental-health
  themes, no user interaction).
- **Privacy policy URL:** Play requires one even for apps that collect no
  data. You can host a short page that repeats the in-app Privacy
  information.
- **Attribution:** keep the ASRS copyright notice and the citations shown
  on each assessment.

## iOS (App Store)

Requires a Mac with Xcode and an Apple Developer account.

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Runner → Signing & Capabilities: choose your Team. The bundle ID is
   already `com.mindcheck.app`.
3. `flutter build ipa --release`, then upload with Xcode Organizer or
   Transporter.
4. App Privacy section: "Data Not Collected".

## App icon

Send the 1024 × 1024 logo; it will be converted into all Android mipmap and
iOS AppIcon sizes.

## Before every release

- Work through `docs/TESTING_CHECKLIST.md`.
- `flutter analyze` and `flutter test` must pass.
- Bump the build number in `pubspec.yaml`.
