# Development Phases

This document defines the current development phase, the overall implementation sequence, and the completion criteria for each phase.

The AI coding assistant must always read this document before starting implementation work.

The current phase is the source of truth for what should be implemented next.

---

# Current Phase

## Phase 4 — Open-Meteo Networking

**Status:** 🚧 In Progress

Refer to the **Phase 4 — Open-Meteo Networking** section under Implementation Sequence for detailed scope, testing requirements, and completion criteria.

---

# Implementation Sequence

## Phase 1 — Planning & Architecture

**Status:** ✅ Completed

### Objectives

* Understand the assignment.
* Define technology choices.
* Define architecture.
* Define project structure.
* Define activity suitability approach.
* Define scoring approach.
* Define networking strategy.
* Define testing strategy.
* Establish development guidelines.

### Key Decisions

* Platform: iOS
* Language: Swift
* UI: SwiftUI
* Architecture: MVVM
* Concurrency: Swift Concurrency (`async/await`)
* Networking: URLSession
* Testing: XCTest
* API: Open-Meteo

### Commit

`chore: initialize iOS project`

---

## Phase 2 — Initial Setup

**Status:** ✅ Completed

Establish and verify the project foundation.

---

## Phase 3 — Domain Models & Suitability Engine

**Status:** ✅ Completed

Implement the core domain layer independently of SwiftUI, networking, and API response models.

---

## Phase 4 — Open-Meteo Networking

**Status:** 🚧 In Progress

### Objectives

Implement the core domain layer independently of SwiftUI, networking, and Open-Meteo-specific API response models.

Expected areas include:

* Location
* Forecast
* Daily forecast
* Activity
* Suitability result
* Rating
* Activity-specific scoring rules
* Suitability engine

The suitability engine must remain testable and extensible.

Adding a new activity should primarily require adding the activity and its scoring rule rather than modifying a large centralized conditional or switch statement.

### Testing

Add unit tests for:

* Domain models where appropriate.
* Rating calculation.
* Suitability scores.
* Activity-specific scoring rules.
* Edge cases.

### Suggested Commit

`feat: add domain models and suitability engine`

---

## Phase 4 — Open-Meteo Networking

**Status:** ⏳ Not Started

### Objectives

Implement:

* Open-Meteo geocoding service.
* Open-Meteo forecast service.
* API Response models.
* Response-to-domain mapping.
* Networking abstractions/protocols.
* Error handling.

Networking implementation must remain isolated from the domain layer.

Use URLSession and Swift Concurrency.

### Testing

Add tests for:

* Response model decoding.
* Mapping.
* Networking behavior using mocks where appropriate.
* Error handling.

Do not depend on live APIs for unit tests.

### Suggested Commit

`feat: implement Open-Meteo networking`

---

## Phase 5 — City Search

**Status:** ⏳ Not Started

### Objectives

Implement the city search feature using the Open-Meteo geocoding API.

The feature should support:

* Search-as-you-type.
* Debouncing.
* Cancellation of previous searches.
* Loading state.
* Empty state.
* Error state.
* Search results.
* City selection.
* Retaining the selected city's coordinates.

The selected latitude and longitude will be used for forecast retrieval.

### Suggested Commit

`feat: add city search`

---

## Phase 6 — Forecast & Suitability Flow

**Status:** ⏳ Not Started

### Objectives

Connect:

```text
Selected City
     ↓
Coordinates
     ↓
Forecast API
     ↓
7-Day Forecast
     ↓
Suitability Engine
     ↓
Activity Results
     ↓
Ranked Results
```

Implement the required ViewModel/application flow while keeping business logic inside the domain layer.

### Suggested Commit

`feat: connect forecast and suitability flow`

---

## Phase 7 — SwiftUI UI & UX

**Status:** ⏳ Not Started

### Objectives

Build the user-facing SwiftUI experience.

The UI should provide:

* City search.
* Search results.
* Selected city.
* 7-day suitability information.
* Activity ranking.
* Daily comparison.
* Loading states.
* Empty states.
* Error handling.
* Clear suitability scores and ratings.

The UI should remain generic enough that adding another activity does not require significant UI changes.

### Suggested Commit

`feat: add weather suitability UI`

---

## Phase 8 — Testing & Quality

**Status:** ⏳ Not Started

### Objectives

Complete the test suite across the important layers.

Prioritize:

1. Suitability/domain logic.
2. Activity scoring rules.
3. ViewModels using mocks.
4. Response model decoding and mapping.
5. Important UI flows where appropriate.

Tests should be deterministic and should not depend on live APIs.

### Suggested Commit

`test: add core application tests`

---

## Phase 9 — Review, Performance & Accessibility

**Status:** ⏳ Not Started

### Objectives

Perform a final engineering review.

Check:

* Architecture.
* Dependency direction.
* Code duplication.
* Error handling.
* Concurrency.
* Cancellation.
* Performance.
* Memory behavior.
* SwiftUI rendering.
* Accessibility.
* User experience.
* Unnecessary complexity.

Remove unnecessary code and abstractions.

### Suggested Commit

`refactor: improve application quality and accessibility`

---

## Phase 10 — Documentation & Submission

**Status:** ⏳ Not Started

### Objectives

Prepare the final submission.

Verify:

* README reflects the actual implementation.
* Architecture is documented.
* Suitability algorithm is documented.
* Assumptions are documented.
* Trade-offs are documented.
* Known limitations are documented.
* AI usage is documented where appropriate.
* Git history clearly represents the development process.
* Repository can be cloned and built successfully.
* Tests pass from a clean checkout.
* No unnecessary files or secrets are committed.

### Final Verification

Perform a clean build and test before submission.

Verify that the public GitHub repository contains everything required to build and evaluate the application.

---

# Development Rules

These rules apply to all phases.

## 1. Follow the Current Phase

Do not implement functionality belonging to future phases unless explicitly requested.

If a future-phase requirement is discovered while working on the current phase, document it rather than implementing it prematurely.

## 2. Read Project Documentation

Before making significant implementation decisions, consult:

* `TECHNICAL_PLAN.md`
* `IMPLEMENTATION_GUIDE.md`
* Relevant files under `SKILLS/`

## 3. Preserve Architecture

Do not bypass the defined architecture for convenience.

If the architecture needs to change, explain the reason and update the relevant documentation deliberately.

## 4. Keep Changes Focused

Each phase should contain only the work necessary for that phase.

Avoid speculative abstractions and unnecessary infrastructure.

## 5. Test Incrementally

When implementing functionality, add appropriate tests as part of the relevant phase rather than postponing all testing until the end.

## 6. Verify Before Finishing

Before declaring a phase complete:

* Build the application.
* Run relevant tests.
* Review changed files.
* Confirm no unrelated functionality was introduced.

## 7. Git Commits

Do not automatically commit changes unless explicitly requested.

When a phase is complete, provide a suggested commit message.

Commit messages should describe the actual change rather than artificially matching the phase number.

---

# Phase Status Legend

* ✅ Completed
* 🚧 In Progress
* ⏳ Not Started
* ⚠️ Blocked

Update the status when moving between phases.

Only one implementation phase should normally be marked **In Progress** at a time.
