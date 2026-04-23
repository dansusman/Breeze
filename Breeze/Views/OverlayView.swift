import SwiftUI

struct OverlayView: View {

    let direction: TempDirection
    let currentTempF: Double
    let settingsStore: SettingsStore
    let onDismiss: () -> Void

    @State private var iconAnimating = false

    private var accentColor: Color {
        switch direction {
        case .tooHot: return .orange
        case .tooCold: return .cyan
        case .comfortZone: return .green
        }
    }

    private var iconName: String {
        switch direction {
        case .tooHot: return "thermometer.sun.fill"
        case .tooCold: return "thermometer.snowflake"
        case .comfortZone: return "wind"
        }
    }

    private var directionLabel: String {
        switch direction {
        case .tooHot: return "\u{2191} Getting hot"
        case .tooCold: return "\u{2193} Getting cold"
        case .comfortZone: return "Perfect temperature"
        }
    }

    private var message: String {
        switch direction {
        case .tooHot: return settingsStore.messageTooHot
        case .tooCold: return settingsStore.messageTooCold
        case .comfortZone: return settingsStore.messageComfort
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.82)
                .ignoresSafeArea()

            closeButton

            VStack(spacing: 28) {
                animatedIcon
                temperatureText
                directionText
                messageText
                dismissButton
            }
            .padding(60)
        }
        .onAppear { iconAnimating = true }
    }

    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.6))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(28)
            }
            Spacer()
        }
    }

    private var animatedIcon: some View {
        Image(systemName: iconName)
            .font(.system(size: 110))
            .foregroundStyle(accentColor)
            .symbolEffect(.bounce, options: .repeating, value: iconAnimating)
            .shadow(color: accentColor.opacity(0.6), radius: 30)
    }

    private var temperatureText: some View {
        Text(settingsStore.formatTemperature(currentTempF))
            .font(.system(size: 80, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }

    private var directionText: some View {
        Text(directionLabel)
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(accentColor)
    }

    private var messageText: some View {
        Text(message)
            .font(.system(size: 30, weight: .medium))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 80)
    }

    private var dismissButton: some View {
        Button("Dismiss", action: onDismiss)
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .tint(accentColor)
            .padding(.top, 8)
    }
}
