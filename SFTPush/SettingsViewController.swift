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

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 400)) // Увеличиваем размер окна
    }

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

        // Constraints for TabView
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20) // Занимает все доступное пространство
        ])

        setupGeneralTab(in: generalView)
        setupSFTPTab(in: sftpView)

        // Save Button Action (удалено)
        // saveButton.target = self
        // saveButton.action = #selector(saveSettingsClicked)
    }

    private func setupGeneralTab(in view: NSView) {
        view.addSubview(folderPathTextField)
        view.addSubview(selectFolderButton)
        view.addSubview(showNotificationsCheckbox)
        view.addSubview(enableSoundCheckbox)
        view.addSubview(startMonitoringOnLaunchCheckbox)
        view.addSubview(launchAtSystemStartupCheckbox)
        view.addSubview(renameFileOnUploadCheckbox)
        view.addSubview(showDockIconCheckbox)

        folderPathTextField.translatesAutoresizingMaskIntoConstraints = false
        selectFolderButton.translatesAutoresizingMaskIntoConstraints = false
        showNotificationsCheckbox.translatesAutoresizingMaskIntoConstraints = false
        enableSoundCheckbox.translatesAutoresizingMaskIntoConstraints = false
        startMonitoringOnLaunchCheckbox.translatesAutoresizingMaskIntoConstraints = false
        launchAtSystemStartupCheckbox.translatesAutoresizingMaskIntoConstraints = false
        renameFileOnUploadCheckbox.translatesAutoresizingMaskIntoConstraints = false
        showDockIconCheckbox.translatesAutoresizingMaskIntoConstraints = false

        // Text Field Settings
        folderPathTextField.placeholderString = "Путь к папке для отслеживания"
        folderPathTextField.isEditable = false
        
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

        NSLayoutConstraint.activate([
            folderPathTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            folderPathTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            folderPathTextField.trailingAnchor.constraint(equalTo: selectFolderButton.leadingAnchor, constant: -10),
            folderPathTextField.heightAnchor.constraint(equalToConstant: 24),

            selectFolderButton.centerYAnchor.constraint(equalTo: folderPathTextField.centerYAnchor),
            selectFolderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectFolderButton.widthAnchor.constraint(equalToConstant: 120),

            showNotificationsCheckbox.topAnchor.constraint(equalTo: folderPathTextField.bottomAnchor, constant: 20),
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
            showDockIconCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }

    private func setupSFTPTab(in view: NSView) {
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.alignment = .centerX // Центрируем элементы по горизонтали
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
        
        // SFTP Settings
        defaults.set(sftpHostTextField.stringValue, forKey: "sftpHost")
        defaults.set(sftpPortTextField.stringValue, forKey: "sftpPort")
        defaults.set(sftpUserTextField.stringValue, forKey: "sftpUser")
        defaults.set(sftpPasswordSecureTextField.stringValue, forKey: "sftpPassword")
        defaults.set(sftpFolderTextField.stringValue, forKey: "sftpFolder")
        defaults.set(sftpBaseUrlTextField.stringValue, forKey: "sftpBaseUrl")
        
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
                    self?.folderPathTextField.stringValue = url.path
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
