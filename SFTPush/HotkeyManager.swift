import Foundation
import AppKit
import Carbon.HIToolbox

// Глобальная функция-обработчик горячих клавиш
private var hotkeyEventHandler: EventHandlerRef?

private let hotkeyCallback: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
    var hotKeyID = EventHotKeyID()
    GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)

    // Отправляем уведомление, чтобы HotkeyManager мог его обработать
    NotificationCenter.default.post(name: .globalHotkeyTriggered, object: nil, userInfo: ["hotkeyID": hotKeyID])
    
    return noErr
}

extension Notification.Name {
    static let globalHotkeyTriggered = Notification.Name("globalHotkeyTriggered")
}

class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotkeyRef: EventHotKeyRef?
    private let hotkeyID = EventHotKeyID(signature: OSType("SFTP".fourCharCode), id: 1)
    
    private var registeredTarget: AnyObject?
    private var registeredSelector: Selector?
    private var currentKeyCombo: KeyCombo?

    private init() {
        // Подписываемся на уведомления от глобального обработчика
        NotificationCenter.default.addObserver(self, selector: #selector(handleGlobalHotkeyNotification), name: .globalHotkeyTriggered, object: nil)
    }

    func registerHotkey(keyCombo: KeyCombo?, target: AnyObject, selector: Selector) {
        unregisterHotkey() // Сначала отменяем регистрацию, если уже есть
        
        guard let keyCombo = keyCombo else {
            self.registeredTarget = nil
            self.registeredSelector = nil
            self.currentKeyCombo = nil
            return
        }

        self.registeredTarget = target
        self.registeredSelector = selector
        self.currentKeyCombo = keyCombo
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = self.hotkeyID.signature
        hotKeyID.id = self.hotkeyID.id
        
        RegisterEventHotKey(UInt32(keyCombo.keyCode), keyCombo.carbonModifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotkeyRef)
        
        // Устанавливаем глобальный обработчик событий, если он еще не установлен
        if hotkeyEventHandler == nil {
            var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            InstallEventHandler(GetEventDispatcherTarget(), hotkeyCallback, 1, &eventType, nil, &hotkeyEventHandler)
        }
    }

    func unregisterHotkey() {
        if let hotkeyRef = hotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
            self.hotkeyRef = nil
        }
        self.registeredTarget = nil
        self.registeredSelector = nil
        self.currentKeyCombo = nil
        
        // Удаляем глобальный обработчик событий, если он больше не нужен
        // (Оставляем его, так как он может быть нужен для других горячих клавиш)
        // if let handler = hotkeyEventHandler {
        //     RemoveEventHandler(handler)
        //     hotkeyEventHandler = nil
        // }
    }

    @objc private func handleGlobalHotkeyNotification(notification: Notification) {
        if let userInfo = notification.userInfo,
           let triggeredHotkeyID = userInfo["hotkeyID"] as? EventHotKeyID,
           triggeredHotkeyID.signature == hotkeyID.signature && triggeredHotkeyID.id == hotkeyID.id {
            
            if let target = registeredTarget, let selector = registeredSelector {
                _ = target.perform(selector)
            }
        }
    }
    
    var currentRegisteredKeyCombo: KeyCombo? {
        return currentKeyCombo
    }
}

extension KeyCombo {
    var carbonModifiers: UInt32 {
        var carbonFlags: UInt32 = 0
        if modifierFlags.contains(.command) { carbonFlags |= UInt32(cmdKey) }
        if modifierFlags.contains(.shift) { carbonFlags |= UInt32(shiftKey) }
        if modifierFlags.contains(.option) { carbonFlags |= UInt32(optionKey) }
        if modifierFlags.contains(.control) { carbonFlags |= UInt32(controlKey) }
        return carbonFlags
    }
}

extension String {
    var fourCharCode: OSType {
        var code: OSType = 0
        for (index, char) in self.utf8.enumerated() {
            if index >= 4 { break }
            code = (code << 8) | OSType(char)
        }
        return code
    }
}
