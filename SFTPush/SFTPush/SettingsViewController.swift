//
//  SettingsViewController.swift
//  
//
//  Created by Alex Masibut on 24.09.2025.
//

import Cocoa

class SettingsViewController: NSViewController {

    // MARK: - UI Elements (General Settings)
    let folderPathTextField = NSTextField()
    let selectFolderButton = NSButton(title: "Выбрать папку", target: nil, action: nil)
    let showNotificationsCheckbox = NSButton(checkboxWithTitle: "Показывать уведомления", target: nil, action: nil)
    let enableSoundCheckbox = NSButton(checkboxWithTitle: "Включить звук уведомлений", target: nil, action: nil)
    let startMonitoringOnLaunchCheckbox = NSButton(checkboxWithTitle: "Старт отслеживания папки при старте приложения", target: nil, action: nil)
    let launchAtSystemStartupCheckbox = NSButton(checkboxWithTitle: "Автозапуск приложения при старте системы", target: nil, action: nil)
    let renameFileOnUploadCheckbox = NSButton(checkboxWithTitle: "Изменять имя файла при загрузке", target: nil, action: nil)
    let showDockIconCheckbox = NSButton(checkboxWithTitle: "Показывать иконку приложения в доке", target: nil, action: nil)

    // MARK: - UI Elements (Clipboard Upload Settings)
    let clipboardFormatLabel = NSTextField(labelWithString: "Формат загрузки из буфера:")
    let clipboardFormatControl = NSSegmentedControl(labels: ["PNG", "JPG"], trackingMode: .selectOne, target: nil, action: nil)
    let jpgQualityLabel = NSTextField(labelWithString: "Качество JPG (10-100):")
    let jpgQualitySlider = NSSlider(value: 80, minValue: 10, maxValue: 100, target: nil, action: nil)
    let jpgQualityValueLabel = NSTextField(labelWithString: "80")

    // MARK: - UI Elements (Hotkey Settings)
    var hotkeyRecorderView: HotkeyRecorderView!
    let clearHotkeyButton = NSButton(title: "Очистить", target: nil, action: nil)

    // MARK: - UI Elements (SFTP Settings)
    let sftpHostTextField = NSTextField()
    let sftpPortTextField = NSTextField()
    let sftpUserTextField = NSTextField()
    let sftpPasswordSecureTextField = NSSecureTextField()
    let sftpFolderTextField = NSTextField()
    let sftpBaseUrlTextField = NSTextField()
    let testConnectionButton = NSButton(title: "Тест соединения", target: nil, action: nil)

    // MARK: - Common UI Elements
    let tabView = NSTabView()
    // Кнопка "Сохранить" удалена, сохранение будет происходить при закрытии окна

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        // saveSettings() // Логика сохранения перенесена в AppDelegate
    }

    private func setupUI() {
        view.addSubview(tabView)
        // view.addSubview(saveButton) // Кнопка "Сохранить" удалена

        tabView.translatesAutoresizingMaskIntoConstraints = false
        // saveButton.translatesAutoresizingMaskIntoConstraints = false // Кнопка "Сохранить" удалена

        // Setup TabView
        let generalTabItem = NSTabViewItem(identifier: "General")
        generalTabItem.label = "Основные"
        let generalView = NSView()
        generalView.translatesAutoresizingMaskIntoConstraints = false // Отключаем автоматические констрейнты
        generalTabItem.view = generalView
        tabView.addTabViewItem(generalTabItem)

        let sftpTabItem = NSTabViewItem(identifier: "SFTP")
        sftpTabItem.label = "SFTP"
        let sftpView = NSView()
        sftpTabItem.view = sftpView
        tabView.addTabViewItem(sftpTabItem)

        let clipboardHotkeyTabItem = NSTabViewItem(identifier: "ClipboardHotkey")
        clipboardHotkeyTabItem.label = "Буфер и Хоткеи"
        let clipboardHotkeyView = NSView()
        clipboardHotkeyTabItem.view = clipboardHotkeyView
        tabView.addTabViewItem(clipboardHotkeyTabItem)

        // Constraints for TabView
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20) // Занимает все доступное пространство
        ])

        setupGeneralTab(in: generalView)
        setupSFTPTab(in: sftpView)
        setupClipboardHotkeyTab(in: clipboardHotkeyView)

        // Save Button Action (удалено)
        // saveButton.target = self
        // saveButton.action = #selector(saveSettingsClicked)
    }

    private func setupGeneralTab(in view: NSView) {
        // Main container
        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        // Folder Selection Section - IN THE VERY TOP
        let folderTitle = NSTextField(labelWithString: "Папка для отслеживания")
        folderTitle.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        folderTitle.textColor = NSColor.labelColor
        folderTitle.translatesAutoresizingMaskIntoConstraints = false

        let folderSection = NSStackView()
        folderSection.orientation = .horizontal
        folderSection.alignment = .centerY
        folderSection.spacing = 10
        folderSection.translatesAutoresizingMaskIntoConstraints = false

        folderPathTextField.translatesAutoresizingMaskIntoConstraints = false
        selectFolderButton.translatesAutoresizingMaskIntoConstraints = false

        folderSection.addArrangedSubview(folderPathTextField)
        folderSection.addArrangedSubview(selectFolderButton)

        // Behavior Section
        let behaviorTitle = NSTextField(labelWithString: "Поведение")
        behaviorTitle.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        behaviorTitle.textColor = NSColor.labelColor
        behaviorTitle.translatesAutoresizingMaskIntoConstraints = false

        let checkboxesStack = NSStackView()
        checkboxesStack.orientation = .vertical
        checkboxesStack.alignment = .leading
        checkboxesStack.spacing = 10
        checkboxesStack.translatesAutoresizingMaskIntoConstraints = false

        showNotificationsCheckbox.translatesAutoresizingMaskIntoConstraints = false
        enableSoundCheckbox.translatesAutoresizingMaskIntoConstraints = false
        startMonitoringOnLaunchCheckbox.translatesAutoresizingMaskIntoConstraints = false
        launchAtSystemStartupCheckbox.translatesAutoresizingMaskIntoConstraints = false
        renameFileOnUploadCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showDockIconCheckbox.translatesAutoresizingMaskIntoConstraints = false

        checkboxesStack.addArrangedSubview(showNotificationsCheckbox)
        checkboxesStack.addArrangedSubview(enableSoundCheckbox)
        checkboxesStack.addArrangedSubview(startMonitoringOnLaunchCheckbox)
        checkboxesStack.addArrangedSubview(launchAtSystemStartupCheckbox)
        checkboxesStack.addArrangedSubview(renameFileOnUploadCheckbox)
        checkboxesStack.addArrangedSubview(showDockIconCheckbox)

        // Add all elements to main stack
        mainStack.addArrangedSubview(folderTitle)
        mainStack.addArrangedSubview(folderSection)
        mainStack.addArrangedSubview(behaviorTitle)
        mainStack.addArrangedSubview(checkboxesStack)

        // Setup targets and actions
        selectFolderButton.target = self
        selectFolderButton.action = #selector(selectFolderClicked)

        showNotificationsCheckbox.target = self
        showNotificationsCheckbox.action = #selector(showNotificationsChanged)
        enableSoundCheckbox.target = self
        enableSoundCheckbox.action = #selector(enableSoundChanged)
        startMonitoringOnLaunchCheckbox.target = self
        startMonitoringOnLaunchCheckbox.action = #selector(startMonitoringOnLaunchChanged)
        launchAtSystemStartupCheckbox.target = self
        launchAtSystemStartupCheckbox.action = #selector(launchAtSystemStartupChanged)
        renameFileOnUploadCheckbox.target = self
        renameFileOnUploadCheckbox.action = #selector(renameFileOnUploadChanged)
        showDockIconCheckbox.target = self
        showDockIconCheckbox.action = #selector(showDockIconChanged)

        // Text Field Settings
        folderPathTextField.placeholderString = "Путь к папке для отслеживания"
        folderPathTextField.isEditable = false
        folderPathTextField.delegate = self // Устанавливаем делегат для обработки длинных путей

        // Constraints
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            folderPathTextField.widthAnchor.constraint(equalToConstant: 300),
            folderPathTextField.heightAnchor.constraint(equalToConstant: 24),
            selectFolderButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 400)) // Оптимизированный размер окна
    }

    private func setupSFTPTab(in view: NSView) {
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.alignment = .leading // Изменено на .leading для выравнивания по левому краю
        stackView.spacing = 10
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        let fields: [(String, NSTextField)] = [
            ("Host:", sftpHostTextField),
            ("Port:", sftpPortTextField),
            ("User:", sftpUserTextField),
            ("Password:", sftpPasswordSecureTextField),
            ("Folder:", sftpFolderTextField),
            ("Base URL:", sftpBaseUrlTextField)
        ]

        for (label, textField) in fields {
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.alignment = .centerY
            rowStack.spacing = 10

            let labelView = NSTextField(labelWithString: label)
            labelView.translatesAutoresizingMaskIntoConstraints = false
            labelView.widthAnchor.constraint(equalToConstant: 80).isActive = true // Фиксированная ширина для меток

            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholderString = label.replacingOccurrences(of: ":", with: "")
            textField.widthAnchor.constraint(equalToConstant: 250).isActive = true // Фиксированная ширина для полей

            rowStack.addArrangedSubview(labelView)
            rowStack.addArrangedSubview(textField)
            stackView.addArrangedSubview(rowStack)
        }

        // Port field should only accept numbers
        sftpPortTextField.formatter = NumberFormatter()
        sftpPortTextField.delegate = self // Устанавливаем делегат для валидации ввода

        // Test Connection Button
        testConnectionButton.target = self
        testConnectionButton.action = #selector(testConnectionClicked)
        stackView.addArrangedSubview(testConnectionButton)
    }

    private func setupClipboardHotkeyTab(in view: NSView) {
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 20
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Clipboard Upload Section
        let clipboardSection = NSStackView()
        clipboardSection.orientation = .vertical
        clipboardSection.alignment = .leading
        clipboardSection.spacing = 10

        let clipboardTitle = NSTextField(labelWithString: "Формат загрузки из буфера обмена")
        clipboardTitle.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        clipboardTitle.textColor = NSColor.labelColor

        let clipboardControlsStack = NSStackView()
        clipboardControlsStack.orientation = .horizontal
        clipboardControlsStack.alignment = .centerY
        clipboardControlsStack.spacing = 10

        clipboardFormatControl.translatesAutoresizingMaskIntoConstraints = false
        jpgQualityLabel.translatesAutoresizingMaskIntoConstraints = false
        jpgQualitySlider.translatesAutoresizingMaskIntoConstraints = false
        jpgQualityValueLabel.translatesAutoresizingMaskIntoConstraints = false

        clipboardControlsStack.addArrangedSubview(clipboardFormatLabel)
        clipboardControlsStack.addArrangedSubview(clipboardFormatControl)

        clipboardSection.addArrangedSubview(clipboardTitle)
        clipboardSection.addArrangedSubview(clipboardControlsStack)

        // JPG Quality controls (initially hidden)
        let jpgControlsStack = NSStackView()
        jpgControlsStack.orientation = .horizontal
        jpgControlsStack.alignment = .centerY
        jpgControlsStack.spacing = 10
        jpgControlsStack.addArrangedSubview(jpgQualityLabel)
        jpgControlsStack.addArrangedSubview(jpgQualitySlider)
        jpgControlsStack.addArrangedSubview(jpgQualityValueLabel)

        clipboardSection.addArrangedSubview(jpgControlsStack)

        // Hotkey Section
        let hotkeySection = NSStackView()
        hotkeySection.orientation = .vertical
        hotkeySection.alignment = .leading
        hotkeySection.spacing = 10

        let hotkeyTitle = NSTextField(labelWithString: "Горячие клавиши")
        hotkeyTitle.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        hotkeyTitle.textColor = NSColor.labelColor

        let hotkeyDescription = NSTextField(labelWithString: "Отправить изображение из буфера на сервер:")
        hotkeyDescription.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        hotkeyDescription.textColor = NSColor.secondaryLabelColor
        hotkeyDescription.translatesAutoresizingMaskIntoConstraints = false

        let hotkeyControlsStack = NSStackView()
        hotkeyControlsStack.orientation = .horizontal
        hotkeyControlsStack.alignment = .centerY
        hotkeyControlsStack.spacing = 10

        hotkeyRecorderView = HotkeyRecorderView()
        hotkeyRecorderView.translatesAutoresizingMaskIntoConstraints = false
        hotkeyRecorderView.delegate = self

        clearHotkeyButton.translatesAutoresizingMaskIntoConstraints = false

        hotkeyControlsStack.addArrangedSubview(hotkeyRecorderView)
        hotkeyControlsStack.addArrangedSubview(clearHotkeyButton)

        hotkeySection.addArrangedSubview(hotkeyTitle)
        hotkeySection.addArrangedSubview(hotkeyDescription)
        hotkeySection.addArrangedSubview(hotkeyControlsStack)

        stackView.addArrangedSubview(clipboardSection)
        stackView.addArrangedSubview(hotkeySection)

        // Setup targets and actions
        clipboardFormatControl.target = self
        clipboardFormatControl.action = #selector(clipboardFormatChanged)
        jpgQualitySlider.target = self
        jpgQualitySlider.action = #selector(jpgQualitySliderChanged)
        clearHotkeyButton.target = self
        clearHotkeyButton.action = #selector(clearHotkeyClicked)

        // Setup constraints
        NSLayoutConstraint.activate([
            hotkeyRecorderView.widthAnchor.constraint(equalToConstant: 150),
            hotkeyRecorderView.heightAnchor.constraint(equalToConstant: 24),
            jpgQualitySlider.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        // General Settings
        folderPathTextField.stringValue = defaults.string(forKey: "folderPath") ?? FolderMonitor.shared.folderPath
        showNotificationsCheckbox.state = defaults.bool(forKey: "showNotifications") ? .on : .off
        enableSoundCheckbox.state = defaults.bool(forKey: "enableSound") ? .on : .off
        startMonitoringOnLaunchCheckbox.state = defaults.bool(forKey: "startMonitoringOnLaunch") ? .on : .off
        launchAtSystemStartupCheckbox.state = defaults.bool(forKey: "launchAtSystemStartup") ? .on : .off // Читаем из UserDefaults
        renameFileOnUploadCheckbox.state = defaults.bool(forKey: "renameFileOnUpload") ? .on : .off
        showDockIconCheckbox.state = defaults.bool(forKey: "showDockIcon") ? .on : .off

        // Clipboard Upload Settings
        let savedFormat = defaults.string(forKey: "clipboardUploadFormat") ?? "png"
        clipboardFormatControl.selectedSegment = (savedFormat == "png") ? 0 : 1
        let savedQuality = defaults.integer(forKey: "clipboardJpgQuality")
        jpgQualitySlider.doubleValue = (savedQuality == 0) ? 80 : Double(savedQuality) // Default to 80 if not set
        jpgQualityValueLabel.stringValue = "\(Int(jpgQualitySlider.doubleValue))"
        updateJpgQualityVisibility() // Обновляем видимость элементов качества JPG

        // SFTP Settings
        sftpHostTextField.stringValue = defaults.string(forKey: "sftpHost") ?? ""
        sftpPortTextField.stringValue = defaults.string(forKey: "sftpPort") ?? "22"
        sftpUserTextField.stringValue = defaults.string(forKey: "sftpUser") ?? ""
        sftpPasswordSecureTextField.stringValue = defaults.string(forKey: "sftpPassword") ?? ""
        sftpFolderTextField.stringValue = defaults.string(forKey: "sftpFolder") ?? "/"
        sftpBaseUrlTextField.stringValue = defaults.string(forKey: "sftpBaseUrl") ?? ""
        
        // Update FolderMonitor
        FolderMonitor.shared.folderPath = folderPathTextField.stringValue
        // SFTP settings will be passed to FolderMonitor when needed (e.g., for upload or test connection)
        
        // Load Hotkey
        if let encodedKeyCombo = defaults.data(forKey: "globalHotkey"),
           let keyCombo = try? JSONDecoder().decode(KeyCombo.self, from: encodedKeyCombo) {
            hotkeyRecorderView.currentKeyCombo = keyCombo
        } else {
            hotkeyRecorderView.currentKeyCombo = nil
        }

        // Update folder path display with truncation if needed
        updateFolderPathDisplay()
    }

    private func updateFolderPathDisplay() {
        let fullPath = folderPathTextField.stringValue
        if !fullPath.isEmpty {
            let truncatedPath = truncatePath(fullPath, maxLength: 45)
            // Обновляем только если путь действительно изменился (чтобы избежать бесконечной рекурсии)
            if folderPathTextField.stringValue != truncatedPath {
                folderPathTextField.stringValue = truncatedPath
            }
        }
    }

    private func truncatePath(_ path: String, maxLength: Int) -> String {
        // Если путь короче максимальной длины, возвращаем как есть
        if path.count <= maxLength {
            return path
        }

        // Находим компоненты пути
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
        guard components.count > 1 else {
            return path
        }

        // Пытаемся сократить путь, показывая начало и конец
        let startComponent = components.first ?? ""
        let endComponents = Array(components.dropFirst())

        // Вычисляем доступную длину для конечных компонентов
        let availableLength = maxLength - (startComponent + ".../").count - 1

        var result = "/\(startComponent)"

        // Добавляем конечные компоненты, если есть место
        if availableLength > 0 {
            var remainingComponents = endComponents
            var currentLength = 0

            // Идем с конца, пока помещается
            while !remainingComponents.isEmpty {
                let component = remainingComponents.last ?? ""
                let componentWithSlash = "/\(component)"

                if currentLength + componentWithSlash.count <= availableLength {
                    result += componentWithSlash
                    currentLength += componentWithSlash.count
                    remainingComponents.removeLast()
                } else {
                    break
                }
            }

            // Если есть оставшиеся компоненты, добавляем троеточие
            if !remainingComponents.isEmpty {
                result += "/..."
            }
        } else {
            result += "/..."
        }

        return result
    }
    }

    func saveSettings() {
        let defaults = UserDefaults.standard

        // General Settings
        defaults.set(self.folderPathTextField.stringValue, forKey: "folderPath")
        defaults.set(self.showNotificationsCheckbox.state == .on, forKey: "showNotifications")
        defaults.set(self.enableSoundCheckbox.state == .on, forKey: "enableSound")
        defaults.set(self.startMonitoringOnLaunchCheckbox.state == .on, forKey: "startMonitoringOnLaunch")
        defaults.set(self.launchAtSystemStartupCheckbox.state == .on, forKey: "launchAtSystemStartup") // Сохраняем состояние чекбокса автозапуска
        defaults.set(self.renameFileOnUploadCheckbox.state == .on, forKey: "renameFileOnUpload")
        defaults.set(self.showDockIconCheckbox.state == .on, forKey: "showDockIcon")

        // Clipboard Upload Settings
        let selectedFormat = (self.clipboardFormatControl.selectedSegment == 0) ? "png" : "jpg"
        defaults.set(selectedFormat, forKey: "clipboardUploadFormat")
        defaults.set(Int(self.jpgQualitySlider.doubleValue), forKey: "clipboardJpgQuality")

        // SFTP Settings
        defaults.set(self.sftpHostTextField.stringValue, forKey: "sftpHost")
        defaults.set(self.sftpPortTextField.stringValue, forKey: "sftpPort")
        defaults.set(self.sftpUserTextField.stringValue, forKey: "sftpUser")
        defaults.set(self.sftpPasswordSecureTextField.stringValue, forKey: "sftpPassword")
        defaults.set(self.sftpFolderTextField.stringValue, forKey: "sftpFolder")
        defaults.set(self.sftpBaseUrlTextField.stringValue, forKey: "sftpBaseUrl")

        // Update LaunchAtLoginManager
        LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: self.launchAtSystemStartupCheckbox.state == .on)

        // Update FolderMonitor
        FolderMonitor.shared.folderPath = self.folderPathTextField.stringValue

        print("Настройки сохранены.")
    }

    @objc private func selectFolderClicked() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = "Выбрать"

        openPanel.begin { [weak self] (result) in
            if result == .OK {
                if let url = openPanel.url {
                    self?.folderPathTextField.stringValue = url.path
                    self?.saveSettings() // Сохраняем настройки немедленно
                }
            }
        }
    }

    @objc private func showNotificationsChanged() {
        saveSettings()
        print("Показывать уведомления: \(showNotificationsCheckbox.state == .on)")
    }
    
    @objc private func enableSoundChanged() {
        saveSettings()
        print("Включить звук уведомлений: \(enableSoundCheckbox.state == .on)")
    }

    @objc private func startMonitoringOnLaunchChanged() {
        saveSettings()
        print("Запускать отслеживание при старте: \(startMonitoringOnLaunchCheckbox.state == .on)")
    }

    @objc private func launchAtSystemStartupChanged() {
        saveSettings()
        print("Автозапуск при старте системы: \(launchAtSystemStartupCheckbox.state == .on)")
    }

    @objc private func renameFileOnUploadChanged() {
        saveSettings()
        print("Изменить имя файла при загрузке: \(renameFileOnUploadCheckbox.state == .on)")
    }

    @objc private func showDockIconChanged() {
        saveSettings()
        let show = showDockIconCheckbox.state == .on
        print("Показывать иконку в доке: \(show)")
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
            // Этот трюк заставляет Dock перерисоваться и убрать иконку
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.activate(ignoringOtherApps: true)
                self.view.window?.makeKeyAndOrderFront(nil)
            }
        }
    }

    @objc private func clipboardFormatChanged() {
        saveSettings()
        updateJpgQualityVisibility()
        print("Формат загрузки из буфера: \(clipboardFormatControl.selectedSegment == 0 ? "PNG" : "JPG")")
    }

    @objc private func jpgQualitySliderChanged() {
        let quality = Int(jpgQualitySlider.doubleValue)
        jpgQualityValueLabel.stringValue = "\(quality)"
        saveSettings()
        print("Качество JPG: \(quality)")
    }

    private func updateJpgQualityVisibility() {
        let isJPGSelected = clipboardFormatControl.selectedSegment == 1 // 0 for PNG, 1 for JPG
        jpgQualityLabel.isHidden = !isJPGSelected
        jpgQualitySlider.isHidden = !isJPGSelected
        jpgQualityValueLabel.isHidden = !isJPGSelected
    }

    @objc private func testConnectionClicked() {
        let originalButtonTitle = testConnectionButton.title
        testConnectionButton.title = "Устанавливаем соединение..."
        testConnectionButton.isEnabled = false // Блокируем кнопку

        let host = sftpHostTextField.stringValue
        let port = Int(sftpPortTextField.stringValue) ?? 22
        let user = sftpUserTextField.stringValue
        let password = sftpPasswordSecureTextField.stringValue

        guard !host.isEmpty, !user.isEmpty, !password.isEmpty else {
            testConnectionButton.title = "Нет соединения"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.testConnectionButton.title = originalButtonTitle
                self?.testConnectionButton.isEnabled = true
            }
            return
        }

        print("Тест соединения SFTP...")
        FolderMonitor.shared.testSFTPConnection(host: host, port: port, user: user, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.testConnectionButton.title = "Соединение ОК"
                case .failure(_):
                    self?.testConnectionButton.title = "Нет соединения"
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.testConnectionButton.title = originalButtonTitle
                    self?.testConnectionButton.isEnabled = true
                }
            }
        }
    }
}

// MARK: - HotkeyRecorderViewDelegate
extension SettingsViewController: HotkeyRecorderViewDelegate {
    func hotkeyRecorderView(_ hotkeyRecorderView: HotkeyRecorderView, didReceiveKeyCombo keyCombo: KeyCombo?) {
        if let keyCombo = keyCombo {
            print("Получена горячая клавиша: \(keyCombo.description)")
            // Сохраняем горячую клавишу в UserDefaults
            if let encoded = try? JSONEncoder().encode(keyCombo) {
                UserDefaults.standard.set(encoded, forKey: "globalHotkey")
            }
        } else {
            print("Горячая клавиша очищена.")
            UserDefaults.standard.removeObject(forKey: "globalHotkey")
        }
        // Перерегистрируем горячую клавишу в AppDelegate
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.reRegisterHotkey()
        }
    }
}

// MARK: - Hotkey Actions
extension SettingsViewController {
    @objc private func clearHotkeyClicked() {
        hotkeyRecorderView.clearHotkey()
    }
}

// MARK: - NSTextFieldDelegate for Port field validation
extension SettingsViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, textField == sftpPortTextField {
            // Удаляем все символы, кроме цифр
            let filteredText = textField.stringValue.filter { $0.isNumber }
            if filteredText != textField.stringValue {
                textField.stringValue = filteredText
            }
        }
    }
}
