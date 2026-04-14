import AppKit
import SwiftUI

final class OverlayWindowController {

    private var windows: [NSWindow] = []
    private var autoDismissTimer: Timer?
    private let autoDismissInterval: TimeInterval = 90

    func show(direction: TempDirection, settingsStore: SettingsStore, currentTempF: Double) {
        dismiss()

        for screen in NSScreen.screens {
            let view = OverlayView(
                direction: direction,
                currentTempF: currentTempF,
                settingsStore: settingsStore,
                onDismiss: { [weak self] in self?.dismiss() }
            )
            let hostingView = NSHostingView(rootView: view)

            let win = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            win.level = .screenSaver
            win.isOpaque = false
            win.backgroundColor = .clear
            win.contentView = hostingView
            win.makeKeyAndOrderFront(nil)
            windows.append(win)
        }

        NSApp.activate()

        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: autoDismissInterval, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }

    func dismiss() {
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}
