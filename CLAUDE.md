# Breeze — Claude Instructions

macOS SwiftUI menu bar app (Swift/SwiftUI + AppKit). Xcode project — do not build or run; developer handles that manually.

## Stack

Swift / SwiftUI + AppKit · `UserDefaults` persistence via `SettingsStore` · Open-Meteo REST API (no key) · No third-party dependencies

<important if="you are working with settings, preferences, or persistent state">
- Settings flow through `SettingsStore` (ObservableObject). Persist via `@Published` `didSet` → `UserDefaults`.
- Temperature is always stored internally in Fahrenheit. Convert at display time via `SettingsStore.formatTemperature`.
</important>

<important if="you are working with ThresholdMonitor, notifications, or location changes">
- `ThresholdMonitor` is stateful — one instance lives on `AppDelegate`. Reset it when location or threshold changes.
</important>

<important if="you are working with WeatherService or the Open-Meteo API">
- `WeatherService` is a stateless enum with static async methods.
</important>

<important if="you are writing Swift code with arrays or collections">
- Do not use `+` for array concatenation — use `append` or `appending`.
</important>

<important if="you are writing unit tests">
- Tests should be self-documenting — no comments needed.
</important>
