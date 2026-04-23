import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var settingsStore: SettingsStore

    @State private var locationQuery = ""
    @State private var isGeocoding = false
    @State private var geocodeError = false

    var body: some View {
        Form {
            Section("Location") {
                HStack {
                    TextField("City or town name", text: $locationQuery)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { geocode() }
                    Button(isGeocoding ? "Searching\u{2026}" : "Search") { geocode() }
                        .disabled(locationQuery.trimmingCharacters(in: .whitespaces).isEmpty || isGeocoding)
                }
                if settingsStore.hasLocation {
                    Label(settingsStore.locationName, systemImage: "mappin.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                if geocodeError {
                    Label("Location not found. Try a different city name.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section("Temperature") {
                VStack(spacing: 16) {
                    Picker("Unit", selection: $settingsStore.useFahrenheit) {
                        Text("Fahrenheit (\u{00B0}F)").tag(true)
                        Text("Celsius (\u{00B0}C)").tag(false)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Open windows")
                            .foregroundStyle(.secondary)
                        Slider(value: lowerThresholdBinding, in: lowerThresholdRange, step: 1)
                        Text(String(format: "%.0f\u{00B0}%@",
                                    settingsStore.lowerThresholdDisplay,
                                    settingsStore.useFahrenheit ? "F" : "C"))
                            .monospacedDigit()
                            .frame(width: 64, alignment: .trailing)
                    }

                    HStack {
                        Text("Close windows")
                            .foregroundStyle(.secondary)
                        Slider(value: upperThresholdBinding, in: upperThresholdRange, step: 1)
                        Text(String(format: "%.0f\u{00B0}%@",
                                    settingsStore.upperThresholdDisplay,
                                    settingsStore.useFahrenheit ? "F" : "C"))
                            .monospacedDigit()
                            .frame(width: 64, alignment: .trailing)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Notifications") {
                HStack {
                    Text("Too hot")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: $settingsStore.messageTooHot)
                        .multilineTextAlignment(.leading)
                }
                HStack {
                    Text("Too cold")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: $settingsStore.messageTooCold)
                        .multilineTextAlignment(.leading)
                }
                HStack {
                    Text("Comfort zone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("", text: $settingsStore.messageComfort)
                        .multilineTextAlignment(.leading)
                }
            }

            Section("Timing") {
                Picker("Check every", selection: $settingsStore.pollIntervalMinutes) {
                    Text("5 min").tag(5)
                    Text("10 min").tag(10)
                    Text("15 min").tag(15)
                    Text("30 min").tag(30)
                }

                Picker("Cooldown between alerts", selection: $settingsStore.cooldownMinutes) {
                    Text("15 min").tag(15)
                    Text("30 min").tag(30)
                    Text("1 hour").tag(60)
                    Text("2 hours").tag(120)
                    Text("4 hours").tag(240)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 560)
        .onAppear {
            locationQuery = settingsStore.locationName.components(separatedBy: ",").first ?? ""
        }
    }

    private func geocode() {
        let query = locationQuery.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        isGeocoding = true
        geocodeError = false
        Task {
            if let result = await WeatherService.geocode(city: query) {
                settingsStore.locationName = result.displayName
                settingsStore.storedLatitude = result.latitude
                settingsStore.storedLongitude = result.longitude
                locationQuery = result.name
            } else {
                geocodeError = true
            }
            isGeocoding = false
        }
    }

    private var lowerThresholdBinding: Binding<Double> {
        Binding(
            get: { settingsStore.lowerThresholdDisplay },
            set: {
                settingsStore.lowerThresholdDisplay = $0
                if settingsStore.lowerThresholdFahrenheit > settingsStore.upperThresholdFahrenheit - 2 {
                    settingsStore.upperThresholdFahrenheit = settingsStore.lowerThresholdFahrenheit + 2
                }
            }
        )
    }

    private var upperThresholdBinding: Binding<Double> {
        Binding(
            get: { settingsStore.upperThresholdDisplay },
            set: {
                settingsStore.upperThresholdDisplay = $0
                if settingsStore.upperThresholdFahrenheit < settingsStore.lowerThresholdFahrenheit + 2 {
                    settingsStore.lowerThresholdFahrenheit = settingsStore.upperThresholdFahrenheit - 2
                }
            }
        )
    }

    private var lowerThresholdRange: ClosedRange<Double> {
        settingsStore.useFahrenheit ? 40.0...98.0 : 4.0...37.0
    }

    private var upperThresholdRange: ClosedRange<Double> {
        settingsStore.useFahrenheit ? 42.0...100.0 : 5.0...38.0
    }
}
