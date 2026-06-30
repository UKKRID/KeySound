import Cocoa

class SettingsViewController: NSViewController {
    let monitor: KeyboardMonitor

    private var volumeSlider: NSSlider!
    private var soundPopUp: NSPopUpButton!
    private var enableCheck: NSButton!
    private var volumeLabel: NSTextField!
    private var testButton: NSButton!

    init(monitor: KeyboardMonitor) {
        self.monitor = monitor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 380))

        let padding: CGFloat = 20
        let labelWidth: CGFloat = 80
        let controlX: CGFloat = padding + labelWidth + 10

        // Icon
        let iconView = NSImageView(frame: NSRect(x: 170, y: 305, width: 80, height: 80))
        iconView.image = NSApp.applicationIconImage
        contentView.addSubview(iconView)

        // Title
        let titleLabel = NSTextField(labelWithString: "KeySound")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 20)
        titleLabel.alignment = .center
        titleLabel.frame = NSRect(x: padding, y: 275, width: 380, height: 28)
        contentView.addSubview(titleLabel)

        // Version
        let versionLabel = NSTextField(labelWithString: "v1.2")
        versionLabel.textColor = .secondaryLabelColor
        versionLabel.alignment = .center
        versionLabel.font = NSFont.systemFont(ofSize: 11)
        versionLabel.frame = NSRect(x: padding, y: 258, width: 380, height: 16)
        contentView.addSubview(versionLabel)

        // Separator
        addSeparator(y: 248, to: contentView)

        // Enable
        enableCheck = NSButton(checkboxWithTitle: "Enable keyboard sound", target: self, action: #selector(toggleEnabled))
        enableCheck.frame = NSRect(x: padding, y: 218, width: 380, height: 24)
        enableCheck.state = monitor.isEnabled ? .on : .off
        contentView.addSubview(enableCheck)

        // Sound row
        let soundLabel = NSTextField(labelWithString: "Sound:")
        soundLabel.frame = NSRect(x: padding, y: 185, width: labelWidth, height: 24)
        soundLabel.alignment = .right
        contentView.addSubview(soundLabel)

        soundPopUp = NSPopUpButton(frame: NSRect(x: controlX, y: 185, width: 190, height: 24))
        for type in KeyboardMonitor.SoundType.allCases {
            soundPopUp.addItem(withTitle: type.rawValue)
            if type == monitor.currentSoundType {
                soundPopUp.selectItem(withTitle: type.rawValue)
            }
        }
        soundPopUp.target = self
        soundPopUp.action = #selector(soundChanged)
        contentView.addSubview(soundPopUp)

        testButton = NSButton(title: "Test", target: self, action: #selector(testSound))
        testButton.frame = NSRect(x: controlX + 200, y: 185, width: 70, height: 24)
        contentView.addSubview(testButton)

        // Volume row
        let volumeTitle = NSTextField(labelWithString: "Volume:")
        volumeTitle.frame = NSRect(x: padding, y: 150, width: labelWidth, height: 24)
        volumeTitle.alignment = .right
        contentView.addSubview(volumeTitle)

        let initVol: Float = monitor.volume
        volumeSlider = NSSlider(value: Double(initVol), minValue: 0, maxValue: 1, target: self, action: #selector(volumeChanged))
        volumeSlider.frame = NSRect(x: controlX, y: 150, width: 260, height: 24)
        volumeSlider.isContinuous = true
        contentView.addSubview(volumeSlider)

        volumeLabel = NSTextField(labelWithString: "\(Int(initVol * 100))%")
        volumeLabel.frame = NSRect(x: controlX + 270, y: 150, width: 50, height: 24)
        contentView.addSubview(volumeLabel)

        // Separator
        addSeparator(y: 135, to: contentView)

        // Info
        let infoLabel = NSTextField(wrappingLabelWithString: "Sounds: Glass, Pop, Tink, Ping, Morse, Sosumi, Funk, Hero\nShortcut: ⌘, Settings   ⌘Q Quit")
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.font = NSFont.systemFont(ofSize: 10)
        infoLabel.frame = NSRect(x: padding, y: 85, width: 380, height: 40)
        contentView.addSubview(infoLabel)

        // Note
        let noteLabel = NSTextField(wrappingLabelWithString: "Requires Accessibility permission in System Settings > Privacy & Security > Accessibility")
        noteLabel.textColor = .tertiaryLabelColor
        noteLabel.font = NSFont.systemFont(ofSize: 9)
        noteLabel.frame = NSRect(x: padding, y: 50, width: 380, height: 28)
        contentView.addSubview(noteLabel)

        self.view = contentView
    }

    private func addSeparator(y: CGFloat, to view: NSView) {
        let sep = NSBox()
        sep.boxType = .separator
        sep.frame = NSRect(x: 20, y: y, width: 380, height: 1)
        view.addSubview(sep)
    }

    @objc func toggleEnabled() {
        monitor.toggle()
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.updateMenu()
        }
    }

    @objc func soundChanged() {
        let name = soundPopUp.titleOfSelectedItem ?? "Glass"
        if let type = KeyboardMonitor.SoundType(rawValue: name) {
            monitor.changeSound(to: type)
        }
    }

    @objc func volumeChanged() {
        let vol = Float(volumeSlider.doubleValue)
        UserDefaults.standard.set(vol, forKey: "soundVolume")
        monitor.volume = vol
        volumeLabel.stringValue = "\(Int(vol * 100))%"
    }

    @objc func testSound() {
        monitor.testSound()
    }
}
