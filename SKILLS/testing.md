# Testing Skill

## Purpose

Ensure new functionality is testable and that changes do not silently break existing behavior.

Testing should prioritize business-critical logic and important application state transitions.

---

## Testing Principles

Tests should be:

* Deterministic.
* Independent.
* Readable.
* Focused.
* Fast.
* Repeatable.

Avoid tests that depend on external network availability unless they are explicitly integration tests.

---

## Testing Priority

Prioritize testing in this order:

1. Domain/business logic.
2. Activity scoring rules.
3. ViewModels.
4. Data mapping/decoding.
5. UI behavior where valuable.

The suitability engine is the highest-priority area because it contains the primary business logic.

---

## Domain Tests

Domain logic must be testable without:

* SwiftUI.
* URLSession.
* Open-Meteo.
* Network access.

Tests should provide domain inputs directly.

Example:

```text
DailyForecast
      ↓
Suitability Rule
      ↓
Suitability Result
```

---

## Activity Tests

Every activity scoring rule must have dedicated tests.

For each activity, test:

### Favorable conditions

Verify that favorable weather produces an appropriately high score.

### Unfavorable conditions

Verify that unfavorable weather produces an appropriately low score.

### Boundaries

Verify behavior around important thresholds.

### Score range

Ensure scores remain between:

```text
0 and 100
```

### Rating

Verify that the correct rating is produced for representative scores.

---

## Example Test Intent

```text
Given comfortable temperature,
low precipitation,
and moderate wind

When calculating outdoor sightseeing suitability

Then:
- score should be within the expected range
- rating should match the score
- expected reasons should be present
```

The exact thresholds should follow the documented scoring rules.

---

## ViewModel Tests

ViewModels should use injected service abstractions.

Test:

* Successful request.
* Empty result.
* Network failure.
* API failure.
* Loading state.
* Successful state.
* Error state.
* Retry behavior where implemented.
* Cancellation/stale-result behavior where relevant.
* Memory leak safety via `trackForMemoryLeaks(viewModel)`.

### Memory Leak Verification

Every ViewModel unit test suite must include a `testMemoryLeak()` test method using `trackForMemoryLeaks(_:)`:

```swift
func testMemoryLeak() {
    let viewModel = CitySearchViewModel(geocodingService: mockService)
    trackForMemoryLeaks(viewModel)
}
```

This automatically asserts that ViewModel instances are cleanly deallocated from memory upon test teardown without retain cycles.

Example:

```text
MockGeocodingService
        ↓
CitySearchViewModel
        ↓
State
```

No real network call should be required.

---

## Data Tests

Use JSON fixtures to test:

* Successful decoding.
* Expected response structures.
* Optional/missing values where supported.
* Mapping from Response model to Domain model.

Tests should verify that API-specific structures are correctly converted into domain models.

---

## Networking Tests

Where appropriate, test:

* HTTP success.
* HTTP failure.
* Invalid responses.
* Decoding failure.

Use mocks or URL loading abstractions rather than depending on live APIs.

---

## UI Tests

UI tests should be used selectively for important user journeys.

Potential critical flow:

```text
Search City
    ↓
Select Location
    ↓
Load Forecast
    ↓
Display Suitability
```

Do not create UI tests for every small visual detail.

---

## Regression Testing

When modifying existing business logic:

1. Run the existing test suite.
2. Add regression tests for the changed behavior.
3. Verify existing activities remain unaffected.
4. Verify the new behavior does not introduce architectural coupling.

---

## Adding a New Activity

When adding a new activity, tests must be added for:

```text
New Activity
      +
Scoring Rule
      +
Score boundaries
      +
Rating
      +
Important edge cases
```

Existing activity tests should continue to pass.

---

## Test Naming

Test names should describe behavior rather than implementation.

Prefer:

```text
testOutdoorSightseeingScoreDecreasesWithHeavyRain()
```

over:

```text
testCalculatorMethod1()
```

---

## Test Independence

Tests must not depend on:

* Test execution order.
* Shared mutable global state.
* Network availability.
* Specific machine configuration.
* Previously executed tests.

Each test should establish its own required state.

---

## Before Completing a Change

Verify:

* [ ] New business logic has tests.
* [ ] New activity has scoring tests.
* [ ] Error paths are covered.
* [ ] Important edge cases are covered.
* [ ] Existing tests pass.
* [ ] Tests do not require live APIs.
* [ ] Tests remain deterministic.
* [ ] No production-only behavior is hidden from tests.

---

## Important Principle

A feature is not complete merely because the application works manually.

The implementation should also demonstrate that its important behavior can be verified automatically.
