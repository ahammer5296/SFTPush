//
//  AppDelegate.swift
//  TestUploader
//
//  Created by Alex Masibut on 24.09.2025.
//

import Cocoa
import UserNotifications // Для системных уведомлений
import Carbon.HIToolbox // Добавлено для HotkeyManager

@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate { // Изменено на UNUserNotificationCenterDelegate

    var statusItem: NSStatusItem?
    var settingsWindowController: NSWindowController? // Для окна настроек
    var hotkeyManager = HotkeyManager.shared // Инициализируем HotkeyManager
    var isUploading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateStatusItemImage()
                self?.updateDockIconAnimation() // Добавляем управление анимацией дока
            }
        }
    }

    // MARK: - Dock Icon Animation Properties
    private var dockAnimationTimer: Timer?
    private var dockAnimationFrames: [NSImage] = []
    private var currentDockFrameIndex: Int = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Устанавливаем значения по умолчанию для настроек, если они еще не установлены
        let defaults = UserDefaults.standard
        
        // Устанавливаем политику активации в зависимости от настроек
        if defaults.object(forKey: "showDockIcon") == nil {
            defaults.set(false, forKey: "showDockIcon") // По умолчанию: не показывать иконку в доке
        }
        
        if defaults.bool(forKey: "showDockIcon") {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }

        // Главное окно больше не создается автоматически из Storyboard, поэтому этот код не нужен.
        // Если бы у нас было другое главное окно, мы бы закрывали его здесь.

        // Создаем NSStatusItem
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Настраиваем кнопку status item
        if let button = statusItem?.button {
            button.image = NSImage(named: "MenuBarIcon") // Используем нашу иконку
            button.action = #selector(statusBarButtonClicked)
            button.target = self
            button.wantsLayer = true // Включаем layer для подсветки
            button.registerForDraggedTypes([.fileURL]) // Регистрируем поддержку drag & drop
        }
        // Создаем меню
        let menu = NSMenu()

        // Добавляем пункты меню
        menu.addItem(NSMenuItem(title: "Загрузить из буфера обмена", action: #selector(uploadFromClipboard), keyEquivalent: "v")) // Новый пункт меню
        menu.addItem(NSMenuItem.separator()) // Разделитель после нового пункта
        menu.addItem(NSMenuItem(title: "Запустить отслеживание папки", action: #selector(toggleFolderMonitoring), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Статус: Остановлено", action: nil, keyEquivalent: "")) // Этот пункт будет обновляться динамически
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Настройки", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Тест уведомления", action: #selector(testNotification), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
        updateMenuStatus() // Обновляем статус меню при запуске

        // Настраиваем делегат для UserNotifications
        UNUserNotificationCenter.current().delegate = self
        // Запрашиваем разрешение на уведомления
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено.")
            } else if let error = error {
                print("Ошибка при запросе разрешения на уведомления: \(error.localizedDescription)")
            }
        }

        // Подписываемся на уведомления от FolderMonitor
        NotificationCenter.default.addObserver(self, selector: #selector(handleFolderMonitoringStatusChanged), name: Notification.Name.folderMonitoringStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadSuccess), name: Notification.Name.uploadSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadFailure), name: Notification.Name.uploadFailure, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestFolderPath), name: Notification.Name.requestFolderPath, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadStarted), name: Notification.Name.uploadStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadFinished), name: Notification.Name.uploadFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBatchUploadStarted), name: Notification.Name.batchUploadStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBatchUploadFinished), name: Notification.Name.batchUploadFinished, object: nil)


        if defaults.object(forKey: "showNotifications") == nil {
            defaults.set(true, forKey: "showNotifications") // По умолчанию: показывать уведомления
        }
        if defaults.object(forKey: "enableSound") == nil {
            defaults.set(false, forKey: "enableSound") // По умолчанию: звук выключен
        }
        if defaults.object(forKey: "startMonitoringOnLaunch") == nil {
            defaults.set(true, forKey: "startMonitoringOnLaunch") // По умолчанию: запускать отслеживание при старте
        }
        if defaults.object(forKey: "renameFileOnUpload") == nil {
            defaults.set(true, forKey: "renameFileOnUpload") // По умолчанию: переименовывать файлы
        }
        if defaults.object(forKey: "clipboardUploadFormat") == nil {
            defaults.set("jpg", forKey: "clipboardUploadFormat") // По умолчанию: JPG
        }
        if defaults.object(forKey: "copyBeforeUpload") == nil {
            defaults.set(false, forKey: "copyBeforeUpload") // По умолчанию: не копировать в буфер перед загрузкой
        }
        if defaults.object(forKey: "copyOnlyFromMonosnap") == nil {
            defaults.set(false, forKey: "copyOnlyFromMonosnap") // По умолчанию: не копировать только из Monosnap
        }
        if defaults.object(forKey: "uploadCopiedFiles") == nil {
            defaults.set(false, forKey: "uploadCopiedFiles") // По умолчанию: не загружать скопированные файлы
        }
        if defaults.object(forKey: "launchAtSystemStartup") == nil {
            // При первом запуске синхронизируем состояние с LaunchAtLoginManager
            let isEnabled = LaunchAtLoginManager.shared.isLaunchAtLoginEnabled()
            defaults.set(isEnabled, forKey: "launchAtSystemStartup")
        } else {
            // Если настройка уже есть, убедимся, что LaunchAtLoginManager соответствует ей
            let savedState = defaults.bool(forKey: "launchAtSystemStartup")
            if LaunchAtLoginManager.shared.isLaunchAtLoginEnabled() != savedState {
                LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: savedState)
            }
        }
        if defaults.object(forKey: "maxFileSizeLimit") == nil {
            defaults.set(200, forKey: "maxFileSizeLimit") // По умолчанию: 200 Мб
        }
        if defaults.object(forKey: "isMaxFileSizeLimitEnabled") == nil {
            defaults.set(false, forKey: "isMaxFileSizeLimitEnabled") // По умолчанию: ограничение размера файла выключено
        }

        // Инициализируем и проверяем папки
        // Если folderPath не установлен, setupFolders отправит .requestFolderPath, который откроет настройки
        _ = FolderMonitor.shared.setupFolders()

        // Проверяем настройку автоматического запуска отслеживания
        // Запускаем мониторинг только если папка выбрана и настройка включена
        if defaults.bool(forKey: "startMonitoringOnLaunch") && defaults.string(forKey: "folderPath") != nil {
            FolderMonitor.shared.startMonitoring()
            updateMenuStatus()
        }
        
        // Регистрируем горячую клавишу
        reRegisterHotkey()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        // Логика сохранения настроек перенесена в SettingsWindowController
        FolderMonitor.shared.stopMonitoring() // Останавливаем отслеживание при завершении работы
        NotificationCenter.default.removeObserver(self) // Отписываемся от всех уведомлений
        
        // Отменяем регистрацию горячей клавиши
        hotkeyManager.unregisterHotkey()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func statusBarButtonClicked(sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseDown {
            statusItem?.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        } else {
            // Левый клик - показать/скрыть меню
            statusItem?.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        }
    }

    @objc func showApp() {
        // Активируем приложение и показываем главное окно
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc func quitApp() {
        NSApp.terminate(self)
    }

    @objc func toggleFolderMonitoring() {
        let defaults = UserDefaults.standard
        let folderPath = defaults.string(forKey: "folderPath")

        if FolderMonitor.shared.isMonitoring {
            FolderMonitor.shared.stopMonitoring()
        } else {
            // Проверяем, выбрана ли папка
            if let path = folderPath, !path.isEmpty {
                FolderMonitor.shared.startMonitoring()
            } else {
                // Если папка не выбрана, выводим уведомление и открываем настройки
                sendNotification(title: "Папка не выбрана", subtitle: "Отслеживание не начато", body: "Пожалуйста, укажите папку для отслеживания в настройках.")
                openSettings()
            }
        }
        updateMenuStatus()
    }

    @objc func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        // Добавляем небольшую задержку перед активацией, чтобы окно успело появиться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            NSApp.activate(ignoringOtherApps: true) // Активируем приложение
            self?.settingsWindowController?.window?.makeKeyAndOrderFront(nil) // Принудительно выводим окно на передний план
        }
    }

    @objc func testNotification() {
        sendNotification(title: "Тестовое уведомление", subtitle: "Это проверка", body: "Уведомления работают корректно!")
    }

    func updateMenuStatus() {
        if let menu = statusItem?.menu {
            // Индексы изменились после добавления нового пункта меню и разделителя
            if let toggleItem = menu.item(at: 2) { // "Запустить/Остановить отслеживание папки"
                toggleItem.title = FolderMonitor.shared.isMonitoring ? "Остановить отслеживание папки" : "Запустить отслеживание папки"
            }
            if let statusItem = menu.item(at: 3) { // "Статус: Запущено/Остановлено"
                statusItem.title = FolderMonitor.shared.isMonitoring ? "Статус: Запущено" : "Статус: Остановлено"
            }
        }
    }

    private func updateStatusItemImage() {
        guard let button = statusItem?.button else { return }

        if isUploading {
            // Запускаем анимацию загрузки
            let animationImages = [
                NSImage(named: "loading_frame_1"),
                NSImage(named: "loading_frame_2"),
                NSImage(named: "loading_frame_3")
            ].compactMap { $0 }
            button.startAnimating(images: animationImages, duration: 0.5)
        } else {
            // Возвращаем обычную иконку
            button.stopAnimating()
            button.image = NSImage(named: "MenuBarIcon")
        }
    }

    private func updateDockIconAnimation() {
        let showDockIcon = UserDefaults.standard.bool(forKey: "showDockIcon")
        guard showDockIcon else { return } // Анимируем только если иконка в доке видима

        if isUploading {
            // Начинаем анимацию
            if dockAnimationTimer == nil {
                dockAnimationFrames = [
                    NSImage(named: "dock_loading_frame_1"),
                    NSImage(named: "dock_loading_frame_2"),
                    NSImage(named: "dock_loading_frame_3")
                ].compactMap { $0 }

                guard !dockAnimationFrames.isEmpty else {
                    print("Не найдены кадры для анимации иконки в доке.")
                    return
                }

                dockAnimationTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(animateDockIcon), userInfo: nil, repeats: true)
            }
        } else {
            // Останавливаем анимацию
            dockAnimationTimer?.invalidate()
            dockAnimationTimer = nil
            currentDockFrameIndex = 0
            // Надежно восстанавливаем исходную иконку из Assets
            NSApp.applicationIconImage = NSImage(named: "AppIcon")
        }
    }

    @objc private func animateDockIcon() {
        guard !dockAnimationFrames.isEmpty else {
            dockAnimationTimer?.invalidate()
            dockAnimationTimer = nil
            return
        }
        NSApp.applicationIconImage = dockAnimationFrames[currentDockFrameIndex]
        currentDockFrameIndex = (currentDockFrameIndex + 1) % dockAnimationFrames.count
    }

    // MARK: - UNUserNotificationCenterDelegate (Изменено)

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // Показываем баннер и воспроизводим звук
    }

    // MARK: - Notification Handlers

    @objc func handleFolderMonitoringStatusChanged() {
        updateMenuStatus()
    }

    @objc func handleUploadStarted() {
        isUploading = true
    }

    @objc func handleUploadSuccess(notification: Notification) {
        // Этот метод теперь обрабатывает только одиночные загрузки (например, из старой логики мониторинга, если она осталась)
        isUploading = false
        if let userInfo = notification.userInfo,
           let fileName = userInfo["fileName"] as? String,
           let url = userInfo["url"] as? String {
            sendNotification(title: "Загрузка завершена", subtitle: fileName, body: "URL скопирован в буфер обмена.")
            print("Успешная загрузка: \(fileName), URL: \(url)")
        }
    }

    @objc func handleUploadFailure(notification: Notification) {
        // Этот метод теперь обрабатывает только одиночные ошибки
        isUploading = false
        if let userInfo = notification.userInfo,
           let fileName = userInfo["fileName"] as? String,
           let error = userInfo["error"] as? String {
            sendNotification(title: "Ошибка загрузки", subtitle: fileName, body: "Не удалось загрузить файл: \(error)")
            print("Ошибка загрузки: \(fileName), Ошибка: \(error)")
        }
    }

    @objc func handleUploadFinished() {
        isUploading = false

        // После завершения загрузки проверяем, нужно ли скрыть иконку из дока (вернуть в состояние accessory)
        // Это решает проблему, когда перетаскивание на иконку в доке "активирует" приложение
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Небольшая задержка для стабильности
            let showDockIcon = UserDefaults.standard.bool(forKey: "showDockIcon")
            if !showDockIcon {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }

    @objc func handleRequestFolderPath() {
        sendNotification(title: "Требуется настройка", subtitle: "Папка для отслеживания не найдена", body: "Пожалуйста, укажите папку для отслеживания в настройках приложения.")
        openSettings() // Открываем окно настроек, чтобы пользователь мог выбрать папку
    }

    // MARK: - Notification Methods

    func sendNotification(title: String, subtitle: String?, body: String) {
        let defaults = UserDefaults.standard
        let showNotifications = defaults.bool(forKey: "showNotifications") // Изменено
        let enableSound = defaults.bool(forKey: "enableSound") // Изменено

        guard showNotifications else { return } // Если уведомления не включены, не отправляем

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle ?? ""
        content.body = body
        if enableSound { // Изменено
            content.sound = UNNotificationSound.default // Звук уведомления
        }

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при отправке уведомления: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Drag & Drop on Dock Icon

    func application(_ sender: NSApplication, openFiles fileNames: [String]) {
        let urls = fileNames.map { URL(fileURLWithPath: $0) }
        handleDroppedFiles(urls: urls)
    }

    // MARK: - Centralized Drag & Drop Handling

    func handleDroppedFiles(urls: [URL]) {
        print("Обработка перетащенных файлов: \(urls.map { $0.lastPathComponent })")
        FolderMonitor.shared.startBatchUpload(urls: urls, isMonitored: false)
    }

    // MARK: - Batch Upload Notification Handlers

    @objc func handleBatchUploadStarted(notification: Notification) {
        if let count = notification.userInfo?["count"] as? Int {
            sendNotification(title: "Началась массовая загрузка", subtitle: "Файлов: \(count)", body: "Пожалуйста, подождите...")
        }
    }

    @objc func handleBatchUploadFinished(notification: Notification) {
        if let summary = notification.userInfo,
           let total = summary["total"] as? Int,
           let success = summary["success"] as? Int,
           let error = summary["error"] as? Int {
            let title = "Массовая загрузка завершена"
            let body = "Успешно: \(success) из \(total). Ошибки: \(error)."
            sendNotification(title: title, subtitle: nil, body: body)
        }
    }

    // MARK: - Hotkey Handler
    @objc func handleHotkeyTriggered() {
        print("Hotkey triggered!")

        let defaults = UserDefaults.standard
        let copyBeforeUpload = defaults.bool(forKey: "copyBeforeUpload")
        let copyOnlyFromMonosnap = defaults.bool(forKey: "copyOnlyFromMonosnap")

        if copyBeforeUpload {
            // Проверяем права на управление другими приложениями
            if !AccessibilityManager.shared.hasAccessibilityPermissions() {
                print("Нет прав на управление другими приложениями")
                AccessibilityManager.shared.showAccessibilityPermissionAlert()
                return
            }

            if copyOnlyFromMonosnap {
                // Проверяем, является ли активное приложение Monosnap
                if AccessibilityManager.shared.isActiveApplicationMonosnap() {
                    print("Активное приложение - Monosnap, симулируем копирование")
                    // Симулируем копирование
                    AccessibilityManager.shared.simulateCopy()

                    // Даем время на копирование (0.2 секунды)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.uploadFromClipboard()
                    }
                } else {
                    print("Активное приложение не Monosnap, загружаем из буфера без копирования")
                    // Просто загружаем из буфера без симуляции Cmd+C
                    uploadFromClipboard()
                }
            } else {
                // Старое поведение: симулируем копирование для любого приложения
                print("Копировать перед загрузкой включено, симулируем копирование")
                AccessibilityManager.shared.simulateCopy()

                // Даем время на копирование (0.2 секунды)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.uploadFromClipboard()
                }
            }
        } else {
            // Обычная загрузка из буфера
            print("Копировать перед загрузкой выключено, загружаем из буфера")
            uploadFromClipboard()
        }
    }
    
    func reRegisterHotkey() {
        if let encodedKeyCombo = UserDefaults.standard.data(forKey: "globalHotkey"),
           let keyCombo = try? JSONDecoder().decode(KeyCombo.self, from: encodedKeyCombo) {
            hotkeyManager.registerHotkey(keyCombo: keyCombo, target: self, selector: #selector(handleHotkeyTriggered))
        } else {
            // Если горячая клавиша не сохранена или очищена, отменяем регистрацию
            hotkeyManager.unregisterHotkey()
        }
    }

    // MARK: - Upload from Clipboard

    @objc func uploadFromClipboard() {
        let pasteboard = NSPasteboard.general
        let defaults = UserDefaults.standard
        let uploadCopiedFiles = defaults.bool(forKey: "uploadCopiedFiles")
        let maxFileSizeLimit = defaults.integer(forKey: "maxFileSizeLimit")
        let maxFileSizeBytes = maxFileSizeLimit * 1024 * 1024 // Конвертируем Мб в байты

        // Шаг 1: Проверяем, есть ли в буфере ссылка на файл
        if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !fileURLs.isEmpty {
            let fileURL = fileURLs[0]

            if uploadCopiedFiles {
                // Проверяем размер файла
                do {
                    let fileManager = FileManager.default
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    let fileSize = attributes[.size] as? Int64 ?? 0

                    if fileSize > maxFileSizeBytes {
                        let fileSizeMB = Double(fileSize) / (1024 * 1024)
                        sendNotification(title: "Файл слишком большой", subtitle: fileURL.lastPathComponent, body: "Файл (\(String(format: "%.1f", fileSizeMB)) Мб) превышает установленный лимит в \(maxFileSizeLimit) Мб.")
                        return
                    }

                    // Загружаем файл по ссылке
                    print("Найден файл в буфере обмена, загружаем: \(fileURL.lastPathComponent) (\(fileSize) bytes)")
                    FolderMonitor.shared.startBatchUpload(urls: fileURLs, isMonitored: false)
                } catch {
                    sendNotification(title: "Ошибка", subtitle: nil, body: "Не удалось получить информацию о файле: \(error.localizedDescription)")
                }
                return
            } else {
                // Пользователь запретил загрузку файлов
                sendNotification(title: "Загрузка файлов запрещена", subtitle: nil, body: "В буфере обмена найден файл, но загрузка файлов запрещена в настройках.")
                return
            }
        }

        // Шаг 2: Если файлов нет или они запрещены, проверяем на наличие изображения
        guard let image = pasteboard.readObjects(forClasses: [NSImage.self])?.first as? NSImage else {
            sendNotification(title: "Ошибка", subtitle: nil, body: "В буфере обмена нет изображения или файла для загрузки.")
            return
        }

        guard let tiffData = image.tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: tiffData) else {
            sendNotification(title: "Ошибка", subtitle: nil, body: "Не удалось обработать изображение из буфера обмена.")
            return
        }

        let format = defaults.string(forKey: "clipboardUploadFormat") ?? "png"
        let quality = defaults.integer(forKey: "clipboardJpgQuality")
        let compressionFactor = CGFloat(quality) / 100.0

        var imageData: Data?
        var fileExtension: String

        if format == "jpg" {
            imageData = imageRep.representation(using: .jpeg, properties: [.compressionFactor: compressionFactor])
            fileExtension = "jpg"
        } else { // Default to PNG
            imageData = imageRep.representation(using: .png, properties: [:])
            fileExtension = "png"
        }

        guard let finalImageData = imageData else {
            sendNotification(title: "Ошибка", subtitle: nil, body: "Не удалось конвертировать изображение в выбранный формат.")
            return
        }

        // Проверяем размер изображения
        let imageSizeBytes = Int64(finalImageData.count)
        if imageSizeBytes > maxFileSizeBytes {
            let imageSizeMB = Double(imageSizeBytes) / (1024 * 1024)
            sendNotification(title: "Изображение слишком большое", subtitle: nil, body: "Изображение (\(String(format: "%.1f", imageSizeMB)) Мб) превышает установленный лимит в \(maxFileSizeLimit) Мб.")
            return
        }

        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "clipboard-\(UUID().uuidString).\(fileExtension)"
        let tempURL = tempDirectory.appendingPathComponent(fileName)

        do {
            try finalImageData.write(to: tempURL)
            print("Изображение из буфера обмена сохранено во временный файл: \(tempURL.path) (\(imageSizeBytes) bytes)")
            FolderMonitor.shared.startBatchUpload(urls: [tempURL], isMonitored: false, deleteAfterUpload: true) // Передаем флаг для удаления
        } catch {
            sendNotification(title: "Ошибка", subtitle: nil, body: "Не удалось сохранить изображение во временный файл: \(error.localizedDescription)")
            print("Ошибка сохранения изображения из буфера обмена: \(error.localizedDescription)")
        }
    }
}
