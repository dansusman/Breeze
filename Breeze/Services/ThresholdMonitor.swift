import Foundation

enum TempDirection {
    case crossedAbove
    case crossedBelow
}

final class ThresholdMonitor {

    private enum Side { case above, below }

    private var lastSide: Side?
    private var lastNotificationDate: Date?

    func process(tempF: Double, thresholdF: Double, cooldownSeconds: Double) -> TempDirection? {
        let side: Side = tempF >= thresholdF ? .above : .below
        defer { lastSide = side }

        guard let last = lastSide, last != side else { return nil }

        let elapsed = lastNotificationDate.map { Date().timeIntervalSince($0) } ?? .infinity
        guard elapsed >= cooldownSeconds else { return nil }

        lastNotificationDate = Date()
        return side == .above ? .crossedAbove : .crossedBelow
    }

    func reset() {
        lastSide = nil
        lastNotificationDate = nil
    }
}
