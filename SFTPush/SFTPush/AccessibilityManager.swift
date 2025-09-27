import Cocoa
import ApplicationServices
import Carbon

class AccessibilityManager {

    static let shared = AccessibilityManager()

    private init() {}

    /// Проверяет, есть ли у приложения права на управление другими приложениями
    func hasAccessibilityPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Запрашивает права на управление другими приложениями
    func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
    }

    /// Симулирует нажатие комбинации клавиш Cmd+C
    func simulateCopy() {
        guard hasAccessibilityPermissions() else {
            print("Нет прав на управление другими приложениями")
            return
        }

        // Симулируем нажатие Cmd+C
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: true)
        keyDownEvent?.flags = CGEventFlags.maskCommand

        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: false)
        keyUpEvent?.flags = CGEventFlags.maskCommand

        // Отправляем события в систему
        keyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
        keyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)

        print("Симулировано нажатие Cmd+C")
    }

    /// Проверяет, является ли активное приложение Monosnap
    func isActiveApplicationMonosnap() -> Bool {
        guard hasAccessibilityPermissions() else {
            print("Нет прав на управление другими приложениями")
            return false
        }

        let frontmostApp = NSWorkspace.shared.frontmostApplication
        let bundleIdentifier = frontmostApp?.bundleIdentifier

        print("Активное приложение: \(bundleIdentifier ?? "неизвестно")")

        // Проверяем на Monosnap (bundle identifier может быть "com.monosnap.monosnap" или подобным)
        return bundleIdentifier?.lowercased().contains("monosnap") ?? false
    }

    /// Показывает уведомление пользователю о необходимости предоставить права
    func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Требуются специальные разрешения"
        alert.informativeText = "Для работы функции \"Копировать перед загрузкой\" необходимо предоставить приложению права на управление другими приложениями.\n\nПожалуйста, перейдите в Системные настройки → Безопасность и конфиденциальность → Специальные возможности и добавьте SFTPush в список разрешенных приложений."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Открыть настройки")
        alert.addButton(withTitle: "Отмена")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // Открываем настройки специальных возможностей
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}
