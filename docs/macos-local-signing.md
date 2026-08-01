# macOS Local Signing Setup

Each developer must configure their own Apple Development Team ID and Bundle Identifier locally. These personal values are **never committed to Git**.

## Quick Start

```bash
cp macos/Runner/Configs/LocalSigning.xcconfig.example \
   macos/Runner/Configs/LocalSigning.xcconfig
```

Then edit `macos/Runner/Configs/LocalSigning.xcconfig` with your own values.

## Finding Your Team ID

### Via Xcode

1. Open the workspace:

   ```bash
   open macos/Runner.xcworkspace
   ```

2. Select the **Runner** target → **Signing & Capabilities**.
3. Under **Team**, your Team ID is displayed (e.g., `ABC123XYZ`).
4. If using a **Personal Team**, that Team ID is acceptable for local development.

### Via Apple Developer Account

1. Go to <https://developer.apple.com/account>.
2. Click **Membership**.
3. Your Team ID is shown under **Membership details**.

## Filling in LocalSigning.xcconfig

```xcconfig
DEVELOPMENT_TEAM = ABC123XYZ
PRODUCT_BUNDLE_IDENTIFIER = com.circlelink.circlelink.yourname
```

- `DEVELOPMENT_TEAM` — your Apple Developer Team ID (no quotes).
- `PRODUCT_BUNDLE_IDENTIFIER` — a unique bundle ID for your local build.
  The pattern `com.circlelink.circlelink.<yourname>` is recommended.
  This must be different from every other developer's identifier.

## Enabling Automatic Signing in Xcode

1. Open `macos/Runner.xcworkspace`.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Check **Automatically manage signing**.
4. Select your Team from the dropdown.
5. Ensure **Signing Certificate** shows your development certificate.

`CODE_SIGN_STYLE = Automatic` is already set in the project. LocalSigning.xcconfig does not need to change this.

## Verifying Effective Settings

```bash
xcodebuild \
  -workspace macos/Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -showBuildSettings \
  | grep -E \
  "DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER|PRODUCT_NAME|PRODUCT_MODULE_NAME|CODE_SIGN_STYLE"
```

Expected output when `LocalSigning.xcconfig` exists:

```
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = <your team ID>
PRODUCT_BUNDLE_IDENTIFIER = com.circlelink.circlelink.<yourname>
PRODUCT_MODULE_NAME = circlelink
PRODUCT_NAME = circlelink
```

Without `LocalSigning.xcconfig`, you will see an empty `DEVELOPMENT_TEAM` and
`PRODUCT_BUNDLE_IDENTIFIER = com.circlelink.circlelink` (the shared default).

## Build

```bash
flutter clean
flutter pub get
flutter run -d macos
```

Or in Xcode: select the **Runner** scheme, choose **My Mac**, and press Run.

## Why a Personal Team Is Acceptable Locally

- Apple allows any Apple ID to sign macOS apps for local testing via a **Personal Team**.
- A Personal Team provisioning profile is valid for 7 days and is sufficient for `flutter run -d macos`.
- **Do not** use a Personal Team for App Store distribution or TestFlight.
- The production signing configuration is separate and outside the scope of this developer-local setup.

## What Not to Commit

- `macos/Runner/Configs/LocalSigning.xcconfig` — already in `.gitignore`.
- Never commit your Team ID or personal Bundle Identifier.
- Never commit provisioning profiles or signing certificates.

## Firebase and Google Sign-In Considerations

If each developer uses a different `PRODUCT_BUNDLE_IDENTIFIER`:

- **Firebase** requires a separate macOS app registration for each Bundle Identifier.
  - See: `macos/Runner/GoogleService-Info.plist`
  - See: `lib/firebase_options.dart`
- **Google Sign-In** (OAuth) also requires each Bundle Identifier to be registered
  in the Google Cloud Console.
  - See: `macos/Runner/Info.plist` (URL scheme/CFBundleURLTypes)
  - See: Google Cloud Console → APIs & Services → Credentials

For local development, you may choose to:

1. Register a unique Firebase app for your personal Bundle Identifier.
2. Or use the shared Bundle Identifier (`com.circlelink.circlelink`) for
   Firebase features and accept that only one developer can test those features at a time.

Consult the project's Firebase admin for the correct approach.

## Precedence Chain Summary

Build-setting resolution order for the Runner target (later overrides earlier):

1. `macos/Runner/Configs/AppInfo.xcconfig` — shared defaults (committed)
   - `PRODUCT_BUNDLE_IDENTIFIER = com.circlelink.circlelink`
   - `PRODUCT_NAME = circlelink`

2. `macos/Runner/Configs/LocalSigning.xcconfig` — developer overrides (ignored, optional)
   - `DEVELOPMENT_TEAM = YOUR_TEAM_ID`
   - `PRODUCT_BUNDLE_IDENTIFIER = com.circlelink.circlelink.yourname`

3. `macos/Runner/Configs/Debug.xcconfig` / `Profile.xcconfig` / `Release.xcconfig` — configuration-specific (committed)

4. Runner target `buildSettings` in `macos/Runner.xcodeproj/project.pbxproj` — remaining shared settings (committed, no longer contains `DEVELOPMENT_TEAM`)
