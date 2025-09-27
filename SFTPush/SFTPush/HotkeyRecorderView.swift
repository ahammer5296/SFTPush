import Cocoa
import Carbon.HIToolbox // Добавлено для kVK_* констант

protocol HotkeyRecorderViewDelegate: AnyObject {
    func hotkeyRecorderView(_ hotkeyRecorderView: HotkeyRecorderView, didReceiveKeyCombo keyCombo: KeyCombo?)
}

class HotkeyRecorderView: NSView {

    weak var delegate: HotkeyRecorderViewDelegate?

    var currentKeyCombo: KeyCombo? { // Изменено на var для возможности установки извне
        didSet {
            updateDisplay()
        }
    }

    private let textField: NSTextField = {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isEditable = false
        field.isSelectable = false
        field.drawsBackground = true
        field.backgroundColor = .controlBackgroundColor
        field.alignment = .center
        field.font = NSFont.systemFont(ofSize: 13)
        field.placeholderString = "Нажмите клавиши..."
        return field
    }()

    override var acceptsFirstResponder: Bool {
        return true
    }

    override var canBecomeKeyView: Bool {
        return true
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Добавляем отслеживание кликов для активации записи
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(clickGesture)
    }

    @objc private func handleClick() {
        window?.makeFirstResponder(self)
        startRecording()
    }

    func startRecording() {
        currentKeyCombo = nil
        textField.stringValue = "Запись..."
        // Можно добавить визуальный индикатор записи
    }

    func stopRecording() {
        updateDisplay()
        // Удалить визуальный индикатор записи
    }

    func clearHotkey() {
        currentKeyCombo = nil
        delegate?.hotkeyRecorderView(self, didReceiveKeyCombo: nil)
        stopRecording()
    }

    private func updateDisplay() {
        if let combo = currentKeyCombo {
            textField.stringValue = combo.description
        } else {
            textField.stringValue = ""
            textField.placeholderString = "Нажмите клавиши..."
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            stopRecording()
            return
        }

        if let newKeyCombo = KeyCombo(event: event) {
            if newKeyCombo.isValid {
                currentKeyCombo = newKeyCombo
                delegate?.hotkeyRecorderView(self, didReceiveKeyCombo: newKeyCombo)
                stopRecording()
            } else {
                // Если комбинация невалидна (например, только модификатор), продолжаем запись
                textField.stringValue = "Неполная комбинация..."
            }
        } else {
            // Если KeyCombo не может быть создан (например, только модификатор), продолжаем запись
            textField.stringValue = "Неполная комбинация..."
        }
    }

    override func resignFirstResponder() -> Bool {
        stopRecording()
        return super.resignFirstResponder()
    }
}

// MARK: - KeyCombo Struct
struct KeyCombo: Codable, Equatable {
    let keyCode: UInt16
    let modifierFlags: NSEvent.ModifierFlags

    var isValid: Bool {
        return keyCode != 0 && !modifierFlags.isEmpty
    }

    init?(event: NSEvent) {
        if event.keyCode == 0 { return nil }

        self.keyCode = event.keyCode
        self.modifierFlags = event.modifierFlags.intersection([.command, .control, .option, .shift])
    }
    
    init(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags.intersection([.command, .control, .option, .shift])
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case keyCode
        case modifierFlags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keyCode = try container.decode(UInt16.self, forKey: .keyCode)
        let rawModifierFlags = try container.decode(UInt.self, forKey: .modifierFlags)
        modifierFlags = NSEvent.ModifierFlags(rawValue: rawModifierFlags)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyCode, forKey: .keyCode)
        try container.encode(modifierFlags.rawValue, forKey: .modifierFlags)
    }

    var description: String {
        var components: [String] = []

        if modifierFlags.contains(.control) { components.append("⌃") }
        if modifierFlags.contains(.option) { components.append("⌥") }
        if modifierFlags.contains(.shift) { components.append("⇧") }
        if modifierFlags.contains(.command) { components.append("⌘") }

        if let keyString = keyString(for: keyCode) {
            components.append(keyString)
        }

        return components.joined(separator: "")
    }

    private func keyString(for keyCode: UInt16) -> String? {
        // Пример маппинга, можно расширить
        switch Int(keyCode) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_Space: return "Space"
        case kVK_Return: return "Return"
        case kVK_Delete: return "Delete"
        case kVK_Tab: return "Tab"
        case kVK_Escape: return "Esc"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        default: return nil
        }
    }
}
