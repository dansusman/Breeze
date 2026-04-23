import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    @Published var currentTempF: Double? = nil
    @Published var lastFetchDate: Date? = nil
    @Published var fetchError: String? = nil

    let settingsStore = SettingsStore()

    private let thresholdMonitor = ThresholdMonitor()
    private let overlayController = OverlayWindowController()

    private var pollTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        observePollInterval()
        schedulePolling()
        if settingsStore.hasLocation {
            Task { await poll() }
        }
    }

    private func observePollInterval() {
        settingsStore.$pollIntervalMinutes
            .dropFirst()
            .sink { [weak self] _ in self?.schedulePolling() }
            .store(in: &cancellables)

        settingsStore.$locationName
            .dropFirst()
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in Task { await self?.poll() } }
            .store(in: &cancellables)
    }

    private func schedulePolling() {
        pollTimer?.invalidate()
        let interval = Double(settingsStore.pollIntervalMinutes) * 60.0
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.poll() }
        }
    }

    func refreshNow() {
        Task { await poll() }
    }

    func testAlert(_ direction: TempDirection) {
        let fakeTemp: Double
        switch direction {
        case .tooHot: fakeTemp = settingsStore.upperThresholdFahrenheit + 3
        case .tooCold: fakeTemp = settingsStore.lowerThresholdFahrenheit - 3
        case .comfortZone: fakeTemp = (settingsStore.lowerThresholdFahrenheit + settingsStore.upperThresholdFahrenheit) / 2
        }
        overlayController.show(
            direction: direction,
            settingsStore: settingsStore,
            currentTempF: currentTempF ?? fakeTemp
        )
    }

    private func poll() async {
        guard settingsStore.hasLocation else {
            fetchError = "No location set — open Settings"
            return
        }

        fetchError = nil

        guard let tempC = await WeatherService.fetchTemperatureCelsius(
            lat: settingsStore.storedLatitude,
            lon: settingsStore.storedLongitude
        ) else {
            fetchError = "Weather fetch failed"
            return
        }

        let tempF = tempC * 9.0 / 5.0 + 32.0
        currentTempF = tempF
        lastFetchDate = Date()
        fetchError = nil

        let direction = thresholdMonitor.process(
            tempF: tempF,
            lowerF: settingsStore.lowerThresholdFahrenheit,
            upperF: settingsStore.upperThresholdFahrenheit,
            cooldownSeconds: Double(settingsStore.cooldownMinutes * 60)
        )

        if let dir = direction {
            overlayController.show(
                direction: dir,
                settingsStore: settingsStore,
                currentTempF: tempF
            )
        }
    }

    func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView().environmentObject(settingsStore)
            let controller = NSHostingController(rootView: view)
            let win = NSWindow(contentViewController: controller)
            win.title = "Breeze Settings"
            win.styleMask = [.titled, .closable, .miniaturizable]
            win.isReleasedWhenClosed = false
            win.center()
            settingsWindow = win
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }
}
