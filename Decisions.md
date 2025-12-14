## Architectural and Implementation Decisions

- Speed was prioritised as limited time was available, to get a quick MVP working. 

- Platform & Language
  - Chosen Swift with Swift Concurrency (async/await) to simplify networking and improve readability over callback-based approaches.
  - Prefer Foundation URLSession for HTTP calls to avoid third‑party dependencies and keep the footprint small.

- Project Structure
  - Feature-first grouping: Screens/Features are grouped with their view, view model, models, and related services to keep context local and reduce cross‑module coupling.
  - A dedicated Networking module encapsulates API clients, request building, decoding, and error handling.

- Networking
  - Token-based authentication  is injected via an Authorization: Bearer header.
  - A single APIClient handles request execution, response status mapping, and JSON decoding using Codable.
  - Lightweight Request/Endpoint types define paths, query parameters, and HTTP method to keep calls consistent and testable.
  - Errors are normalized into an AppError enum that distinguishes transport, decoding, and API-specific issues.

- Caching & Performance
  - URLCache is used for HTTP response caching where appropriate to reduce network usage.
  - Image loading is done via URLSession with in-memory caching (NSCache) to avoid re-downloading common posters and backdrops.
  - Pagination support for lists to avoid large payloads and keep scrolling smooth.

- UI Layer
  - SwiftUI for declarative UI and simple state management with Observable and @State/@StateObject.
  - ViewModels expose simple state (loading, data, error) and perform async operations; Views remain presentation-focused.
  - Accessibility considerations: Dynamic Type friendly layouts, content labels for images, and semantic grouping.

- Testing
  - Networking is abstracted behind protocols to allow mocking API responses.

- Configuration & Secrets
  - API credentials are excluded from version control; AccessKeys is a local-only file.
  - Build configurations reference environment-specific settings where needed, enabling easy switch between mock and live APIs.

- Error Handling & Resilience
  - User-facing errors are human-readable and actionable (e.g., “Check your network connection” or “Try again”).

- Extensibility
  - Models closely mirror TMDB entities but are wrapped in app-specific types when needed to avoid leaking API details into the UI.
  - Endpoint definitions are centralized so adding new features (search, details, similar titles) requires minimal boilerplate.

- Trade-offs
  - Avoided third-party dependencies for networking and image loading to keep maintenance low.
  - Chose SwiftUI for speed of iteration and clarity.
