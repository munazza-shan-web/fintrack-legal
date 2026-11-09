# Savings Goals

A 100% free personal savings tracker, built as a nonprofit initiative for **AILANGA SCHOOL PROJECT**. Public website: **SaveGoals.site**.

## App

Cupertino app with iOS-style navigation, goals, deposits and withdrawals, daily/weekly/monthly savings plans, milestone tracking, activity reports, optional local daily reminders, English/Urdu, four display currencies, and light/dark themes. See [Mac setup and testing](MAC_SETUP.md). Savings records stay in the on-device SQLite database. Currency selection changes labels, not exchange rates.

```sh
flutter pub get
flutter test
flutter analyze
flutter run
```

The SDK minimum is Dart 3.12.2, matching this checkout's installed Flutter 3.44.8. Existing preferences are retained; new installs start in dark mode with USD display currency. Internal package names, platform application IDs, notification-channel IDs, and `fintrack.db` remain stable to preserve existing app identity and stored savings during upgrades.

## App redesign — 1.3.0

Version 1.3.2 applies navigation B: only the active destination has a horizontal label, while all four destinations keep accessibility labels and actions. Home's small header symbol is removed. The chosen lilac-pot sprout is the launcher identity, and a borderless lime launch screen shows a three-dot loader during real initialization. Native Android/iOS launch backgrounds match; reduced motion is respected. No artificial launch delay is added.

Version 1.3.1 adds live comma grouping and amount-in-words hints for target and savings entries, a prominent Home streak card, a floating blurred navigation capsule, explicit root-tab back-button handling, equally sized tappable monthly activity summaries, and a persisted Black appearance alongside Dark and Light.

The approved visual direction is implemented with bundled Manrope typography, forest-charcoal surfaces, lime actions, lilac/peach goal accents, compact shared navigation, a sprout companion, circular goal progress, category selection, savings keypad, live balance previews, milestone celebrations, and private share cards. Android and iOS use the same widgets; native safe areas, share sheets, notification permissions, and keyboards remain platform-specific.

Per the latest instruction the app remains free. **Settings → Preview trial screen** opens the minimal US/UK paywall design. It is explicitly a visual preview: there is no purchase SDK, payment gate, real trial, or subscription charge. The two prices are samples. The preview has one Restore purchases link and a Done control so users can leave it in this free version.

Manrope is bundled under the SIL Open Font License in `assets/fonts/Manrope-OFL.txt`. See `output/redesign-1.3/` for screenshots rendered from the actual widgets. Native iOS compilation still requires a Mac.

## Selected logo

The newly selected **Savings Goals** sprout icon is retained unchanged at `assets/branding/selected_sprout_source.png`. App launcher sizes are derived from this source. The transparent `sprout_lockup.png` is used directly on the lime splash background, without an icon tile or frame. The older typography-only source remains at `save_goals_logo_source.png` for the existing website branding.

```sh
dart run tools/build_app_brand.dart
dart run flutter_launcher_icons
```

The full-bleed app icon is 1024 × 1024. An inset adaptive version protects the full words from Android masks.

## Plain HTML website

Open `index.html`, or serve this directory with any static HTTP server. No build step, JavaScript, external fonts, analytics, or cookies are required. Upload these files together:

- `index.html`, `styles.css`, `privacy-policy.html`, `terms-and-conditions.html`
- `assets/branding/save_goals_icon.png`, `favicon.png`, `apple-touch-icon.png`

The landing page includes a capture of the actual Flutter home-screen widgets with labelled example amounts, existing app features, the nonprofit purpose, FAQs, legal links and support. The App Store badge remains unlinked until a real listing URL is provided. The nonprofit is AILANGA SCHOOL PROJECT and support is jiyoo7480@gmail.com; no individual publisher name is displayed. The privacy page describes the current code, optional operating-system backups, external links, website hosting logs, and support email.

App legal links target `https://savegoals.site/privacy-policy.html` and `https://savegoals.site/terms-and-conditions.html`; upload the site and configure the domain before distributing this app build. Files are prepared locally; this change does not publish the domain or submit an App Store release. iOS compilation, signing, and device validation still require the appropriate Apple build environment and account.

Apple's privacy disclosures must match the version submitted: [App privacy details](https://developer.apple.com/app-store/app-privacy-details/) and [App Review Guidelines, privacy](https://developer.apple.com/app-store/review/guidelines/#privacy).

## Landing page hero assets

The hero uses the App Store badge supplied by the user and a Google Play badge from https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png. Both badges currently link to `#availability`; replace those URLs with the real store listings when published.

The home-screen image is rendered directly from the app widgets with sample goals, using `flutter test tools/capture_home.dart`. It is a static screenshot, not a live emulator session or a cloud-connected app. The capture tool loads the Flutter SDK's Roboto font; set `FLUTTER_ROOT` if Flutter is installed somewhere other than `C:\flutter`.

Include `assets/store-badges/` and `assets/screenshots/home-screen.png` when uploading the website. The website ZIP already includes these files.

## Upload package and responsive layout fix

Run `python tools/package_site.py` after editing the website sources. The generated pages in `output/save-goals-website/` embed their stylesheet and images, avoiding missing relative assets and stale external styles after upload. Upload the generated `index.html`, `privacy-policy.html`, and `terms-and-conditions.html` together to your public web root, replacing the old pages. The editable root sources still use ordinary CSS and image files.

The packaged landing page was checked in a browser at 320, 375, 390, 680, 768, 1024 and 1440 pixels, with no horizontal overflow or broken images. Both legal pages were also checked at 320 pixels. The live domain could not be verified because DNS resolution for savegoals.site failed from this machine; no hosted files were modified.

## Savings Goals 1.2

Savings Goals uses shared Flutter layout and bundled fonts on Android and iOS,
with explicit status-bar contrast and safe-area padding. Animated progress and an
original sprout companion honor reduced-motion settings. Real deposit dates power
the saving streak and seven-day strip.

Goal details include an optional progress-card preview and native image sharing.
Amounts, transaction dates and notes are excluded; goal names are opt-in. Read
MAC_SETUP.md for cross-platform and native-sharing checks. No automatic posting,
accounts, subscriptions or advertising are included.
