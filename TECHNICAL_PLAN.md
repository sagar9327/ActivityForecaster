# Technical Plan — Weather Activity Suitability

## 1. Overview

Build a native iOS application using **Swift and SwiftUI** that allows users to search for a city/town and evaluate how suitable the next 7 days are for:

* Skiing
* Surfing
* Outdoor sightseeing
* Indoor sightseeing

The application will use the Open-Meteo Geocoding API to search for locations and the Open-Meteo Forecast API to retrieve weather data.

No backend service is required.

The implementation will focus on a clean, testable, and extensible architecture while keeping the solution appropriately scoped to the exercise.

---

## 2. Goals

The application should:

1. Allow users to search for a city or town.
2. Display matching locations returned by the geocoding API.
3. Allow the user to select a location.
4. Retrieve the forecast for the selected location for the next 7 days.
5. Calculate a suitability score for each activity for each day.
6. Present/rank activities based on suitability.
7. Provide understandable reasons behind suitability scores.
8. Handle loading, empty, and error states.
9. Include automated tests for core business logic.
10. Allow new activities to be added with minimal changes to existing code.

---

## 3. Technology Choices

### Platform

iOS

### Language

Swift

### UI Framework

SwiftUI

### Architecture

MVVM with separation between Presentation, Domain, and Data layers.

### Concurrency

Swift Concurrency (`async/await`)

### Networking

URLSession

### Testing

XCTest

### Dependencies

No third-party dependencies are planned initially.

The solution will prefer Apple's native frameworks to keep the project lightweight and easy to build and run locally.

---

## 4. Architectural Principles

The architecture will follow these principles:

### Separation of concerns

UI, business logic, and networking should remain independently testable.

### Dependency inversion

ViewModels should depend on service abstractions rather than concrete networking implementations.

### API isolation

Open-Meteo-specific DTOs should not leak into the Domain or Presentation layers.

### Extensibility

The suitability engine should allow new activities and their scoring rules to be introduced without significant changes to existing application layers.

### Pragmatism

The architecture should solve the current requirements without introducing unnecessary frameworks or abstractions.

---

## 5. High-Level Architecture

```text
                    ┌─────────────────────┐
                    │      SwiftUI         │
                    │       Views          │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │     ViewModels       │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
        ┌─────────────────┐        ┌────────────────────┐
        │  API Services   │        │ Suitability Engine │
        └────────┬────────┘        └─────────┬──────────┘
                 │                           │
                 ▼                           │
            URLSession                       │
                 │                           │
                 ▼                           │
          Open-Meteo API ────────────────────┘
```

The UI should not communicate directly with the API layer.

The ViewModels coordinate user actions and application state.

The Suitability Engine remains independent of SwiftUI and networking.

---

## 6. Activity Architecture

Activities are a core domain concept and should be scalable.

The initial activities are:

* Skiing
* Surfing
* Outdoor sightseeing
* Indoor sightseeing

The design should avoid a centralized implementation such as:

```text
calculateSkiingScore()
calculateSurfingScore()
calculateOutdoorScore()
calculateIndoorScore()
```

Instead, activity-specific scoring rules should be isolated behind a common abstraction.

Conceptually:

```text
                 Suitability Engine
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
     Skiing           Surfing          Outdoor
      Rules             Rules            Rules
        │                │                │
        └────────────────┼────────────────┘
                         │
                         ▼
                 Suitability Result
```

Adding a future activity such as Cycling should primarily require adding its activity definition and scoring rules.

The existing networking, ViewModels, and generic result UI should not require significant changes.

---

## 7. Suitability Model

Suitability will be represented using a score from **0–100**.

Each activity will use relevant weather factors with activity-specific weights.

Potential factors include:

### Skiing

* Snowfall
* Temperature
* Wind
* Weather conditions
* Precipitation

### Surfing

* Wind
* Weather conditions
* Precipitation
* Temperature

### Outdoor sightseeing

* Temperature
* Precipitation
* Weather conditions
* Wind

### Indoor sightseeing

* Precipitation
* Temperature
* Weather conditions
* Wind

The scoring approach will be deterministic and explainable rather than using machine learning.

---

## 8. Score Classification

```text
90–100  Excellent
75–89   Good
50–74   Fair
25–49   Poor
0–24    Very Poor
```

The application should provide the score along with a human-readable rating.

Where practical, the main contributing weather factors should also be displayed.

---

## 9. Activity Ranking

The domain model should support seven daily suitability results for every activity.

For example:

```text
Outdoor Sightseeing

Wednesday   88  Good
Thursday    72  Fair
Friday      94  Excellent
Saturday    61  Fair
...
```

The UI may additionally provide a daily comparison:

```text
Wednesday

Outdoor Sightseeing   88  Good
Indoor Sightseeing    76  Good
Surfing               42  Poor
Skiing                12  Very Poor
```

This allows both activity-based and day-based views of the same underlying data.

---

## 10. Important Assumptions

The application provides **weather-based suitability**, not guaranteed activity availability.

### Skiing

The application does not verify ski resort availability, lifts, terrain, or resort-specific snow conditions.

### Surfing

The initial score is based on available weather forecast information.

It should not be interpreted as a complete surf-quality forecast without wave, swell, and tide information.

### Outdoor sightseeing

The score represents weather suitability for spending time outdoors.

It does not verify attraction availability or opening hours.

### Indoor sightseeing

The score represents weather suitability for choosing indoor activities.

It does not verify attraction availability or opening hours.

---

## 11. API Strategy

Open-Meteo will be used for:

* Location search
* Weather forecast

The selected location's latitude and longitude will be reused for the forecast request.

The application will not maintain its own city database.

---

## 12. Concurrency Strategy

Swift Concurrency will be used for asynchronous operations.

Search will support:

* Debouncing
* Request cancellation
* Latest-query-wins behavior

Forecast retrieval will be asynchronous and should not block the UI.

---

## 13. Error Handling Strategy

The application should explicitly handle:

* Network failure
* API failure
* Timeout
* Invalid responses
* Decoding errors
* Empty search results
* Missing forecast data

Application-level errors should be presented using meaningful user-facing messages.

---

## 14. Testing Strategy

Testing will prioritize the core business logic.

Primary areas:

* Activity scoring
* Score boundaries
* Rating classification
* Activity-specific rules
* ViewModel state transitions
* API response decoding

The activity architecture should allow each activity's scoring logic to be tested independently.

---

## 15. Performance Strategy

The application will avoid unnecessary work through:

* Search debouncing
* Request cancellation
* Reusing selected coordinates
* Avoiding duplicate API requests
* Keeping calculations independent of UI rendering

The application will remain lightweight because persistence and offline functionality are outside the initial scope.

---

## 16. Architectural Trade-offs

The implementation intentionally avoids:

* Unnecessary third-party frameworks
* Complex dependency injection containers
* Database/persistence layers
* Generic networking frameworks
* Excessive abstraction

The goal is to demonstrate **pragmatic architecture rather than architecture for its own sake**.

At the same time, the domain layer will remain sufficiently isolated to support future activities, testing, persistence, or API changes.

---

## 17. Future Improvements

Potential future extensions include:

* Forecast caching
* Offline support
* Favorite locations
* Additional activities
* Wave/swell/tide information for surfing
* Ski resort data
* More detailed weather visualization
* Personalized recommendations
* Analytics and observability

---

## 18. Definition of Done

The architecture will be considered successfully implemented when:

* All required activities are supported.
* Suitability is calculated for the next seven days.
* Activity scoring is isolated and testable.
* Adding a new activity does not require significant changes to existing layers.
* API implementation is isolated from the Domain and Presentation layers.
* ViewModels remain testable.
* The UI handles loading, empty, and error states.
* Automated tests cover the core business logic.
* The implementation remains focused and maintainable.
