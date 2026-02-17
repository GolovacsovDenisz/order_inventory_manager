
# Order & Inventory Manager

Flutter app for small business: manage **orders**, **products**, and **clients** with authentication.

## Features

- **Auth** — Firebase (email/password), sign in / create account, auth redirect
- **Orders** — Full CRUD, status workflow (New → In Progress → Done / Cancelled), search, filter by status, sort by date/total/status, multi-select and batch delete
- **Products** — Full CRUD (name, price, stock, notes), list with pull-to-refresh
- **Clients** — Full CRUD (name, phone, email, notes), list with pull-to-refresh
- **Settings** — Sign out

## Tech stack

- Flutter, Dart
- **State:** Riverpod (AsyncNotifier)
- **Navigation:** go_router (auth redirect, bottom nav shell)
- **Auth:** Firebase Auth
- **Backend:** REST API (Dio); currently configured for mock API (e.g. mockapi.io). Ready to swap to Firebase Firestore or another backend by changing the data layer only.

## How to run

1. Clone the repo, then: `flutter pub get`
2. Add your Firebase config (e.g. `flutterfire configure` or place `google-services.json` / `GoogleService-Info.plist`).
3. If using a mock API: set the base URL in `lib/core/dio_client.dart`. Create resources for `/orders`, `/products`, `/clients` with the expected fields.
4. Run: `flutter run`

## Project structure

- **Domain** — Models (Order, Product, Client) and repository interfaces
- **Data** — DTOs, API classes (Dio), repository implementations, Riverpod providers
- **Controllers** — Riverpod AsyncNotifier for each feature
- **UI** — Screens under `lib/features/screens/`