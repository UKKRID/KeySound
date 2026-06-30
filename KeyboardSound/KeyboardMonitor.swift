import Cocoa
import AVFoundation

class KeyboardMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private(set) var isEnabled = false

    private(set) var currentSoundType: SoundType = .glass
    private var playerPools: [String: [AVAudioPlayer]] = [:]
    private var playerIndices: [String: Int] = [:]

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

    var volume: Float = 0.5 {
        didSet {
            for (_, players) in playerPools {
                for player in players {
                    player.volume = volume
                }
            }
        }
    }

    private var lastPlayTime: UInt64 = 0
    private var timeBase: UInt32 = 1
    private let poolSize = 8

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

        preloadAllSounds()
    }

    func start() {
        guard !isEnabled else { return }

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

        for (_, players) in playerPools {
            for player in players {
                player.stop()
            }
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
        if playerPools[type.rawValue] == nil {
            preloadSound(type)
        }
    }

    func testSound() {
        playSound()
    }

    // MARK: - Preload

    private func preloadAllSounds() {
        for type in SoundType.allCases {
            preloadSound(type)
        }
    }

    private func preloadSound(_ type: SoundType) {
        guard playerPools[type.rawValue] == nil else { return }

        let path = "/System/Library/Sounds/\(type.rawValue).aiff"
        guard FileManager.default.fileExists(atPath: path) else { return }
        let url = URL(fileURLWithPath: path)

        var players: [AVAudioPlayer] = []
        for _ in 0..<poolSize {
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.volume = volume
                player.prepareToPlay()
                players.append(player)
            }
        }

        playerPools[type.rawValue] = players
        playerIndices[type.rawValue] = 0
    }

    // MARK: - Play

    private func playSound() {
        let now = mach_absolute_time()
        let elapsed = (now - lastPlayTime) * UInt64(timeBase)
        guard elapsed >= 2_000_000 else { return }
        lastPlayTime = now

        guard let players = playerPools[currentSoundType.rawValue], !players.isEmpty else { return }

        let idx = playerIndices[currentSoundType.rawValue] ?? 0
        let player = players[idx % players.count]
        playerIndices[currentSoundType.rawValue] = idx + 1

        player.stop()
        player.currentTime = 0
        player.volume = volume
        player.play()
    }

    // MARK: - Event Tap

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
