# Breeze

macOS menu bar app that monitors outdoor temperature and notifies you when it crosses a threshold — so you know when to open or close your windows.

## Features

- Live temperature in the menu bar (updates on a configurable interval)
- Threshold alerts with custom notification messages for crossing above or below
- Cooldown between alerts to avoid notification spam
- City search via geocoding (no API key needed)
- Fahrenheit/Celsius toggle
- Free weather data from [Open-Meteo](https://open-meteo.com/)

## Requirements

- macOS 13 Ventura or later
- Xcode 15+

## Setup

1. Open `Breeze.xcodeproj` in Xcode
2. Select your team in Signing & Capabilities
3. Build and run (⌘R)

## Usage

Click the thermometer icon in the menu bar to see current temperature and threshold. Open **Settings** (⌘,) to:

- Set your location by city name
- Choose a temperature threshold
- Customize alert messages
- Configure poll interval and cooldown

Use **Test Alert** from the menu to preview notifications without waiting for a threshold crossing.

## Architecture

| File | Role |
|------|------|
| `BreezeApp.swift` | App entry point, menu bar label |
| `AppDelegate.swift` | Poll timer, notification delivery, settings window |
| `SettingsStore.swift` | `UserDefaults`-backed settings with F/C conversion |
| `WeatherService.swift` | Open-Meteo fetch + geocoding |
| `ThresholdMonitor.swift` | Edge-detection logic with cooldown |
| `MenuBarContentView.swift` | Menu bar dropdown UI |
| `SettingsView.swift` | Settings form |
| `OverlayView.swift` / `OverlayWindowController.swift` | Overlay window |
