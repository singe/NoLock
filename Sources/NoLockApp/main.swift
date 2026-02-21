import SwiftUI
import IOKit.pwr_mgt

@main
struct NoLockApp: App {
    @StateObject private var manager = NoLockManager()

    var body: some Scene {
        WindowGroup(id: "main-window") {
            ContentView(manager: manager)
                .frame(width: 320, height: 170)
                .padding(20)
        }
        .windowResizability(.contentSize)

        MenuBarExtra(
            manager.isEnabled ? "NoLock ON" : "NoLock OFF",
            systemImage: manager.isEnabled ? "lock.open.fill" : "lock"
        ) {
            MenuBarContent(manager: manager)
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor
final class NoLockManager: ObservableObject {
    @Published var isEnabled = false {
        didSet {
            if isEnabled {
                enableAssertions()
            } else {
                disableAssertions()
            }
        }
    }

    private var displayAssertionID: IOPMAssertionID = 0
    private var idleAssertionID: IOPMAssertionID = 0

    private func enableAssertions() {
        guard displayAssertionID == 0, idleAssertionID == 0 else { return }

        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "NoLockApp: Keep display awake" as CFString,
            &displayAssertionID
        )

        let idleResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "NoLockApp: Prevent idle sleep" as CFString,
            &idleAssertionID
        )

        if displayResult != kIOReturnSuccess || idleResult != kIOReturnSuccess {
            disableAssertions()
            isEnabled = false
        }
    }

    private func disableAssertions() {
        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }

        if idleAssertionID != 0 {
            IOPMAssertionRelease(idleAssertionID)
            idleAssertionID = 0
        }
    }
}

struct ContentView: View {
    @ObservedObject var manager: NoLockManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("NoLock")
                .font(.title2.bold())

            Toggle(isOn: $manager.isEnabled) {
                Text(manager.isEnabled ? "Keep Mac awake: ON" : "Keep Mac awake: OFF")
                    .font(.headline)
            }
            .toggleStyle(.switch)

            Text(manager.isEnabled
                 ? "Display sleep and idle sleep are disabled."
                 : "macOS default locking/sleep behavior is active.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

struct MenuBarContent: View {
    @ObservedObject var manager: NoLockManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Toggle(isOn: $manager.isEnabled) {
            Text(manager.isEnabled ? "Keep Mac awake: ON" : "Keep Mac awake: OFF")
        }

        Divider()

        Text(manager.isEnabled
             ? "NoLock is active."
             : "NoLock is inactive.")
            .font(.footnote)
            .foregroundStyle(.secondary)

        Divider()

        Button("Show Window") {
            NSApplication.shared.activate(ignoringOtherApps: true)
            openWindow(id: "main-window")
        }

        Divider()

        Button("Quit NoLock") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
