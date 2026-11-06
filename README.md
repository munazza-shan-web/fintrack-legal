# Save Goals

A 100% free personal savings tracker, built as a nonprofit initiative for **AILANGA SCHOOL PROJECT**. Public website: **SaveGoals.site**.

## App

Cupertino app with iOS-style navigation, goals, deposits and withdrawals, daily/weekly/monthly savings plans, milestone tracking, activity reports, optional local daily reminders, English/Urdu, four display currencies, and light/dark themes. See [Mac setup and testing](MAC_SETUP.md). Savings records stay in the on-device SQLite database. Currency selection changes labels, not exchange rates.

```sh
flutter pub get
flutter test
flutter analyze
flutter run
```

The SDK minimum is Dart 3.12.2, matching this checkout's installed Flutter 3.44.8. Existing preferences are retained; new installs start in light mode. Internal package names, platform application IDs, notification-channel IDs, and `fintrack.db` remain stable to preserve existing app identity and stored savings during upgrades.

## Selected logo

The user-selected **Savings Goals** logo is retained unchanged at `assets/branding/save_goals_logo_source.png`. App and web sizes are derived from this file, preserving its lettering and colors. The previous vector concept is no longer used.

```sh
node tools/build-brand.mjs /absolute/path/to/node_modules/sharp
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
