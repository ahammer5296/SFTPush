//
//  LaunchAtLoginManager.swift
//  TestUploader
//
//  Created by Alex Masibut on 24.09.2025.
//

import Foundation
import ServiceManagement // Для SMAppService
import AppKit // Для NSApplication.shared

class LaunchAtLoginManager {

    static let shared = LaunchAtLoginManager()

    private init() {}

    func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            let appService = SMAppService.mainApp
            if enabled {
                if appService.status == .notRegistered { // Регистрируем только если не зарегистрирован
                    do {
                        try appService.register()
                        print("Автозапуск включен.")
                    } catch {
                        print("Ошибка при включении автозапуска: \(error.localizedDescription)")
                    }
                }
            } else {
                if appService.status == .enabled || appService.status == .requiresApproval { // Отменяем регистрацию только если включен или требует подтверждения
                    do {
                        try appService.unregister()
                        print("Автозапуск выключен.")
                    } catch {
                        print("Ошибка при выключении автозапуска: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Fallback для старых версий macOS
            let bundleID = Bundle.main.bundleIdentifier!
            SMLoginItemSetEnabled(bundleID as CFString, enabled)
            print("Автозапуск (старый API) установлен в: \(enabled)")
        }
    }

    func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled || SMAppService.mainApp.status == .requiresApproval
        } else {
            // Fallback для старых версий macOS
            let bundleID = Bundle.main.bundleIdentifier!
            guard let jobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]] else {
                return false
            }

            for job in jobs {
                if let label = job["Label"] as? String, label == bundleID {
                    return true
                }
            }
            return false
        }
    }
}
