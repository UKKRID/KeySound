import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var keyboardMonitor: KeyboardMonitor?
    var statusItem: NSStatusItem?
    var settingsWindow: NSWindow?
    var settingsVC: SettingsViewController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: "KeySound")
        }

        keyboardMonitor = KeyboardMonitor()
        buildMenu()
        keyboardMonitor?.start()
        updateMenu()
        openSettings()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        keyboardMonitor?.stop()
        return .terminateNow
    }

    private func buildMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Enable Sound", action: #selector(toggleSound), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit KeySound", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc func toggleSound() {
        keyboardMonitor?.toggle()
        updateMenu()
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            settingsVC = SettingsViewController(monitor: keyboardMonitor!)
            settingsWindow = NSWindow(contentViewController: settingsVC!)
            settingsWindow?.title = "KeySound Settings"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 420, height: 380))
            settingsWindow?.center()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        keyboardMonitor?.stop()
        NSApplication.shared.terminate(nil)
    }

    func updateMenu() {
        if let item = statusItem?.menu?.items.first {
            item.state = keyboardMonitor?.isEnabled == true ? .on : .off
        }
    }
}
