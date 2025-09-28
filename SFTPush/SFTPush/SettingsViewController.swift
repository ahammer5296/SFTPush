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

    // MARK: - UI Elements (Section Headers)
    let folderSectionHeader = NSTextField(labelWithString: "Папка для отслеживания")
    let behaviorSectionHeader = NSTextField(labelWithString: "Поведение")
    let imageFormatSectionHeader = NSTextField(labelWithString: "Формат изображения")
    let imageSettingsHeader = NSTextField(labelWithString: "Настройки изображения")
    let hotkeySectionHeader = NSTextField(labelWithString: "Хоткеи")
    let hotkeyDescriptionLabel = NSTextField(labelWithString: "Отправить на сервер изображение из буфера")
    let showNotificationsCheckbox = NSButton(checkboxWithTitle: "Показывать уведомления", target: nil, action: nil)
    let enableSoundCheckbox = NSButton(checkboxWithTitle: "Включить звук уведомлений", target: nil, action: nil)
    let startMonitoringOnLaunchCheckbox = NSButton(checkboxWithTitle: "Старт отслеживания папки при старте приложения", target: nil, action: nil)
    let launchAtSystemStartupCheckbox = NSButton(checkboxWithTitle: "Автозапуск приложения при старте системы", target: nil, action: nil)
    let renameFileOnUploadCheckbox = NSButton(checkboxWithTitle: "Изменять имя файла при загрузке", target: nil, action: nil)
    let showDockIconCheckbox = NSButton(checkboxWithTitle: "Показывать иконку приложения в доке", target: nil, action: nil)
    let limitFileSizeCheckbox = NSButton(checkboxWithTitle: "Ограничить максимальный размер файла", target: nil, action: nil)
    let maxFileSizeTextField = NSTextField()
    let maxFileSizeLabel = NSTextField(labelWithString: "Mb")

    // MARK: - UI Elements (Clipboard Upload Settings)
    let clipboardFormatLabel = NSTextField(labelWithString: "Формат загрузки из буфера:")
    let clipboardFormatControl = NSSegmentedControl(labels: ["PNG", "JPG"], trackingMode: .selectOne, target: nil, action: nil)
    let jpgQualityLabel = NSTextField(labelWithString: "Качество JPG (10-100):")
    let jpgQualitySlider = NSSlider(value: 80, minValue: 10, maxValue: 100, target: nil, action: nil)
    let jpgQualityValueLabel = NSTextField(labelWithString: "80")

    // MARK: - UI Elements (Hotkey Settings)
    var hotkeyRecorderView: HotkeyRecorderView!
    let clearHotkeyButton = NSButton(title: "Очистить", target: nil, action: nil)
    let copyBeforeUploadCheckbox = NSButton(checkboxWithTitle: "Копировать в буфер перед загрузкой", target: nil, action: nil)
    let copyOnlyFromMonosnapCheckbox = NSButton(checkboxWithTitle: "Копировать в буфер перед загрузкой только из Monosnap", target: nil, action: nil)
    let uploadCopiedFilesCheckbox = NSButton(checkboxWithTitle: "Загружать скопированные файлы", target: nil, action: nil)

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
        // Логика сохранения перенесена в SettingsWindowController
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

        let bufferAndHotkeysTabItem = NSTabViewItem(identifier: "BufferAndHotkeys")
        bufferAndHotkeysTabItem.label = "Буфер и Хоткеи"
        let bufferAndHotkeysView = NSView()
        bufferAndHotkeysTabItem.view = bufferAndHotkeysView
        tabView.addTabViewItem(bufferAndHotkeysTabItem)

        // Constraints for TabView
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20) // Занимает все доступное пространство
        ])

        setupGeneralTab(in: generalView)
        setupSFTPTab(in: sftpView)
        setupBufferAndHotkeysTab(in: bufferAndHotkeysView)

        // Save Button Action (удалено)
        // saveButton.target = self
        // saveButton.action = #selector(saveSettingsClicked)
    }

    private func setupGeneralTab(in view: NSView) {
        view.addSubview(folderSectionHeader)
        view.addSubview(folderPathTextField)
        view.addSubview(selectFolderButton)
        view.addSubview(behaviorSectionHeader)
        view.addSubview(showNotificationsCheckbox)
        view.addSubview(enableSoundCheckbox)
        view.addSubview(startMonitoringOnLaunchCheckbox)
        view.addSubview(launchAtSystemStartupCheckbox)
        view.addSubview(renameFileOnUploadCheckbox)
        view.addSubview(showDockIconCheckbox)
        view.addSubview(limitFileSizeCheckbox)
        view.addSubview(maxFileSizeTextField)
        view.addSubview(maxFileSizeLabel)

        folderSectionHeader.translatesAutoresizingMaskIntoConstraints = false
        folderPathTextField.translatesAutoresizingMaskIntoConstraints = false
        selectFolderButton.translatesAutoresizingMaskIntoConstraints = false
        behaviorSectionHeader.translatesAutoresizingMaskIntoConstraints = false
        showNotificationsCheckbox.translatesAutoresizingMaskIntoConstraints = false
        enableSoundCheckbox.translatesAutoresizingMaskIntoConstraints = false
        startMonitoringOnLaunchCheckbox.translatesAutoresizingMaskIntoConstraints = false
        launchAtSystemStartupCheckbox.translatesAutoresizingMaskIntoConstraints = false
        renameFileOnUploadCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showDockIconCheckbox.translatesAutoresizingMaskIntoConstraints = false
        limitFileSizeCheckbox.translatesAutoresizingMaskIntoConstraints = false
        maxFileSizeTextField.translatesAutoresizingMaskIntoConstraints = false
        maxFileSizeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Text Field Settings
        folderPathTextField.placeholderString = "Путь к папке для отслеживания"
        folderPathTextField.isEditable = false
        folderPathTextField.maximumNumberOfLines = 1
        folderPathTextField.lineBreakMode = .byTruncatingMiddle

        // Section Headers Font Settings - Bold
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        folderSectionHeader.font = boldFont
        behaviorSectionHeader.font = boldFont
        
        // Button Settings
        selectFolderButton.target = self
        selectFolderButton.action = #selector(selectFolderClicked)
        
        // Checkbox Settings
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
        limitFileSizeCheckbox.target = self
        limitFileSizeCheckbox.action = #selector(limitFileSizeChanged) // Добавляем обработчик для чекбокса лимита
        copyBeforeUploadCheckbox.target = self
        copyBeforeUploadCheckbox.action = #selector(copyBeforeUploadChanged)
        copyOnlyFromMonosnapCheckbox.target = self
        copyOnlyFromMonosnapCheckbox.action = #selector(copyOnlyFromMonosnapChanged)
        uploadCopiedFilesCheckbox.target = self
        uploadCopiedFilesCheckbox.action = #selector(uploadCopiedFilesChanged)

        // Clipboard Format Settings
        clipboardFormatControl.target = self
        clipboardFormatControl.action = #selector(clipboardFormatChanged)
        jpgQualitySlider.target = self
        jpgQualitySlider.action = #selector(jpgQualitySliderChanged)
        jpgQualitySlider.controlSize = .small
        jpgQualitySlider.numberOfTickMarks = 10
        jpgQualitySlider.allowsTickMarkValuesOnly = true

        clearHotkeyButton.translatesAutoresizingMaskIntoConstraints = false
        clearHotkeyButton.target = self
        clearHotkeyButton.action = #selector(clearHotkeyClicked)

        NSLayoutConstraint.activate([
            // Folder Section Header
            folderSectionHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            folderSectionHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Folder Path and Button
            folderPathTextField.topAnchor.constraint(equalTo: folderSectionHeader.bottomAnchor, constant: 10),
            folderPathTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            folderPathTextField.trailingAnchor.constraint(equalTo: selectFolderButton.leadingAnchor, constant: -10),
            folderPathTextField.heightAnchor.constraint(equalToConstant: 24),

            selectFolderButton.centerYAnchor.constraint(equalTo: folderPathTextField.centerYAnchor),
            selectFolderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectFolderButton.widthAnchor.constraint(equalToConstant: 120),

            // Behavior Section Header
            behaviorSectionHeader.topAnchor.constraint(equalTo: folderPathTextField.bottomAnchor, constant: 20),
            behaviorSectionHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Behavior Checkboxes
            showNotificationsCheckbox.topAnchor.constraint(equalTo: behaviorSectionHeader.bottomAnchor, constant: 10),
            showNotificationsCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            enableSoundCheckbox.topAnchor.constraint(equalTo: showNotificationsCheckbox.bottomAnchor, constant: 10),
            enableSoundCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            startMonitoringOnLaunchCheckbox.topAnchor.constraint(equalTo: enableSoundCheckbox.bottomAnchor, constant: 10),
            startMonitoringOnLaunchCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            launchAtSystemStartupCheckbox.topAnchor.constraint(equalTo: startMonitoringOnLaunchCheckbox.bottomAnchor, constant: 10),
            launchAtSystemStartupCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            renameFileOnUploadCheckbox.topAnchor.constraint(equalTo: launchAtSystemStartupCheckbox.bottomAnchor, constant: 10),
            renameFileOnUploadCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            showDockIconCheckbox.topAnchor.constraint(equalTo: renameFileOnUploadCheckbox.bottomAnchor, constant: 10),
            showDockIconCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // File Size Limit Section
            limitFileSizeCheckbox.topAnchor.constraint(equalTo: showDockIconCheckbox.bottomAnchor, constant: 15),
            limitFileSizeCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            maxFileSizeTextField.centerYAnchor.constraint(equalTo: limitFileSizeCheckbox.centerYAnchor),
            maxFileSizeTextField.leadingAnchor.constraint(equalTo: limitFileSizeCheckbox.trailingAnchor, constant: 10),
            maxFileSizeTextField.widthAnchor.constraint(equalToConstant: 80),
            maxFileSizeTextField.heightAnchor.constraint(equalToConstant: 20),

            maxFileSizeLabel.centerYAnchor.constraint(equalTo: limitFileSizeCheckbox.centerYAnchor),
            maxFileSizeLabel.leadingAnchor.constraint(equalTo: maxFileSizeTextField.trailingAnchor, constant: 5),
        ])
    }

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 380)) // Размер окна настроек
    }

    // MARK: - Helper Methods
    private func formatFolderPath(_ path: String) -> String {
        let maxLength = 50 // Максимальная длина отображаемого пути

        guard path.count > maxLength else {
            return path // Если путь короткий, возвращаем как есть
        }

        // Разделяем путь на компоненты
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }

        guard components.count > 2 else {
            // Если мало компонентов, просто обрезаем с конца
            let startIndex = path.startIndex
            let endIndex = path.index(startIndex, offsetBy: maxLength - 3)
            return String(path[startIndex..<endIndex]) + "..."
        }

        // Берем первый и последний компоненты
        let firstComponent = components.first!
        let lastComponent = components.last!

        // Вычисляем доступную длину для первого компонента
        let ellipsis = " ... "
        let availableLength = maxLength - (String(lastComponent).count + ellipsis.count)

        var result = "/" + firstComponent

        if availableLength > 0 {
            // Добавляем часть второго компонента, если есть место
            if components.count > 2 {
                let secondComponent = components[1]
                let remainingLength = availableLength - (result.count + 1) // +1 для следующего "/"

                if remainingLength > 0 {
                    let truncatedSecond = String(secondComponent).prefix(remainingLength)
                    result += "/" + truncatedSecond
                }
            }
        }

        // Добавляем многоточие и последний компонент
        result += ellipsis + "/" + lastComponent

        return result
    }

    private func setupSFTPTab(in view: NSView) {
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.alignment = .centerX // Центрируем элементы по горизонтали для центрирования кнопки
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

    private func setupBufferAndHotkeysTab(in view: NSView) {
        view.addSubview(imageSettingsHeader)
        view.addSubview(clipboardFormatLabel)
        view.addSubview(clipboardFormatControl)
        view.addSubview(jpgQualityLabel)
        view.addSubview(jpgQualitySlider)
        view.addSubview(jpgQualityValueLabel)
        view.addSubview(hotkeySectionHeader)
        view.addSubview(hotkeyDescriptionLabel)
        view.addSubview(copyBeforeUploadCheckbox)
        view.addSubview(copyOnlyFromMonosnapCheckbox)
        view.addSubview(uploadCopiedFilesCheckbox)

        // Hotkey Recorder
        hotkeyRecorderView = HotkeyRecorderView()
        hotkeyRecorderView.translatesAutoresizingMaskIntoConstraints = false
        hotkeyRecorderView.delegate = self
        view.addSubview(hotkeyRecorderView)

        view.addSubview(clearHotkeyButton)

        imageSettingsHeader.translatesAutoresizingMaskIntoConstraints = false
        clipboardFormatLabel.translatesAutoresizingMaskIntoConstraints = false
        clipboardFormatControl.translatesAutoresizingMaskIntoConstraints = false
        jpgQualityLabel.translatesAutoresizingMaskIntoConstraints = false
        jpgQualitySlider.translatesAutoresizingMaskIntoConstraints = false
        jpgQualityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        hotkeySectionHeader.translatesAutoresizingMaskIntoConstraints = false
        hotkeyDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        copyBeforeUploadCheckbox.translatesAutoresizingMaskIntoConstraints = false
        copyOnlyFromMonosnapCheckbox.translatesAutoresizingMaskIntoConstraints = false
        uploadCopiedFilesCheckbox.translatesAutoresizingMaskIntoConstraints = false

        // Section Headers Font Settings - Bold
        let boldFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        imageSettingsHeader.font = boldFont
        hotkeySectionHeader.font = boldFont

        // Clipboard Format Settings
        clipboardFormatControl.target = self
        clipboardFormatControl.action = #selector(clipboardFormatChanged)
        jpgQualitySlider.target = self
        jpgQualitySlider.action = #selector(jpgQualitySliderChanged)
        jpgQualitySlider.controlSize = .small
        jpgQualitySlider.numberOfTickMarks = 10
        jpgQualitySlider.allowsTickMarkValuesOnly = true

        clearHotkeyButton.translatesAutoresizingMaskIntoConstraints = false
        clearHotkeyButton.target = self
        clearHotkeyButton.action = #selector(clearHotkeyClicked)

        NSLayoutConstraint.activate([
            // Image Settings Header
            imageSettingsHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageSettingsHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Clipboard Format
            clipboardFormatLabel.topAnchor.constraint(equalTo: imageSettingsHeader.bottomAnchor, constant: 10),
            clipboardFormatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clipboardFormatControl.centerYAnchor.constraint(equalTo: clipboardFormatLabel.centerYAnchor),
            clipboardFormatControl.leadingAnchor.constraint(equalTo: clipboardFormatLabel.trailingAnchor, constant: 10),

            // JPG Quality
            jpgQualityLabel.topAnchor.constraint(equalTo: clipboardFormatLabel.bottomAnchor, constant: 10),
            jpgQualityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            jpgQualitySlider.centerYAnchor.constraint(equalTo: jpgQualityLabel.centerYAnchor),
            jpgQualitySlider.leadingAnchor.constraint(equalTo: jpgQualityLabel.trailingAnchor, constant: 10),
            jpgQualitySlider.widthAnchor.constraint(equalToConstant: 150),
            jpgQualityValueLabel.centerYAnchor.constraint(equalTo: jpgQualityLabel.centerYAnchor),
            jpgQualityValueLabel.leadingAnchor.constraint(equalTo: jpgQualitySlider.trailingAnchor, constant: 10),

            // Hotkey Section Header
            hotkeySectionHeader.topAnchor.constraint(equalTo: jpgQualityLabel.bottomAnchor, constant: 20),
            hotkeySectionHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Hotkey Description
            hotkeyDescriptionLabel.topAnchor.constraint(equalTo: hotkeySectionHeader.bottomAnchor, constant: 8),
            hotkeyDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Hotkey Recorder (теперь выше чекбоксов)
            hotkeyRecorderView.topAnchor.constraint(equalTo: hotkeyDescriptionLabel.bottomAnchor, constant: 8),
            hotkeyRecorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hotkeyRecorderView.widthAnchor.constraint(equalToConstant: 150),
            hotkeyRecorderView.heightAnchor.constraint(equalToConstant: 24),

            clearHotkeyButton.centerYAnchor.constraint(equalTo: hotkeyRecorderView.centerYAnchor),
            clearHotkeyButton.leadingAnchor.constraint(equalTo: hotkeyRecorderView.trailingAnchor, constant: 10),

            // Copy Before Upload Checkbox
            copyBeforeUploadCheckbox.topAnchor.constraint(equalTo: hotkeyRecorderView.bottomAnchor, constant: 15),
            copyBeforeUploadCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Copy Only From Monosnap Checkbox (с отступом для визуальной иерархии)
            copyOnlyFromMonosnapCheckbox.topAnchor.constraint(equalTo: copyBeforeUploadCheckbox.bottomAnchor, constant: 8),
            copyOnlyFromMonosnapCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),

            // Upload Copied Files Checkbox
            uploadCopiedFilesCheckbox.topAnchor.constraint(equalTo: copyOnlyFromMonosnapCheckbox.bottomAnchor, constant: 8),
            uploadCopiedFilesCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        // General Settings
        let folderPath = defaults.string(forKey: "folderPath") ?? FolderMonitor.shared.folderPath
        folderPathTextField.stringValue = formatFolderPath(folderPath)
        showNotificationsCheckbox.state = defaults.bool(forKey: "showNotifications") ? .on : .off
        enableSoundCheckbox.state = defaults.bool(forKey: "enableSound") ? .on : .off
        startMonitoringOnLaunchCheckbox.state = defaults.bool(forKey: "startMonitoringOnLaunch") ? .on : .off
        launchAtSystemStartupCheckbox.state = defaults.bool(forKey: "launchAtSystemStartup") ? .on : .off // Читаем из UserDefaults
        renameFileOnUploadCheckbox.state = defaults.bool(forKey: "renameFileOnUpload") ? .on : .off
        showDockIconCheckbox.state = defaults.bool(forKey: "showDockIcon") ? .on : .off
        limitFileSizeCheckbox.state = defaults.bool(forKey: "isMaxFileSizeLimitEnabled") ? .on : .off

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

        // Load Copy Before Upload Setting
        copyBeforeUploadCheckbox.state = defaults.bool(forKey: "copyBeforeUpload") ? .on : .off

        // Load Copy Only From Monosnap Setting
        copyOnlyFromMonosnapCheckbox.state = defaults.bool(forKey: "copyOnlyFromMonosnap") ? .on : .off

        // Load Upload Copied Files Setting
        uploadCopiedFilesCheckbox.state = defaults.bool(forKey: "uploadCopiedFiles") ? .on : .off

        // Load Max File Size Limit Setting
        let savedMaxFileSize = defaults.integer(forKey: "maxFileSizeLimit")
        maxFileSizeTextField.stringValue = savedMaxFileSize == 0 ? "200" : "\(savedMaxFileSize)"
        updateFileSizeLimitUIState() // Обновляем состояние UI для лимита размера файла
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        
        // General Settings
        defaults.set(folderPathTextField.stringValue, forKey: "folderPath")
        defaults.set(showNotificationsCheckbox.state == .on, forKey: "showNotifications")
        defaults.set(enableSoundCheckbox.state == .on, forKey: "enableSound")
        defaults.set(startMonitoringOnLaunchCheckbox.state == .on, forKey: "startMonitoringOnLaunch")
        defaults.set(launchAtSystemStartupCheckbox.state == .on, forKey: "launchAtSystemStartup") // Сохраняем состояние чекбокса автозапуска
        defaults.set(renameFileOnUploadCheckbox.state == .on, forKey: "renameFileOnUpload")
        defaults.set(showDockIconCheckbox.state == .on, forKey: "showDockIcon")
        defaults.set(limitFileSizeCheckbox.state == .on, forKey: "isMaxFileSizeLimitEnabled") // Сохраняем состояние чекбокса лимита размера файла

        // Clipboard Upload Settings
        let selectedFormat = (clipboardFormatControl.selectedSegment == 0) ? "png" : "jpg"
        defaults.set(selectedFormat, forKey: "clipboardUploadFormat")
        defaults.set(Int(jpgQualitySlider.doubleValue), forKey: "clipboardJpgQuality")
        
        // SFTP Settings
        defaults.set(sftpHostTextField.stringValue, forKey: "sftpHost")
        defaults.set(sftpPortTextField.stringValue, forKey: "sftpPort")
        defaults.set(sftpUserTextField.stringValue, forKey: "sftpUser")
        defaults.set(sftpPasswordSecureTextField.stringValue, forKey: "sftpPassword")
        defaults.set(sftpFolderTextField.stringValue, forKey: "sftpFolder")
        defaults.set(sftpBaseUrlTextField.stringValue, forKey: "sftpBaseUrl")

        // Hotkey Settings
        defaults.set(copyBeforeUploadCheckbox.state == .on, forKey: "copyBeforeUpload")
        defaults.set(copyOnlyFromMonosnapCheckbox.state == .on, forKey: "copyOnlyFromMonosnap")
        defaults.set(uploadCopiedFilesCheckbox.state == .on, forKey: "uploadCopiedFiles")

        // File Size Limit Settings
        let maxFileSizeValue = Int(maxFileSizeTextField.stringValue) ?? 200
        defaults.set(maxFileSizeValue, forKey: "maxFileSizeLimit")
        
        // Update LaunchAtLoginManager
        LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: launchAtSystemStartupCheckbox.state == .on)
        
        // Update FolderMonitor
        FolderMonitor.shared.folderPath = folderPathTextField.stringValue
        
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
                    let formattedPath = self?.formatFolderPath(url.path) ?? url.path
                    self?.folderPathTextField.stringValue = formattedPath
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

    @objc private func limitFileSizeChanged() {
        saveSettings()
        updateFileSizeLimitUIState()
        print("Ограничить максимальный размер файла: \(limitFileSizeCheckbox.state == .on)")
    }

    @objc private func copyBeforeUploadChanged() {
        saveSettings()
        updateMonosnapCheckboxState()
        print("Копировать перед загрузкой: \(copyBeforeUploadCheckbox.state == .on)")
    }

    @objc private func copyOnlyFromMonosnapChanged() {
        saveSettings()
        print("Копировать в буфер только из Monosnap: \(copyOnlyFromMonosnapCheckbox.state == .on)")
    }

    @objc private func uploadCopiedFilesChanged() {
        saveSettings()
        print("Загружать скопированные файлы: \(uploadCopiedFilesCheckbox.state == .on)")
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

    private func updateMonosnapCheckboxState() {
        let isCopyBeforeUploadEnabled = copyBeforeUploadCheckbox.state == .on

        // Если главный чекбокс выключен, то дочерний тоже выключаем и делаем неактивным
        if !isCopyBeforeUploadEnabled {
            copyOnlyFromMonosnapCheckbox.state = .off
            copyOnlyFromMonosnapCheckbox.isEnabled = false
        } else {
            // Если главный чекбокс включен, то дочерний становится активным
            copyOnlyFromMonosnapCheckbox.isEnabled = true
        }

        print("Состояние чекбоксов обновлено: главный=\(isCopyBeforeUploadEnabled), дочерний активен=\(copyOnlyFromMonosnapCheckbox.isEnabled)")
    }

    private func updateFileSizeLimitUIState() {
        let isLimitEnabled = limitFileSizeCheckbox.state == .on
        maxFileSizeTextField.isEnabled = isLimitEnabled
        maxFileSizeLabel.isEnabled = isLimitEnabled
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

        if let textField = obj.object as? NSTextField, textField == maxFileSizeTextField {
            // Удаляем все символы, кроме цифр
            let filteredText = textField.stringValue.filter { $0.isNumber }
            if filteredText != textField.stringValue {
                textField.stringValue = filteredText
            }

            // Проверяем значение и корректируем, если оно выходит за пределы
            if let value = Int(filteredText), value > 1048576 {
                textField.stringValue = "1048576" // Максимум 1 Тб
            } else if let value = Int(filteredText), value < 0 {
                textField.stringValue = "200" // Минимум 200 Мб
            }
        }
    }
}
