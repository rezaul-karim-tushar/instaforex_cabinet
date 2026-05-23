# Client Cabinet — Flutter Mobile App

## Estimated Time: 18 hours
## Actual Time Spent: 20 hours

---

## Architecture

The project follows **Clean Architecture** with a **feature-based folder structure**.

Each feature is self-contained and organized into three layers:

- **Data** — API calls, models, repository implementations
- **Domain** — Entities, repository interfaces, business logic
- **Presentation** — BLoC/Cubit, pages, widgets

lib/
├── core/               # Shared utilities, constants, theme, network
├── features/
│   ├── auth/           # Login, token management
│   ├── profile/        # User profile display
│   ├── signals/        # Trading signals archive
│   └── promo/          # Promo materials (SOAP)
├── injection_container.dart
└── main.dart

---

## Technical Decisions

### State Management — BLoC + Cubit
Used `flutter_bloc` throughout the app. BLoC was chosen for Auth because
it has multiple distinct events (check session, login, logout). Cubit was
used for Profile, Signals, and Promo since these are simpler load/display
flows that don't require event-driven architecture. This avoids unnecessary
boilerplate while keeping the code consistent.

### Dependency Injection — get_it
`get_it` was used as a service locator. All dependencies are registered
in `injection_container.dart` with clear separation between singletons
and factories. BLoCs and Cubits are registered as factories so a fresh
instance is created per screen.

### Networking — Dio
Two separate Dio instances are maintained — one for the Peanut service
and one for the Partner service — each with its own base URL and timeout
configuration. A third plain Dio instance handles the SOAP service.

### SOAP Handling
The Promo screen communicates via SOAP/XML. The request is built manually
as a raw XML string and the response is parsed using the `xml` package.
Image domains are replaced from `forex-images.instaforex.com` to
`forex-images.ifxdb.com` before rendering.

### Secure Storage
Tokens and login credentials are stored using `flutter_secure_storage`
which uses Android Keystore and iOS Keychain under the hood. On app
start, stored credentials are checked automatically to restore the
session without requiring re-login.

### Token Expiry & Re-authorization
If any API call returns an auth error, the user is redirected to the
login screen and stored credentials are cleared. The app supports
full re-authorization and logout.

---

## Error Handling

Every screen handles three states explicitly:
- **Loading** — shimmer skeleton UI
- **Error** — user-friendly message with retry button
- **Empty** — informative empty state

Network loss is handled gracefully at the Dio level and surfaced
through typed Failure classes (NetworkFailure, ServerFailure, AuthFailure).

---

## Additional Questions

### How would you organize a reusable verification module shared across multiple apps?

I would extract the verification flow into a standalone Dart package
hosted on a private pub server or as a Git submodule. The package would
expose a clean public API — for example a `VerificationFlow` widget or
a `VerificationCubit` — while keeping all internal implementation details
private.

The package would have no dependency on any specific app's routing or
theme. Instead it would accept callbacks and configuration from the host
app. For example:

```dart
VerificationFlow(
  onSuccess: (token) => router.push('/home'),
  onFailure: () => router.push('/error'),
  config: VerificationConfig(baseUrl: Env.verifyUrl),
)
```

This way the same module works across apps without modification.

### Which architectural approaches would you use?

Inside the shared package I would follow the same Clean Architecture
pattern used in this project. The domain layer would be completely
framework-agnostic. State management would use Cubit so the host app
is not forced into a specific BLoC event structure. The package would
expose only domain entities and presentation widgets — nothing internal.

### How would you organize dependency isolation and navigation flow?

Dependencies would be injected from outside using constructor injection,
not hardcoded inside the package. The host app registers its own service
locator entries and passes them in. This avoids version conflicts between
the package and host app dependencies.

For navigation, the package would use callbacks or a Navigator 2.0
compatible RouterDelegate rather than calling `Navigator.push` directly.
This lets each host app handle routing in its own way — whether using
go_router, auto_route, or plain Navigator — without the package caring
about the host app's navigation structure.