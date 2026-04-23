import Foundation
import Combine

final class SettingsStore: ObservableObject {

    private static let defaults = UserDefaults.standard

    @Published var upperThresholdFahrenheit: Double {
        didSet { Self.defaults.set(upperThresholdFahrenheit, forKey: "thresholdFahrenheit") }
    }

    @Published var lowerThresholdFahrenheit: Double {
        didSet { Self.defaults.set(lowerThresholdFahrenheit, forKey: "lowerThresholdFahrenheit") }
    }

    @Published var useFahrenheit: Bool {
        didSet { Self.defaults.set(useFahrenheit, forKey: "useFahrenheit") }
    }

    @Published var messageTooHot: String {
        didSet { Self.defaults.set(messageTooHot, forKey: "messageAbove") }
    }

    @Published var messageTooCold: String {
        didSet { Self.defaults.set(messageTooCold, forKey: "messageBelow") }
    }

    @Published var messageComfort: String {
        didSet { Self.defaults.set(messageComfort, forKey: "messageComfort") }
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
        upperThresholdFahrenheit = { let v = ud.double(forKey: "thresholdFahrenheit"); return v == 0 ? 72.0 : v }()
        lowerThresholdFahrenheit = { let v = ud.double(forKey: "lowerThresholdFahrenheit"); return v == 0 ? 66.0 : v }()
        useFahrenheit = ud.object(forKey: "useFahrenheit") == nil ? true : ud.bool(forKey: "useFahrenheit")
        messageTooHot = ud.string(forKey: "messageAbove") ?? "Close the windows! It\u{2019}s getting hot."
        messageTooCold = ud.string(forKey: "messageBelow") ?? "Close the windows! It\u{2019}s getting cold."
        messageComfort = ud.string(forKey: "messageComfort") ?? "Open the windows! Time to let that breeze in."
        cooldownMinutes = { let v = ud.integer(forKey: "cooldownMinutes"); return v == 0 ? 30 : v }()
        pollIntervalMinutes = { let v = ud.integer(forKey: "pollIntervalMinutes"); return v == 0 ? 10 : v }()
        locationName = ud.string(forKey: "locationName") ?? ""
        storedLatitude = ud.double(forKey: "storedLatitude")
        storedLongitude = ud.double(forKey: "storedLongitude")
    }

    var upperThresholdDisplay: Double {
        get { useFahrenheit ? upperThresholdFahrenheit : Self.fahrenheitToCelsius(upperThresholdFahrenheit) }
        set { upperThresholdFahrenheit = useFahrenheit ? newValue : Self.celsiusToFahrenheit(newValue) }
    }

    var lowerThresholdDisplay: Double {
        get { useFahrenheit ? lowerThresholdFahrenheit : Self.fahrenheitToCelsius(lowerThresholdFahrenheit) }
        set { lowerThresholdFahrenheit = useFahrenheit ? newValue : Self.celsiusToFahrenheit(newValue) }
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

    func formatThresholdRange() -> String {
        "\(formatTemperature(lowerThresholdFahrenheit)) – \(formatTemperature(upperThresholdFahrenheit))"
    }
}
