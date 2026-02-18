
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
- **Backend:** Supabase REST API (Dio). Data stored in Supabase (orders, products, clients).

## How to run

1. Clone the repo, then: `flutter pub get`
2. Add your Firebase config (e.g. `flutterfire configure` or place `google-services.json` / `GoogleService-Info.plist`).
3. **Supabase:** In `lib/core/supabase_config.dart`, set `supabaseAnonKey` to your project’s anon key (Project Settings → API → anon public).
4. Run: `flutter run`

## Project structure

- **Domain** — Models (Order, Product, Client) and repository interfaces
- **Data** — DTOs, API classes (Dio), repository implementations, Riverpod providers
- **Controllers** — Riverpod AsyncNotifier for each feature
- **UI** — Screens under `lib/features/screens/`