---
description: Build a signed release APK for Android
---

To generate a new signed release APK for Android, follow these steps:

1.  (Optional) Update the version number in `pubspec.yaml` (e.g., `version: 1.0.1+2`).
2.  Open a terminal in the `flutter_app` directory.
// turbo
3.  Run the following command:
    ```bash
    flutter build apk --release
    ```

The final APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`
