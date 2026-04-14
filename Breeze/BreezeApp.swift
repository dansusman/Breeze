import SwiftUI

@main
struct BreezeApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(appDelegate)
                .environmentObject(appDelegate.settingsStore)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.menu)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        if let temp = appDelegate.currentTempF {
            Label(appDelegate.settingsStore.formatTemperature(temp), systemImage: "thermometer.medium")
        } else {
            Label("Breeze", systemImage: "thermometer.medium")
        }
    }
}
