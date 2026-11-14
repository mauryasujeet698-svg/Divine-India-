# Android APK workflow

There is no automatic build trigger in this repository.

The workflow `.github/workflows/manual-android-apk.yml` is configured for `workflow_dispatch` only. It must be started manually from GitHub Actions, and lets an authorized repository user select Customer, Admin or Operations.

The job generates the Android platform scaffold in a temporary folder, copies only the generated `android/` directory into the selected app, resolves dependencies, and then produces a release APK. This keeps platform-specific generated files out of the initial frontend commits.

The uploaded APK artifact uses `retention-days: 1`, so GitHub removes the downloadable artifact after one day. This does **not** expire or uninstall an APK already downloaded and installed on a phone.

No APK/AAB workflow has been dispatched during repository setup.
