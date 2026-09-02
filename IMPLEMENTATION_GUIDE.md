# Implementation Guide — Weather Activity Suitability

## 1. Purpose

This document translates the architectural decisions in `TECHNICAL_PLAN.md` into concrete implementation guidance.

The goal is to allow multiple engineers to work on different parts of the application while maintaining consistent architectural boundaries.

---

# 2. Project Structure

The project structure follows a feature-oriented MVVM pattern with lightweight Domain, Data, Services, and Core separation:

```text
WeatherSuitability/
│
├── App/
│   └── WeatherSuitabilityApp.swift
│
├── Core/
│   ├── Networking/
│   ├── Extensions/
│   ├── Utilities/
│   └── Constants/
│
├── Features/
│   ├── CitySearch/
│   │   ├── Model/
│   │   ├── View/
│   │   │   └── CitySearchView.swift
│   │   └── ViewModel/
│   │       └── CitySearchViewModel.swift
│   │
│   └── Forecast/
│       ├── Model/
│       ├── View/
│       │   └── ForecastView.swift
│       └── ViewModel/
│           └── ForecastViewModel.swift
│
├── Domain/
│   └── Suitability/
│
├── Services/
│
├── Data/
│   ├── Responses/
│   └── Mappers/
│
├── Resources/
│
└── Tests/
    ├── Domain/
    │   └── Suitability/
    ├── CitySearch/
    ├── Forecast/
    └── Data/
```

---

# 3. Layer Rules

## Features (Presentation)

Contains feature-oriented MVVM modules:

* SwiftUI Views under `Features/<Feature>/View/`
* Feature ViewModels under `Features/<Feature>/ViewModel/`
* Presentation-specific state

Must not:

* Build URL requests directly
* Decode JSON
* Implement activity scoring

---

## Domain

Contains shared business and domain concepts:

* Domain models under `Domain/Models/`
* Suitability business logic and rules under `Domain/Suitability/`

Must not depend on:

* SwiftUI
* URLSession
* Open-Meteo API response models
* UI-specific types

The Domain layer should be independently testable.

---

## Services

Contains service abstractions and implementations used by ViewModels to fetch data or perform operations.

---

## Data

Contains API data objects and mapping logic:

* API Responses under `Data/Responses/`
* Response → Domain mapping under `Data/Mappers/`

The Data layer is responsible for mapping external response formats into domain models.

---

## Core

Contains generic infrastructure required by multiple parts of the application:

* `Networking/`
* `Extensions/`
* `Utilities/`
* `Constants/`

Avoid putting business logic here.

---

# 4. Domain Models

Initial domain models should represent application concepts rather than API response structures.

Example:

```swift
struct Location {
    let name: String
    let country: String?
    let administrativeArea: String?
    let latitude: Double
    let longitude: Double
}
```

Forecast domain models should contain only the weather information required by the application.

Example conceptually:

```text
Forecast
 └── [DailyForecast]

DailyForecast
 ├── date
 ├── temperature
 ├── precipitation
 ├── snowfall
 ├── windSpeed
 └── weatherCondition
```

The exact model should be driven by the API fields actually required by the scoring rules.

---

# 5. API Response Models

API response models should mirror the external API response where necessary.

Example:

```text
GeocodingResponse
 └── results

LocationResponse
 ├── name
 ├── latitude
 ├── longitude
 ├── country
 └── admin1
```

Forecast response models should similarly represent the Open-Meteo forecast response.

Response models must not be passed directly to SwiftUI views.

---

# 6. Mapping

Use explicit mapping between API response models and Domain models.

```text
Open-Meteo Response
      ↓
Mapper
      ↓
Domain Model
```

This isolates the application from changes in the external API response format.

---

# 7. Service Abstractions

Services should be exposed through protocols.

Example:

```swift
protocol GeocodingService {
    func searchCity(_ query: String) async throws -> [Location]
}

protocol ForecastService {
    func forecast(
        latitude: Double,
        longitude: Double
    ) async throws -> Forecast
}
```

Concrete implementations should handle URL construction, networking, decoding, and mapping.

---

# 8. Networking

Use `URLSession`.

The networking implementation should:

1. Create the request.
2. Execute it asynchronously.
3. Validate the HTTP response.
4. Decode the response.
5. Map the response into domain models.
6. Convert failures into appropriate application errors.

Avoid putting networking code directly inside ViewModels.

---

# 9. City Search Implementation

The search flow should be:

```text
User Input
    ↓
Debounce
    ↓
Cancel Previous Task
    ↓
GeocodingService
    ↓
[Location]
    ↓
ViewModel
    ↓
SwiftUI List
```

The ViewModel should own the search Task.

When a new query is entered, the previous Task should be cancelled.

Empty queries should not trigger API requests.

---

# 10. Forecast Implementation

When the user selects a location:

```text
Location
 ├── latitude
 └── longitude
        ↓
ForecastService
        ↓
Forecast
        ↓
Suitability Engine
```

The forecast service should not know anything about activities.

It should only provide weather information.

---

# 11. Activity Design

Activities should be modeled through a common abstraction.

Conceptually:

```swift
protocol ActivityScoringRule {
    var activity: Activity { get }

    func calculateScore(
        for forecast: DailyForecast
    ) -> SuitabilityResult
}
```

The exact protocol can be refined during implementation.

Each activity should provide its own scoring logic.

For example:

```text
SkiingScoringRule
SurfingScoringRule
OutdoorSightseeingScoringRule
IndoorSightseeingScoringRule
```

The suitability engine coordinates these rules.

---

# 12. Adding a New Activity

Adding a future activity such as Cycling should involve:

### Step 1

Add the activity definition.

### Step 2

Create:

```text
CyclingScoringRule
```

### Step 3

Define its weather factors and scoring logic.

### Step 4

Register/provide the new scoring rule to the suitability engine.

### Step 5

Add unit tests.

The existing API and generic UI should not require significant changes.

---

# 13. Suitability Result

A suitability result should contain enough information for the UI to render the result without knowing how the score was calculated.

Conceptually:

```text
SuitabilityResult
 ├── activity
 ├── score
 ├── rating
 └── reasons
```

For example:

```text
Activity: Outdoor Sightseeing
Score: 88
Rating: Good

Reasons:
- Comfortable temperature
- Low precipitation
- Moderate wind
```

---

# 14. Scoring Rules

The scoring engine should produce a value between:

```text
0–100
```

Each activity may use different weather factors and weights.

The calculation should be:

* Deterministic
* Explainable
* Testable
* Independent of UI

Avoid embedding scoring calculations inside SwiftUI views or ViewModels.

---

# 15. ViewModel Responsibilities

## CitySearchViewModel

Responsible for:

* Search text
* Search state
* Debouncing
* Cancellation
* Calling GeocodingService
* Exposing locations to the UI
* Handling errors

It should not:

* Build API URLs
* Decode JSON
* Calculate suitability scores

---

## ForecastViewModel

Responsible for:

* Selected location
* Forecast loading
* Calling ForecastService
* Passing forecast data to the suitability engine
* Exposing suitability results
* Handling errors

It should not contain individual activity scoring algorithms.

---

# 16. UI Screens

## City Search Screen

Should provide:

* Search input
* Search results
* Loading state
* Empty state
* Error state

Example:

```text
Search city

[ Ahmedabad              ]

Ahmedabad, India
Ahmedabad, Gujarat
...
```

---

## Forecast / Results Screen

Should provide:

* Selected city
* Seven-day forecast
* Activity suitability
* Score
* Rating
* Reasons where available

The UI should make it easy to understand which activities are most suitable.

---

# 17. Application State

Represent loading/error/content states explicitly.

Conceptually:

```swift
enum ViewState {
    case idle
    case loading
    case loaded
    case empty
    case error
}
```

The exact state model can differ between screens if required.

Avoid using multiple unrelated Boolean properties such as:

```swift
isLoading
hasError
hasData
isEmpty
```

when a single state model can represent the state more clearly.

---

# 18. Error Handling

Convert low-level errors into meaningful application errors.

Example:

```text
Network unavailable
Server error
Invalid response
Unable to decode forecast
No locations found
No forecast available
```

The ViewModel decides what state the UI should display.

The SwiftUI view is responsible only for presenting that state.

---

# 19. Dependency Injection

Services should be injected into ViewModels.

Example conceptually:

```text
CitySearchViewModel
        │
        ▼
GeocodingService
```

During production:

```text
OpenMeteoGeocodingService
```

During tests:

```text
MockGeocodingService
```

This allows ViewModels to be tested without making real API calls.

---

# 20. Testing

## Suitability Tests

These are the highest-priority tests.

Test:

* High suitability
* Low suitability
* Boundary values
* Rating classification
* Activity-specific behavior
* Multiple weather combinations

---

## Activity Rule Tests

Each activity's scoring rule should have independent tests.

Example:

```text
Given heavy rain
When calculating outdoor suitability
Then the score should decrease appropriately
```

---

## ViewModel Tests

Test:

* Search success
* Search failure
* Empty search
* Forecast success
* Forecast failure
* Loading state
* Error state

Use mocked services.

---

## API Tests

Use JSON fixtures to test:

* Successful decoding
* Missing fields where applicable
* Unexpected response structures

Avoid relying entirely on live APIs for unit tests.

---

# 21. Concurrency Guidelines

Use Swift Concurrency rather than callback-based APIs.

Search:

```text
New Query
   ↓
Cancel Previous Task
   ↓
Debounce
   ↓
Perform Search
```

Forecast:

```text
Location Selected
   ↓
Async Forecast Request
   ↓
Calculate Results
   ↓
Update UI State
```

Cancelled tasks should not incorrectly update the UI with stale results.

---

# 22. UI / Domain Separation

The SwiftUI layer should consume presentation-ready results.

Avoid:

```text
SwiftUI View
   ↓
Calculate snowfall score
   ↓
Calculate temperature score
   ↓
Calculate activity score
```

Prefer:

```text
Forecast
   ↓
Suitability Engine
   ↓
SuitabilityResult
   ↓
ViewModel
   ↓
SwiftUI
```

---

# 23. Performance Guidelines

Avoid unnecessary:

* API calls
* SwiftUI recomputation
* Work on the main thread
* Duplicate forecast requests

Search should be debounced and cancellable.

Suitability calculations should remain lightweight and deterministic.

---

# 24. Accessibility Guidelines

The UI should support:

* Dynamic Type
* VoiceOver
* Accessibility labels
* Appropriate contrast
* Clear textual ratings

Do not rely exclusively on color to communicate suitability.

Use:

```text
88 — Good
```

rather than communicating the result only through a colored indicator.

---

# 25. Git Workflow

Work should be committed incrementally.

Example:

```text
docs: add technical implementation plan

chore: initialize iOS project

feat: add domain models

feat: implement suitability engine

feat: implement geocoding service

feat: implement forecast service

feat: add city search UI

feat: add forecast UI

feat: add activity suitability results

feat: add loading and error states

test: add suitability engine tests

test: add view model tests

refactor: improve activity scoring architecture

docs: update README
```

The actual commit history should reflect meaningful development stages.

---

# 26. Definition of Done for a Feature

A feature is considered complete when:

* Implementation follows the defined architecture.
* No business logic is embedded in SwiftUI views.
* Dependencies are injectable where required.
* Error and loading states are handled.
* Appropriate unit tests are included.
* No unnecessary third-party dependency is introduced.
* Code is reviewed for readability and maintainability.
* The application builds successfully.
* Existing tests continue to pass.
* Documentation is updated when an architectural decision changes.

---

# 27. Developer Workflow

A developer picking up a task should follow:

```text
Understand requirement
       ↓
Check Technical Plan
       ↓
Check Implementation Guide
       ↓
Identify affected layer
       ↓
Implement smallest focused change
       ↓
Add/update tests
       ↓
Run application
       ↓
Run test suite
       ↓
Review architecture boundaries
       ↓
Commit focused change
```

---

# 28. Relationship Between Documents

The two documents have different purposes.

```text
TECHNICAL_PLAN.md
        │
        │  Architectural decisions
        │  Requirements
        │  Assumptions
        │  Trade-offs
        ▼
IMPLEMENTATION_GUIDE.md
        │
        │  Concrete boundaries
        │  Models
        │  Services
        │  ViewModels
        │  Testing
        ▼
     Source Code
```

`TECHNICAL_PLAN.md` explains **why the system is designed this way**.

`IMPLEMENTATION_GUIDE.md` explains **how engineers should implement it consistently**.
