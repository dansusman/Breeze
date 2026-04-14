import SwiftUI

struct MenuBarContentView: View {

    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Group {
            temperatureHeader
            Divider()
            Button("Refresh Now") { appDelegate.refreshNow() }
            Menu("Test Alert\u{2026}") {
                Button("Test \u{2191} Hot Alert") { appDelegate.testAlert(.crossedAbove) }
                Button("Test \u{2193} Cool Alert") { appDelegate.testAlert(.crossedBelow) }
            }
            Divider()
            Button("Settings\u{2026}") { appDelegate.openSettings() }
                .keyboardShortcut(",", modifiers: .command)
            Divider()
            Button("Quit Breeze") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
        }
    }

    private var temperatureHeader: some View {
        Group {
            if let error = appDelegate.fetchError {
                Text("\u{26A0}\u{FE0F} \(error)")
                    .foregroundStyle(.red)
            } else if let temp = appDelegate.currentTempF {
                Text("Now: \(settingsStore.formatTemperature(temp))")
                Text("Threshold: \(settingsStore.formatThreshold())")
            } else {
                Text("Fetching weather\u{2026}")
            }
            if let date = appDelegate.lastFetchDate {
                Text("Updated \(date.formatted(.relative(presentation: .named)))")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
