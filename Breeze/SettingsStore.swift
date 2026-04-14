import Foundation
import Combine

final class SettingsStore: ObservableObject {

    private static let defaults = UserDefaults.standard

    @Published var thresholdFahrenheit: Double {
        didSet { Self.defaults.set(thresholdFahrenheit, forKey: "thresholdFahrenheit") }
    }

    @Published var useFahrenheit: Bool {
        didSet { Self.defaults.set(useFahrenheit, forKey: "useFahrenheit") }
    }

    @Published var messageAbove: String {
        didSet { Self.defaults.set(messageAbove, forKey: "messageAbove") }
    }

    @Published var messageBelow: String {
        didSet { Self.defaults.set(messageBelow, forKey: "messageBelow") }
    }

    @Published var cooldownMinutes: Int {
        didSet { Self.defaults.set(cooldownMinutes, forKey: "cooldownMinutes") }
    }

    @Published var pollIntervalMinutes: Int {
        didSet { Self.defaults.set(pollIntervalMinutes, forKey: "pollIntervalMinutes") }
    }

    @Published var locationName: String {
        didSet { Self.defaults.set(locationName, forKey: "locationName") }
    }

    @Published var storedLatitude: Double {
        didSet { Self.defaults.set(storedLatitude, forKey: "storedLatitude") }
    }

    @Published var storedLongitude: Double {
        didSet { Self.defaults.set(storedLongitude, forKey: "storedLongitude") }
    }

    var hasLocation: Bool { !locationName.isEmpty }

    init() {
        let ud = Self.defaults
        thresholdFahrenheit = { let v = ud.double(forKey: "thresholdFahrenheit"); return v == 0 ? 72.0 : v }()
        useFahrenheit = ud.object(forKey: "useFahrenheit") == nil ? true : ud.bool(forKey: "useFahrenheit")
        messageAbove = ud.string(forKey: "messageAbove") ?? "Close the windows! It\u{2019}s getting hot."
        messageBelow = ud.string(forKey: "messageBelow") ?? "Open the windows! Time to let that breeze in."
        cooldownMinutes = { let v = ud.integer(forKey: "cooldownMinutes"); return v == 0 ? 30 : v }()
        pollIntervalMinutes = { let v = ud.integer(forKey: "pollIntervalMinutes"); return v == 0 ? 10 : v }()
        locationName = ud.string(forKey: "locationName") ?? ""
        storedLatitude = ud.double(forKey: "storedLatitude")
        storedLongitude = ud.double(forKey: "storedLongitude")
    }

    var thresholdDisplay: Double {
        get { useFahrenheit ? thresholdFahrenheit : Self.fahrenheitToCelsius(thresholdFahrenheit) }
        set { thresholdFahrenheit = useFahrenheit ? newValue : Self.celsiusToFahrenheit(newValue) }
    }

    static func fahrenheitToCelsius(_ f: Double) -> Double {
        (f - 32) * 5 / 9
    }

    static func celsiusToFahrenheit(_ c: Double) -> Double {
        c * 9 / 5 + 32
    }

    func formatTemperature(_ fahrenheit: Double) -> String {
        let value = useFahrenheit ? fahrenheit : Self.fahrenheitToCelsius(fahrenheit)
        return String(format: "%.1f\u{00B0}%@", value, useFahrenheit ? "F" : "C")
    }

    func formatThreshold() -> String {
        formatTemperature(thresholdFahrenheit)
    }
}
