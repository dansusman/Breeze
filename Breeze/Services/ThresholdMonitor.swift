import Foundation

enum TempDirection {
    case tooHot
    case tooCold
    case comfortZone
}

final class ThresholdMonitor {

    enum Zone { case cold, comfort, hot }

    private var lastZone: Zone?
    private var lastNotificationDate: Date?

    static func zone(tempF: Double, lowerF: Double, upperF: Double) -> Zone {
        if tempF >= upperF { return .hot }
        if tempF < lowerF { return .cold }
        return .comfort
    }

    func process(tempF: Double, lowerF: Double, upperF: Double, cooldownSeconds: Double) -> TempDirection? {
        let current = Self.zone(tempF: tempF, lowerF: lowerF, upperF: upperF)
        defer { lastZone = current }

        guard let last = lastZone, last != current else { return nil }

        let elapsed = lastNotificationDate.map { Date().timeIntervalSince($0) } ?? .infinity
        guard elapsed >= cooldownSeconds else { return nil }

        lastNotificationDate = Date()

        switch current {
        case .hot: return .tooHot
        case .cold: return .tooCold
        case .comfort: return .comfortZone
        }
    }

    func reset() {
        lastZone = nil
        lastNotificationDate = nil
    }
}
