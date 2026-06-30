import Cocoa
import AudioToolbox

class KeyboardMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private(set) var isEnabled = false

    private(set) var currentSoundType: SoundType = .glass
    private var soundID: SystemSoundID = 0

    enum SoundType: String, CaseIterable {
        case glass = "Glass"
        case pop = "Pop"
        case tink = "Tink"
        case ping = "Ping"
        case morse = "Morse"
        case sosumi = "Sosumi"
        case funk = "Funk"
        case hero = "Hero"
    }

    var volume: Float = 0.5
    private var lastPlayTime: UInt64 = 0
    private var timeBase: UInt32 = 1

    init() {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        timeBase = info.numer / info.denom

        if let saved = UserDefaults.standard.string(forKey: "selectedSound"),
           let type = SoundType(rawValue: saved) {
            currentSoundType = type
        }
        let savedVol = UserDefaults.standard.float(forKey: "soundVolume")
        volume = savedVol > 0 ? savedVol : 0.5
    }

    func start() {
        guard !isEnabled else { return }
        loadSound(currentSoundType)

        guard let eventTap = createEventTap() else {
            showAccessibilityAlert()
            return
        }

        self.eventTap = eventTap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        isEnabled = true
    }

    func stop() {
        guard isEnabled else { return }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        if soundID != 0 {
            AudioServicesDisposeSystemSoundID(soundID)
            soundID = 0
        }
        eventTap = nil
        runLoopSource = nil
        isEnabled = false
    }

    func toggle() {
        if isEnabled { stop() } else { start() }
    }

    func changeSound(to type: SoundType) {
        currentSoundType = type
        UserDefaults.standard.set(type.rawValue, forKey: "selectedSound")
        loadSound(type)
    }

    func testSound() {
        playSound()
    }

    private func loadSound(_ type: SoundType) {
        if soundID != 0 {
            AudioServicesDisposeSystemSoundID(soundID)
            soundID = 0
        }

        let path = "/System/Library/Sounds/\(type.rawValue).aiff"
        guard FileManager.default.fileExists(atPath: path) else {
            print("[KeySound] Sound file not found: \(path)")
            return
        }

        let url = URL(fileURLWithPath: path) as CFURL
        let status = AudioServicesCreateSystemSoundID(url, &soundID)
        if status != noErr {
            print("[KeySound] Failed to load sound: \(status)")
        }
    }

    private func playSound() {
        guard soundID != 0 else { return }

        let now = mach_absolute_time()
        let elapsed = (now - lastPlayTime) * UInt64(timeBase)
        let minNs: UInt64 = 2_000_000
        guard elapsed >= minNs else { return }
        lastPlayTime = now

        AudioServicesPlaySystemSound(soundID)
    }

    private func createEventTap() -> CFMachPort? {
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        return CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon).takeUnretainedValue()
                monitor.playSound()
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
    }

    private func showAccessibilityAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "KeySound needs Accessibility permission to detect keyboard input.\n\nOpen System Settings > Privacy & Security > Accessibility and enable KeySound."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Later")

            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}
