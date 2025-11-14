# Build & Run (Flutter + Rust stub)

Prereqs (local machine):
- Flutter SDK (stable) with platform toolchains (Android Studio SDKs, Xcode for iOS)
- Rust toolchain via rustup (for the engine)

One-time setup:
1) Flutter: https://docs.flutter.dev/get-started/install
2) Rust: https://rustup.rs

Engine build (stub, optional now):
```
cd engine
cargo build --release
```

Flutter dependencies:
```
cd app
flutter pub get
```

Run on Web (Chrome):
```
flutter run -d chrome
```

Run on Android (device or emulator):
```
flutter devices
flutter run -d <android-device-id>
```

Run on iOS (simulator):
```
flutter devices
flutter run -d <ios-simulator-id>
```

Notes:
- On first Android/iOS runs, Flutter creates platform folders and asks for camera permissions; allow them.
- This app uses a stub engine in Dart; Rust binding via flutter_rust_bridge can be added later without UI changes.
 
## Calling Rust via FFI (mobile/desktop)

This repo includes a C-ABI function from Rust (`process_meal_photo_ffi`) and a Dart FFI loader. To test on devices:

Android (.so via NDK):
1) Install NDK helper: `cargo install cargo-ndk`
2) Build for ABIs:
```
cd engine
cargo ndk -t arm64-v8a -o ../app/android/app/src/main/jniLibs build --release
cargo ndk -t armeabi-v7a -o ../app/android/app/src/main/jniLibs build --release
cargo ndk -t x86_64 -o ../app/android/app/src/main/jniLibs build --release
```
3) This produces `libengine.so` under `app/android/app/src/main/jniLibs/<abi>/`.
4) Run: `cd ../app && flutter run -d <android-device-id>`

iOS (link staticlib into Runner):
1) Build static lib:
```
cd engine
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios
```
2) Create XCFramework (optional) or add `target/*/release/libengine.a` to the iOS Runner in Xcode and ensure symbols are available at runtime (Dart FFI uses `DynamicLibrary.process()`).
3) Ensure `NSCameraUsageDescription` is set (already in `app/ios/Runner/Info.plist`).
4) Run: `cd ../app && flutter run -d <ios-simulator-id>` (for device, codesigning required).

Desktop (macOS/Windows/Linux):
- Build `libengine` for the host, place the shared lib where the app can load it (PATH or bundle), then `flutter run -d <platform>`.

Web:
- Web cannot use Dart FFI; the app uses a stubbed engine on web. `flutter run -d chrome` works with camera permission.
