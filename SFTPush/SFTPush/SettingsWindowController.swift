//
//  SettingsWindowController.swift
//  TestUploader
//
//  Created by Alex Masibut on 24.09.2025.
//

import Cocoa

class SettingsWindowController: NSWindowController {

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Настройки"
        window.isReleasedWhenClosed = false // Чтобы окно не уничтожалось при закрытии
        self.init(window: window)
        
        // Устанавливаем контроллер содержимого
        self.contentViewController = SettingsViewController()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
