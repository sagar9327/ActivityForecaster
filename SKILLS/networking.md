# Networking Skill

## Purpose

Define how external API communication must be implemented.

The current application uses Open-Meteo APIs for:

* Geocoding.
* Weather forecasting.

Networking must remain isolated from the Presentation and Domain layers.

---

## Networking Responsibility

The Data layer is responsible for:

* Creating API requests.
* Executing requests.
* Validating HTTP responses.
* Decoding JSON.
* Mapping Response models to Domain models.
* Translating low-level failures into appropriate errors.

---

## URLSession

Use Apple's `URLSession` for HTTP communication.

Do not introduce a third-party networking framework unless there is a clear requirement and the architectural trade-off is documented.

---

## Service Abstractions

Services should be exposed through protocols where dependency injection and testing require an abstraction.

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

Concrete implementations remain in the Data layer.

---

## API Response Models

API response models must remain in the Data layer (`Data/Responses/`).

For example:

```text
GeocodingResponse
LocationResponse
ForecastResponse
```

Do not expose these response models to ViewModels or Domain logic.

---

## Mapping

Always map external API models into application/domain models.

```text
Open-Meteo JSON
      ↓
API Response
      ↓
Mapper
      ↓
Domain Model
```

The Domain layer must not know about Open-Meteo's response format.

---

## HTTP Validation

Network requests should validate the HTTP response before decoding.

At minimum, handle:

* Successful responses.
* HTTP errors.
* Invalid responses.
* Decoding errors.

Do not assume that a successful network request always means valid application data.

---

## Error Handling

Convert low-level failures into meaningful application-level errors.

Potential errors:

```text
Network unavailable
Request failed
Server error
Invalid response
Decoding failed
No data available
```

Do not expose raw implementation details to the UI unless useful.

---

## Search Requests

City search must support:

* Empty-query prevention.
* Debouncing.
* Cancellation.
* Latest-query-wins behavior.

Do not send an API request for every keystroke.

Conceptually:

```text
User Input
    ↓
Debounce
    ↓
Cancel Previous Request
    ↓
Geocoding Service
```

---

## Forecast Requests

The forecast request should use the coordinates returned by the selected location.

Do not perform another geocoding request after a location has already been selected.

```text
Selected Location
      ↓
Latitude + Longitude
      ↓
Forecast API
```

---

## Request Construction

Keep API URL construction and request-specific configuration inside the Data/networking layer.

Do not construct Open-Meteo URLs inside:

* SwiftUI Views.
* ViewModels.
* Domain objects.

---

## API Changes

If Open-Meteo changes its response structure:

1. Update the Response model.
2. Update mapping.
3. Update relevant tests.
4. Avoid changing Domain models unless the application requirement itself has changed.

This minimizes external API coupling.

---

## Testing

Networking code should be testable without requiring live API calls for normal unit tests.

Use:

* Mock services for ViewModel tests.
* JSON fixtures for decoding tests.
* URL loading abstractions/mocks where appropriate.

Live API calls should not be required for the core unit test suite.

---

## Performance

Avoid unnecessary network requests.

Use:

* Debouncing.
* Cancellation.
* Reuse of selected coordinates.
* Appropriate request scoping.

Do not introduce caching unless there is a clear requirement.

---

## Security

Do not introduce secrets or credentials into source code.

The current Open-Meteo integration does not require application secrets.

If a future API requires credentials:

* Do not hardcode secrets in the repository.
* Do not ship server-side secrets inside the application.
* Use an appropriate secure architecture.

---

## Important Rule

Networking should provide data.

Networking should **not** calculate activity suitability.

The responsibility boundary is:

```text
Networking
   ↓
Forecast Data
   ↓
Domain
   ↓
Suitability Calculation
```
