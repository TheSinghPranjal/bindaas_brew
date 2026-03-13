# Copilot / AI Agent Instructions — bindaas_brew

Short guide to help AI coding agents be immediately productive in this Flutter repo.

1) Project snapshot
- Flutter app (Dart) — entry point: `lib/main.dart`.
- Lightweight project scaffolding present: `lib/config`, `lib/features`, `lib/widgets`, `lib/shared_folder`, `lib/custom_component` (currently empty). Use these folders for feature placement.

2) High-level architecture & where to implement features
- Authentication: implement under `lib/features/auth/` (e.g. `login_page.dart`, `google_auth.dart`). After login show a mode chooser screen at `lib/features/auth/mode_choice.dart`.
- User & RBAC: place models in `lib/shared_folder/models/` (e.g. `user.dart`) and services in `lib/shared_folder/services/` (e.g. `user_service.dart`). Role-based UI lives under `lib/features/{admin,manager,restaurant,customer}/`.
- Manager / Product / Category UIs: implement under `lib/features/manager/` (e.g. `dashboard.dart`, `categories.dart`, `products.dart`).

3) Developer workflows (explicit commands)
- Fetch deps: `flutter pub get`
- Run on connected device/emulator: `flutter run`
- Run tests: `flutter test`
- Android build (from repo root): `cd android && ./gradlew assembleDebug`
- iOS: open `ios/Runner.xcworkspace` in Xcode to run/profile on simulator/device.

4) Project conventions you should follow
- Keep models in `lib/shared_folder/models/` and JSON mock data in `assets/data/` (add the assets path to `pubspec.yaml`).
- Feature folders under `lib/features/<feature>/` contain UI, small local widgets and a service/provider for state.
- Shared UI widgets go in `lib/widgets/`. Custom platform components (if needed) go in `lib/custom_component/`.
- Keep services (data loading, auth, RBAC checks) in `lib/shared_folder/services/` and prefer simple synchronous mocks for early work (replaceable by real backends later).

5) Concrete examples & patterns to implement (use these exact paths)
- Mock users JSON: `assets/data/users.json` — load via `rootBundle.loadString()` and parse into `User` model at `lib/shared_folder/models/user.dart`.
- Super Admin dashboard: `lib/features/admin/super_admin_dashboard.dart` — implement scrollable cards that show profile photo, name, designation, employeeId. Clicking a card opens `lib/features/admin/role_assignment_panel.dart`.
- Mode choice after login: `lib/features/auth/mode_choice.dart` — show modal with two buttons: Customer / Restaurant.

6) Search & filters (behavioural notes)
- Super Admin search fields: support searching by `name`, `username`, `employeeId`, `designation` — implement simple client-side filtering on the loaded mock JSON.
- Product / Category screens: allow search by product name and a category filter. If a product lacks a category show `Category: New / Unassigned`.

7) Authentication & federated login
- No auth code exists yet; for Google sign-in, prefer `google_sign_in` plugin and put integration helpers in `lib/features/auth/google_auth.dart` so it can be swapped for other providers.

8) Mock data for initial work
- Add 20 hardcoded users into `assets/data/users.json` using the required fields (employeeId, name, username, mobile, alternateMobile, email, designation, role, photo, about, age, languages, joiningDate, status, address, emergencyContact). Example object (trimmed):
```json
{
  "employeeId":"EMP001",
  "name":"Rahul Sharma",
  "username":"rahul",
  "mobile":"9876543210",
  "designation":"Manager",
  "role":"Manager",
  "age":32,
  "languages":["English","Hindi"]
}
```

9) Tests & validation
- Put widget/unit tests under `test/features/` mirroring feature folders. Write at least one test for parsing the mock users JSON and one widget test for the mode chooser.

10) When to ask the human
- If an integration choice must be made (e.g., Firebase vs custom OAuth), ask which provider to use.
- If UI/branding is required beyond basic Material widgets (colors, assets), ask for design assets.

Notes
- The repo currently contains the default Flutter starter app and empty feature folders — place new files into the paths above so other contributors and future automation will find them.
- Be conservative: prefer creating new files under the named folders rather than editing `lib/main.dart` beyond wiring the initial router.

If this looks good I will create the initial file tree and add a sample `assets/data/users.json` with 20 mocked users and a minimal `User` model + loader; tell me to proceed. 
