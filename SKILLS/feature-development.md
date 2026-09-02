# Feature Development Skill

## Purpose

Provide a consistent process for implementing new features while preserving the architecture defined for the application.

---

## Before Implementation

Before writing code:

1. Understand the feature requirement.
2. Identify the user interaction.
3. Identify the required input and output.
4. Identify business rules.
5. Identify error scenarios.
6. Identify affected architectural layers.
7. Inspect existing implementations for reusable components.
8. Determine what tests are required.

Do not immediately start coding before understanding where the feature belongs.

---

## Feature Design

For every new feature, determine:

```text
User Interaction
      ↓
Presentation
      ↓
ViewModel
      ↓
Domain / Service
      ↓
Data / API
```

Only introduce layers that are actually required.

Do not create unnecessary abstractions for simple functionality.

---

## Existing Code First

Before creating a new component:

* Search for an existing service.
* Search for an existing model.
* Search for an existing protocol.
* Search for existing error handling.
* Search for existing UI components.
* Search for existing utilities.

Extend or reuse existing components when appropriate.

Do not duplicate functionality.

---

## Domain Changes

If the feature introduces a new business concept:

1. Define the concept in the Domain layer.
2. Keep business rules independent from UI.
3. Make the concept independently testable.
4. Avoid coupling the concept to API-specific structures.

---

## Data Changes

If the feature requires external data:

1. Identify the required API information.
2. Add or extend DTOs.
3. Implement/extend the appropriate service.
4. Map DTOs into Domain models.
5. Keep API-specific details inside the Data layer.

Do not expose external API structures to the Presentation layer.

---

## ViewModel Changes

ViewModels should:

* Coordinate the feature.
* Manage UI state.
* Call service abstractions.
* Transform domain data into presentation data when necessary.
* Handle asynchronous operations.

ViewModels should not:

* Build raw API requests.
* Decode JSON.
* Contain business scoring algorithms.
* Directly depend on API DTOs.

---

## SwiftUI Changes

SwiftUI Views should:

* Render state.
* Handle user interaction.
* Trigger ViewModel actions.
* Display domain/presentation results.

SwiftUI Views should not:

* Perform networking.
* Decode JSON.
* Calculate business scores.
* Contain activity-specific business rules.

---

## State Management

Explicitly consider:

* Idle state.
* Loading state.
* Success state.
* Empty state.
* Error state.

Avoid multiple unrelated Boolean flags when a clear state model can represent the UI state.

---

## Error Handling

Every feature should consider:

* Network failures.
* Invalid data.
* Empty results.
* Unexpected API responses.
* Cancellation.
* User retry.

Errors should be converted into meaningful application-level errors where appropriate.

---

## Concurrency

Use Swift Concurrency (`async/await`) for asynchronous operations.

When implementing user-driven requests:

* Consider cancellation.
* Avoid stale results.
* Avoid duplicate requests.
* Avoid blocking the main thread.

For search functionality, use debouncing and cancellation.

---

## Testing

Every feature should identify the appropriate tests before implementation is considered complete.

At minimum, consider:

* Business logic tests.
* ViewModel tests.
* Error scenarios.
* Empty states.
* Important edge cases.

Use dependency injection and mocks where required.

---

## Feature Completion Checklist

Before considering a feature complete:

* [ ] Requirement implemented.
* [ ] Correct architectural layer used.
* [ ] Existing abstractions reused where appropriate.
* [ ] No duplicated responsibility.
* [ ] Loading state handled.
* [ ] Empty state handled.
* [ ] Error state handled.
* [ ] Cancellation considered.
* [ ] Business logic tested.
* [ ] Existing tests pass.
* [ ] UI reviewed for accessibility.
* [ ] Documentation updated if an architectural decision changed.

---

## Important Rule

Do not solve a feature by bypassing the architecture simply because it is faster.

If an architectural exception is genuinely necessary, explain the reason and document the trade-off.
