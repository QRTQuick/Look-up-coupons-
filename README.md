# Look Up Coupons

Offline-first Flutter app for discovering nearby deals, coupons, and promotions. All data is stored locally in SQLite with no backend, server, or Firebase.

Features
- Geolocation-based deals sorted by proximity
- Deals feed with categories, distance filters, and search
- Favorites stored locally in SQLite
- Daily local notifications for new or expiring deals
- Google Maps view for nearby deals
- Optional Business Panel to add/edit/remove deals on device
- Light and dark themes
- Offline caching with placeholder images

Project Structure
- lib/main.dart
- lib/models/
- lib/providers/
- lib/screens/
- lib/services/
- lib/widgets/

Quick Start (Android)
1. Install Flutter and Android toolchain.
2. Add your Google Maps API key in tooling/android/google_maps_api.xml.
3. Generate Android scaffolding and apply the manifest template:
   scripts/setup_android.sh
   scripts/setup_android.ps1 (Windows)
4. Install dependencies:
   flutter pub get
5. Generate app icons:
   flutter pub run flutter_launcher_icons:main
6. Run the app:
   flutter run

CI/CD
- GitHub Actions builds the Android APK on every push.
- The workflow generates Android scaffolding, applies the manifest template, and builds a release APK.

Notes
- Location and notification permissions are requested in-app under Settings.
- Seed data is inserted on first launch so you can test offline immediately.
