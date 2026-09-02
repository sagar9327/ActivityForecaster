# Activity Suitability Skill

## Purpose

Define how activity-specific suitability logic must be implemented while keeping the system extensible.

The application currently supports:

* Skiing
* Surfing
* Outdoor sightseeing
* Indoor sightseeing

Future activities should be addable without significant changes to existing activities or unrelated layers.

---

## Core Principle

Activity-specific business logic belongs in the Domain layer.

Do not place activity scoring logic inside:

* SwiftUI Views.
* ViewModels.
* API services.
* Networking code.

---

## Activity Abstraction

Activities should follow a common abstraction so that the suitability engine can work with activities generically.

The exact implementation may use a protocol, strategy pattern, or another appropriate design, but the abstraction must allow each activity to define its own scoring behavior.

Conceptually:

```text
Activity
   ↓
Activity Scoring Rule
   ↓
Suitability Result
```

---

## Activity-Specific Rules

Each activity should have isolated scoring logic.

Conceptually:

```text
SkiingScoringRule
SurfingScoringRule
OutdoorSightseeingScoringRule
IndoorSightseeingScoringRule
```

Each rule should:

* Identify the activity.
* Determine relevant weather factors.
* Apply activity-specific scoring logic.
* Produce a generic suitability result.

---

## Suitability Result

The result should contain enough information for the UI to display the outcome without knowing how the score was calculated.

Conceptually:

```text
SuitabilityResult
 ├── Activity
 ├── Score
 └── Rating
```

The result should be independent of SwiftUI.

---

## Score

Scores must be normalized to:

```text
0–100
```

The scoring logic should be:

* Deterministic.
* Explainable.
* Testable.
* Activity-specific.

Avoid arbitrary randomness or opaque calculations.

---

## Rating

The default rating classification is:

```text
90–100  Excellent
75–89   Good
50–74   Fair
25–49   Poor
0–24    Very Poor
```

Keep rating classification separate from the UI.

---

## Weather Factors

Different activities may use different weather factors.

### Skiing

Potential factors:

* Snowfall.
* Temperature.
* Wind.
* Weather conditions.
* Precipitation.

### Surfing

Potential factors:

* Wind.
* Weather conditions.
* Precipitation.
* Temperature.

Surfing suitability must clearly acknowledge that weather data alone does not represent complete surf quality.

### Outdoor Sightseeing

Potential factors:

* Temperature.
* Precipitation.
* Weather conditions.
* Wind.

### Indoor Sightseeing

Potential factors:

* Precipitation.
* Temperature.
* Weather conditions.
* Wind.

The scoring rules should document why each factor is used.

---

## Adding a New Activity

When adding a new activity such as Cycling:

### Step 1

Add the activity definition.

### Step 2

Create a dedicated scoring rule.

Example:

```text
CyclingScoringRule
```

### Step 3

Define the weather factors and weights.

### Step 4

Register/provide the scoring rule to the suitability engine.

### Step 5

Add unit tests.

### Step 6

Verify that existing activities remain unchanged.

---

## What Must NOT Happen

Do not implement a growing centralized switch such as:

```swift
switch activity {
case .skiing:
    ...
case .surfing:
    ...
case .outdoor:
    ...
case .indoor:
    ...
case .cycling:
    ...
}
```

if adding every new activity requires modifying a large central scoring implementation.

Do not create separate ViewModels for each activity unless a genuine feature requirement justifies it.

Do not duplicate forecast/networking logic for individual activities.

---

## Generic UI

The UI should consume activities generically.

Adding a new activity should not require creating a completely new results screen.

Conceptually:

```text
[Activity]
[Score]
[Rating]
[Reasons]
```

The same UI structure should be capable of rendering any supported activity.

---

## Testing

Every activity must have dedicated unit tests.

Tests should cover:

* Favorable conditions.
* Unfavorable conditions.
* Boundary values.
* Score range.
* Rating classification.
* Important combinations of weather factors.
* Explanation/reason generation where applicable.

When a new activity is introduced, its scoring rules must be tested before the feature is considered complete.

---

## Extensibility Check

Before completing an activity implementation, ask:

1. Can another activity be added without changing existing scoring rules?
2. Can the UI display the new activity generically?
3. Does the new activity reuse existing forecast data?
4. Is its scoring logic independently testable?
5. Does the suitability engine remain generic?

If the answer to any of these is no, reconsider the design before proceeding.

---

## Important Principle

Adding a new activity should primarily be an **addition**, not a modification of unrelated existing behavior.

Prefer:

```text
Add:
  New Activity
  New Scoring Rule
  New Tests
```

over:

```text
Modify:
  Existing Activities
  Existing UI
  Networking
  ViewModels
  Central Calculator
```
