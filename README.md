# isitiyaGarden

*Growing local. Connecting communities.*

A Flutter mobile app that makes the produce of smallholder farmers in rural
Eastern Cape communities visible to nearby buyers. Farmers advertise what they
currently have available, and buyers discover it, then contact the farmer
directly by call, WhatsApp or SMS.

It is **not** a marketplace. There are no payments, carts, delivery or logistics
(see the SRS, section 3.2).

Built for Application Technology IV.

## Features

**Farmer**
- Register, log in, manage a farm profile
- Add produce with a photo, quantity and unit, price (or "negotiable"),
  availability dates, general location and intended buyer types
- Edit listings, mark produce unavailable, deactivate or reactivate listings

**Buyer**
- Register, log in, choose a buyer type, manage a profile
- Browse produce near their community, search by name, filter by category,
  availability and community
- View full details and the farmer's information
- See whether a listing is aimed at their buyer type
- Contact the farmer by call, WhatsApp or SMS

## Tech stack

| Layer | Choice |
|---|---|
| App | Flutter (Android), Dart |
| State management | Riverpod |
| Backend | Supabase: PostgreSQL, Auth, Storage |
| Security | Row Level Security policies, check constraints, triggers |
| Packages | `supabase_flutter`, `flutter_riverpod`, `image_picker`, `url_launcher`, `shared_preferences` |

## Project structure

```
lib/
  app/        App root, theme and design tokens
  core/       Shared widgets, validators and utilities
  features/
    auth/     Splash, onboarding, login, registration, profiles
    buyer/    Home, search, filters, buyer shell
    farmer/   Dashboard, add/edit produce, manage listings
    produce/  Produce model, repository, details, contact sheet
    profile/  Buyer and farmer profile screens
test/         Unit and widget tests
docs/         Requirements traceability, database security tests, demo script
```

Each feature separates screens (`presentation`), Supabase access
(`data`, repositories) and data classes (`models`), so one part can change
without affecting the others (NFR07).

## Setup

### 1. Supabase
1. Create a project at supabase.com.
2. In the SQL Editor, run `docs/isitiyagarden_schema.sql`, then the demo data from
   `docs/isitiyagarden_seed_and_tests.sql` (Part 1).
3. Authentication > Providers > Email: turn **Confirm email off** while
   developing.
4. Copy the **Project URL** and the **publishable key** from
   Project Settings > API Keys.

### 2. Flutter
```bash
flutter pub get
cp env.example.json env.json      # then fill in your URL and key
flutter run --dart-define-from-file=env.json
```

`env.json` is ignored by Git. Never put the Supabase secret / service_role key
in the app or in this repository.

### 3. Build a release APK
```bash
flutter build apk --release --dart-define-from-file=env.json
```
The file is created in `build/app/outputs/flutter-apk/app-release.apk`.

## Tests

```bash
flutter analyze
flutter test
```

Database security is tested separately: paste `docs/isitiyagarden_security_tests.sql`
into the Supabase SQL Editor. It checks that buyers cannot change farmers' data,
farmers cannot change each other's listings, roles cannot be changed, and
logged-out users see nothing.

## Requirements

`docs/SRS_traceability.md` links every functional requirement (FR01-FR25) and
non-functional requirement (NFR01-NFR10) to the code that implements it and the
test that verifies it.

## Known limitations

- Android only.
- Edits to a listing and its buyer types are not a single database transaction
  (the app cleans up after failures). A database function would be stricter.
- No request timeouts on very poor connections.
- Email confirmation is off for development and should be on in production.
- No automated end-to-end tests against the live backend.
- Out of scope by design: payments, delivery, ratings and reviews, chat,
  recommendations, national marketplace features.

## Author

Simamkele Yawa
