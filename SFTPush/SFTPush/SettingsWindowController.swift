//
//  SettingsWindowController.swift
//  TestUploader
//
//  Created by Alex Masibut on 24.09.2025.
//

import Cocoa

class SettingsWindowController: NSWindowController, NSWindowDelegate { // Добавляем соответствие протоколу NSWindowDelegate

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
        
        // Устанавливаем делегата окна
        window.delegate = self
        
        // Устанавливаем контроллер содержимого
        self.contentViewController = SettingsViewController()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        // При закрытии окна настроек сохраняем все изменения
        if let settingsVC = contentViewController as? SettingsViewController {
            settingsVC.saveSettings()
            print("Настройки сохранены при закрытии окна.")
        }
    }
}
