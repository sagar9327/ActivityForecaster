# Architecture Skill

## Purpose

Follow the architectural decisions defined in `TECHNICAL_PLAN.md` and `IMPLEMENTATION_GUIDE.md` whenever creating or modifying code.

The application must remain simple, testable, maintainable, and extensible.

---

## Before Making Changes

Before implementing a feature or modifying existing functionality:

1. Read `TECHNICAL_PLAN.md`.
2. Read `IMPLEMENTATION_GUIDE.md`.
3. Identify the affected architectural layer.
4. Inspect existing code and abstractions before creating new ones.
5. Reuse existing components where appropriate.
6. Avoid changing unrelated code.
7. Consider whether the change affects existing architectural boundaries.

---

## Architectural Layers

The application follows these layers:

### Presentation

Contains:

* SwiftUI Views
* ViewModels
* Presentation state

### Domain

Contains:

* Domain models
* Business rules
* Activity definitions
* Suitability calculation
* Suitability results

### Data

Contains:

* API DTOs
* API services
* JSON decoding
* DTO-to-Domain mapping

### Core

Contains:

* Shared infrastructure
* Networking primitives
* Common utilities

---

## Dependency Rules

Dependencies should follow these boundaries:

```text
Presentation
     ↓
Domain

Presentation
     ↓
Service Abstractions

Data
     ↓
Domain

Core
     ↓
Shared Infrastructure
```

The following are prohibited:

* Domain depending on SwiftUI.
* Domain depending on URLSession.
* Domain depending on Open-Meteo DTOs.
* SwiftUI Views directly calling URLSession.
* SwiftUI Views directly calling Open-Meteo APIs.
* SwiftUI Views decoding JSON.
* ViewModels decoding API responses.
* ViewModels containing activity-specific scoring algorithms.

---

## Separation of Concerns

### SwiftUI Views

Views are responsible for:

* Rendering UI.
* User interaction.
* Presenting state.
* Navigation.

Views must not contain business logic.

### ViewModels

ViewModels are responsible for:

* Managing presentation state.
* Handling user actions.
* Coordinating services.
* Managing asynchronous operations.
* Preparing data for the UI.

ViewModels must not contain activity-specific scoring algorithms.

### Domain

Domain is responsible for:

* Business rules.
* Activity scoring.
* Suitability calculation.
* Domain models.

Domain logic must remain independent of UI and networking.

### Data

Data is responsible for:

* API communication.
* DTOs.
* Decoding.
* Mapping external data into domain models.

---

## API Isolation

Open-Meteo-specific models must remain inside the Data layer.

Do not expose API DTOs to:

* SwiftUI Views.
* ViewModels.
* Domain services.

Use:

```text
API DTO
   ↓
Mapper
   ↓
Domain Model
```

---

## Dependency Injection

Prefer dependency injection for services that require testing.

Use protocols where they provide a meaningful testing or architectural boundary.

Avoid creating concrete services directly inside ViewModels when doing so makes testing difficult.

---

## Abstraction Guidelines

Do not introduce abstractions simply for the sake of abstraction.

Before creating a new:

* Protocol
* Service
* Manager
* Factory
* Repository
* Utility

check whether an existing abstraction already provides the required behavior.

Prefer the simplest design that satisfies the architectural requirements.

---

## Extensibility

When implementing a new feature, consider whether the design allows future requirements without modifying unrelated components.

For activity-related functionality, follow `activity-suitability.md`.

Adding a new activity should primarily involve adding its definition and scoring rules rather than modifying existing activity implementations.

---

## Code Quality

Generated or modified code should:

* Follow existing naming conventions.
* Follow Swift conventions.
* Prefer small focused types.
* Avoid duplicated logic.
* Avoid force unwraps unless clearly justified.
* Avoid unnecessary global state.
* Avoid unrelated refactoring.
* Keep responsibilities clear.

---

## Before Completing a Change

Verify:

* Correct architectural layer.
* Correct dependency direction.
* No business logic in Views.
* No API DTO leakage.
* Existing abstractions were considered.
* New logic is testable.
* Relevant tests were added or updated.
* No unrelated architectural changes were introduced.
