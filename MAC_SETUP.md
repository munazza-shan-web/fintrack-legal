# Run Savings Goals on your Mac

The app now uses Cupertino screens, iOS navigation, grouped settings, date
pickers and light/dark appearance. The green identity and selected logo remain.

## Get the code

```sh
git clone https://github.com/munazza-shan-web/fintrack-legal.git
cd fintrack-legal
git switch codex/ios-redesign
```

If you already cloned the repository:

```sh
git fetch origin
git switch codex/ios-redesign
git pull --ff-only
```

Use Flutter stable with Dart 3.12.2 or newer. This change was developed with
Flutter 3.44.8 / Dart 3.12.2. Install Xcode, open it once to finish its setup,
and install an iOS Simulator runtime through Xcode Settings → Components.
Run `flutter doctor -v` and resolve its Xcode/iOS toolchain findings.

## Validate and run

```sh
flutter pub get
flutter analyze
flutter test
open -a Simulator
flutter devices
flutter run -d <simulator-device-id>
```

Replace `<simulator-device-id>` with the ID reported by `flutter devices`.
For a compile-only Simulator check, use:

```sh
flutter build ios --simulator --debug
```

The Xcode project already uses Flutter's generated Swift Package Manager
integration. Let Flutter generate `ios/Flutter/ephemeral/` locally; do not copy
that generated directory between machines. If Flutter requests CocoaPods for a
plugin fallback, follow the toolchain guidance printed by Flutter.

For native debugging, open `ios/Runner.xcworkspace` after `flutter pub get`.
Deployment target is iOS 15.0. Simulator testing does not need App Store
submission or distribution signing. Before a real-device or App Store build,
configure your own signing team and final bundle identifier in Xcode. The
existing `com.example.fintrack` identifier is intentionally unchanged here.

## What to test

- Create a goal, choose its emoji and deadline, then edit it.
- In goal details, compare Daily, Weekly and Monthly saving amounts. Monthly
  means one contribution per 30-day period. The calculation includes today and
  the deadline, and updates from the remaining balance. It does not move money.
- Deposit enough to cross 25%, 50%, 75% or 100%; a milestone dialog appears.
  Withdrawing money updates milestones to the current balance. Overdue goals
  ask for a new deadline instead of suggesting an impossible saving pace.
- Try an excessive withdrawal and an invalid target; neither should save.
- Check the Activity chart, transaction filters and search.
- Change currency, language (English/Urdu), appearance and balance visibility.
  Currency changes labels; it does not convert amounts. Hidden balances also
  hide chart values.
- Enable daily reminders, allow notification permission, choose a time and
  verify a notification. Permission denial should show a recoverable message.
- Restart the app and confirm that goals, entries and preferences persist.
- Delete a goal only when intended: its transaction history is also removed.

## Data and verification limits

Existing `fintrack.db`, preference keys, notification IDs and platform IDs are
preserved. No migration, account, cloud service, advertising, subscription or
paid feature was added. Savings-plan and milestone values are derived from
existing goal records.

Automated widget tests cover small screens, light/dark appearance, English/Urdu,
form validation, deposits, milestone dialogs and withdrawals, using an in-memory
test repository. Model tests cover date boundaries, overdue/completed goals and
milestone calculations. Native SQLite, notification delivery, Swift compilation
and Simulator/device behavior must still be validated on your Mac; this work
was performed on Windows.

The landing page retains its previous screenshot until you approve new device
screenshots. `tools/capture_home.dart` can render a development preview with
example goals; this is not an App Store device screenshot.

## Savings Goals 1.2 design and sharing checks

The app name is Savings Goals; platform IDs and the local database remain unchanged.
Both platforms use the bundled SavingsSans font and the same header/card widgets.
The root applies explicit light/dark system-bar icon styles, and page content uses
one SafeArea around the scroll view. Validate real notch/camera-cutout devices,
Android gesture/three-button navigation, keyboard resizing and iPad split views.

The original animated sprout grows with aggregate progress. Tap it to replay its
spring animation. Animations honor the operating system's reduced-motion setting.
The seven-day strip and streak derive only from dated deposits; opening the app,
withdrawals and future entries do not generate streak days.

Open a goal → Share your progress. The preview excludes amounts, transaction
notes and dates. Goal names are off by default and can be opted in. The Share
progress card button opens the native Android/iOS share sheet with a PNG and a
short caption. The user selects a destination and sends it themselves. Verify
this on the Android phone and on iPhone/iPad; app-specific target behavior depends
on installed sharing apps. No social login or automatic posting was added.

Visual reference: https://play.google.com/store/apps/details?id=me.pocketpal.app&hl=en
Reference screenshots were inspected for colour hierarchy and playful visual
feedback; no competitor assets are included in the app.
