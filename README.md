# Smart Pump 2.0 🌊

A premium, modern Flutter application for remotely monitoring and controlling
agricultural water pumps — built for Indian farmers and pump owners.

Smart Pump 2.0 is a ground-up reimagining of the "remote pump control app"
category (inspired by, but visually and architecturally independent from,
existing apps like SSP RMS). It focuses on a clean Material 3 design,
richer analytics, real automation, and two AI-assisted farm advisor tools
on top of the core pump-control experience.

---

## ✨ Feature Overview

| Area | What's included |
|---|---|
| **Dashboard** | Animated tank level, pump status with start/stop/emergency-stop, quick stats grid, weather + irrigation tip, recent alerts, quick actions |
| **Analytics** | 5 tabs (Water / Energy / Runtime / Motor / Solar) × 4 time filters, interactive `fl_chart` line charts, efficiency score, month-over-month comparison, PDF/Excel export hooks |
| **Automation** | Tank auto-fill (low/high % thresholds), weekly scheduler (add/edit/delete slots), seasonal modes (Summer/Monsoon/Winter), rain mode, AI suggestions |
| **Alerts** | Timeline UI with severity colour-coding, filter chips (All/Unread/Warnings/Critical), mark-as-read, multi-channel prefs (Push/SMS/WhatsApp) |
| **Profile** | Profile card, multi-pump summary, preferences (language/theme/notifications), device management, maintenance shortcut, support/FAQ/about |
| **Maintenance module** | Reminders, service history, warranty tracking, technician directory, spare-part records |
| **Multi-pump support** | Bottom-sheet pump switcher (Farm Pump / Home Pump / Village Tank Pump) with live status per pump |
| **🌱 Crop Disease Library** | Searchable library of Kharif & Rabi crop diseases (cotton, soybean, tur, groundnut, wheat, gram, mustard, orange) with symptoms/causes/treatment/prevention, plus a camera-based "scan a leaf" identification flow |
| **💧 AI Irrigation Advisor** | Location + soil-type + crop onboarding (remembered on-device), then a daily watering recommendation (litres, duration, reasoning) with a **Start Pump** action right next to it |
| **Auth** | Mobile+OTP login, MPIN login, biometric login, remember-device |
| **i18n** | English, Hindi (हिंदी), Marathi (मराठी) |
| **Theming** | Full light/dark Material 3 theme, teal/green brand palette |

---

## 🧱 Tech Stack

- **Flutter** (Material 3)
- **flutter_riverpod** — state management (Notifier/AsyncNotifier/FutureProvider/StreamProvider)
- **go_router** — declarative navigation with a `StatefulShellRoute` bottom-nav shell
- **hive / hive_flutter** — local persistence (settings, session, remembered farm profile)
- **firebase_core / firebase_messaging** — push notification scaffold (see setup below)
- **fl_chart** — analytics charts
- **google_fonts, percent_indicator, shimmer, lottie** — visual polish
- **image_picker** — crop disease "scan a leaf" camera/gallery capture
- **pdf / printing, share_plus** — export hooks for analytics reports

---

## 📁 Project Structure

```
lib/
  core/
    constants/        # app-wide constants (Hive keys, durations, thresholds)
    theme/             # AppColors, AppTextStyles, AppTheme (light + dark)
    router/            # GoRouter config (StatefulShellRoute bottom nav)
    localization/      # lightweight custom i18n (en/hi/mr)
    utils/             # validators, date/number formatting
  models/              # plain Dart data models (Pump, Tank, Alert, User, Farm,
                        # Analytics, Schedule, Weather, Maintenance, Device,
                        # Disease, IrrigationAdvisory)
  services/            # ABSTRACT service interfaces — see "Plugging in the
                        # real API" below
    mock/              # in-memory mock implementations used today
  providers/           # Riverpod providers/notifiers, one file per concern
  features/
    splash/
    auth/
    shell/             # bottom-nav scaffold (MainShell)
    home/
    analytics/
    automation/
    alerts/
    profile/
    maintenance/
    disease_library/   # NEW: crop disease library + camera scan
    irrigation_advisor/ # NEW: AI watering recommendation
  widgets/             # shared, reusable UI (AppCard, EmptyState, shimmer, etc.)
test/                  # unit tests for models & mock services
```

This is a standard **clean architecture** split: `models` are pure data,
`services` are abstract contracts, `mock/` are swappable implementations,
`providers` wire services into the UI, and `features` are UI-only.

---

## 🔌 Plugging in the real hardware/controller API

Every screen depends on an **abstract interface**, never a concrete mock:

```dart
abstract class PumpService {
  Future<PumpModel> turnPumpOn(String pumpId);
  Future<PumpModel> turnPumpOff(String pumpId);
  Future<PumpModel> getPumpStatus(String pumpId);
  Stream<PumpModel> watchPumpStatus(String pumpId);
  // ...
}
```

To go live with the existing controller vendor's backend:

1. Create `lib/services/api/api_pump_service.dart` implementing `PumpService`
   (same for `AnalyticsService`, `NotificationService`, `UserService`,
   `CropDiseaseService`, `IrrigationAdvisoryService`).
2. Open **`lib/providers/service_providers.dart`** and change **one line**:

   ```dart
   final pumpServiceProvider = Provider<PumpService>((ref) => ApiPumpService());
   ```

No screen, widget or provider needs to change. This is the single
integration seam for the whole app.

### About the two AI features & "connecting to Claude"

You asked whether the app can call Claude directly — yes, but **not from
inside the Flutter client**. LLM API keys must never be embedded in a
shipped mobile app (they'd be trivially extractable). The correct pattern:

```
Flutter app  →  your own backend (Cloud Function / small server)  →  Claude API
```

- **Crop Disease Library "scan a leaf"**: `CropDiseaseService.identifyFromImage()`
  already returns ranked `DiseaseMatch` results — wire your backend to accept
  the uploaded photo, call a vision-capable model (a Claude model with an
  image content block, or a specialised plant-pathology model) with a prompt
  asking for structured JSON (`{disease, confidence}[]`), and map the
  response into `DiseaseMatch` objects. The UI needs zero changes.
- **AI Irrigation Advisor**: `IrrigationAdvisoryService.getRecommendation()`
  already takes the farmer's saved location/soil/crop and returns a
  structured `IrrigationRecommendation` (litres, duration, reasoning). Your
  backend can fetch real weather/soil-moisture data for the coordinates and
  ask an LLM to turn that into the plain-language `reasoning` string.

Both abstract services and their doc-comments spell this out in code —
see `lib/services/crop_disease_service.dart` and
`lib/services/irrigation_advisory_service.dart`.

---

## 🔥 Firebase Cloud Messaging setup

The push-notification scaffolding is in place but commented out until you
connect a real Firebase project (there's nothing to configure a mock
against):

1. `flutterfire configure` in the project root — this generates
   `lib/firebase_options.dart` and platform config files.
2. In `lib/main.dart`, uncomment:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
3. Implement `ApiNotificationService.registerDeviceToken()` to send the FCM
   token to your backend so it can target this device.

---

## 🌐 Localization

A lightweight, hand-rolled i18n system lives in `lib/core/localization/`
(`AppLocalizations` + `translations.dart`) so the project **compiles without
a codegen step**. Call sites look like:

```dart
Text(context.l10n.t('home'))
```

To add a string: add the key to all three maps in `translations.dart`
(`en`, `hi`, `mr`). For a larger production app, swap this for
`flutter gen-l10n` + ARB files — the call sites (`context.l10n.t(...)`)
can stay identical if you keep a thin wrapper.

---

## 🎨 Design system

- **Primary teal** `#009688`, **secondary green** `#4CAF50`,
  **warning** `#FF9800`, **danger** `#F44336`
- 16–20px rounded corners everywhere (`AppTheme.radiusMd/Lg`)
- Full Material 3 `ColorScheme.fromSeed`, light + dark
- Poppins for headings, Inter for body (via `google_fonts`), with a
  Devanagari fallback for Hindi/Marathi
- Shimmer skeletons instead of bare spinners; consistent empty states;
  pull-to-refresh everywhere data is fetched

---

## 🚀 Getting started

> **This archive contains Dart/Flutter source only** (`lib/`, `test/`,
> `pubspec.yaml`) — it does not include the generated `android/`, `ios/`,
> `web/`, `windows/`, `macos/`, `linux/` platform folders, since those are
> large, machine-generated, and platform-toolchain-specific. Generate them
> once on your dev machine:

```bash
# 1. Unzip, then from the project root:
flutter create .        # generates android/ ios/ web/ etc. in place,
                         # without touching your lib/ or pubspec.yaml
flutter pub get
flutter run              # or: flutter build apk
```

If `flutter create .` prompts about overwriting `pubspec.yaml`, say no —
it only needs to add the missing platform folders.

```bash
flutter pub get
flutter run
```

The app runs entirely on **mock data** out of the box — no backend, no
Firebase project, no API keys required to explore every screen.

### Running tests

```bash
flutter test
```

---

## 🧪 What's mocked vs. real hardware, for reference

While designing the mock pump/device data, real Crompton solar-pump
controller nameplates (RMU ID, IMEI, model `CSCMDC-5.0-S`, 5HP/30M motor,
4.8kWp Alpex Solar array) were used as a reference so the **Device
Management** screen in Profile reflects genuine field hardware fields
instead of placeholder text. Swap `MockUserService.getDeviceInfo()` for a
real lookup once the controller's own API/QR registration flow is
available.

---

## 📌 Known stubs / next steps

- PDF/Excel export in Analytics returns a fake file path — wire up `pdf` +
  `printing` (already a dependency) for real report generation.
- `local_auth` biometric prompt is not yet called from the UI layer —
  `AuthNotifier.loginWithBiometrics()` is the seam to call
  `LocalAuthentication().authenticate()` before restoring the session.
- "Use current location" in the Irrigation Advisor is simulated — swap in
  the `geolocator` package for real GPS + reverse geocoding.
- WhatsApp notification channel is UI-ready but marked "Coming soon" since
  it depends on the WhatsApp Business API being provisioned.
