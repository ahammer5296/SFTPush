//
//  FolderMonitor.swift
//  TestUploader
//
//  Created by Alex Masibut on 24.09.2025.
//

import Foundation
import AppKit // Добавлено для NSPasteboard
import mft // Импортируем mft

class FolderMonitor: NSObject {
    
    static let shared = FolderMonitor() // Singleton для удобства доступа
    
    var folderPath: String = "" { // Убираем путь по умолчанию, теперь он будет запрашиваться
        didSet {
            // Если путь изменился, останавливаем, перенастраиваем папки и перезапускаем мониторинг
            if isMonitoring {
                stopMonitoring()
                if setupFolders() {
                    startMonitoring()
                }
            }
        }
    }
    var isMonitoring: Bool = false {
        didSet {
            // Уведомляем AppDelegate об изменении статуса
            NotificationCenter.default.post(name: .folderMonitoringStatusChanged, object: nil)
        }
    }
    
    private var fileDescriptor: CInt = -1
    private var dispatchSource: DispatchSourceFileSystemObject?
    private let monitorQueue = DispatchQueue(label: "com.testuploader.foldermonitor")

    // MARK: - Batch Upload Properties
    private var batchUploadTotalCount: Int = 0
    private var batchUploadSuccessCount: Int = 0
    private var batchUploadErrorCount: Int = 0
    private var isBatchInProgress: Bool {
        return batchUploadTotalCount > 0
    }
    
    // mft не использует EventLoopGroup напрямую, поэтому закомментируем
    // private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    private override init() {
        super.init()
    }
    
    deinit {
        stopMonitoring()
        // try? eventLoopGroup.syncShutdownGracefully() // Закомментировано
    }
    
    // MARK: - Public Methods
    
    func setupFolders() -> Bool {
        let fileManager = FileManager.default
        let mainFolderURL = URL(fileURLWithPath: folderPath)
        
        // Проверяем существование основной папки
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: mainFolderURL.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            // Папка не существует, запрашиваем у пользователя
            // Временно, пока нет окна настроек, просто выводим сообщение
            print("Основная папка для отслеживания не найдена: \(folderPath). Пожалуйста, укажите ее в настройках.")
            // Отправляем уведомление, чтобы AppDelegate мог запросить у пользователя папку
            NotificationCenter.default.post(name: .requestFolderPath, object: nil)
            return false
        }
        
        // Проверяем и создаем подпапки Error и Uploaded
        let errorFolderURL = mainFolderURL.appendingPathComponent("Error")
        let uploadedFolderURL = mainFolderURL.appendingPathComponent("Uploaded")
        
        do {
            if !fileManager.fileExists(atPath: errorFolderURL.path) {
                try fileManager.createDirectory(at: errorFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            if !fileManager.fileExists(atPath: uploadedFolderURL.path) {
                try fileManager.createDirectory(at: uploadedFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Ошибка при создании подпапок: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        let fileManager = FileManager.default
        let mainFolderURL = URL(fileURLWithPath: folderPath)
        
        guard fileManager.fileExists(atPath: mainFolderURL.path) else {
            print("Невозможно начать отслеживание: папка не существует.")
            isMonitoring = false
            return
        }
        
        fileDescriptor = open(folderPath, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            print("Не удалось открыть файловый дескриптор для папки: \(folderPath)")
            isMonitoring = false
            return
        }
        
        dispatchSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename, .link, .revoke],
            queue: monitorQueue
        )
        
        dispatchSource?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            let event = self.dispatchSource?.data
            if event?.contains(.write) == true {
                print("Обнаружено изменение в папке: \(self.folderPath)")
                self.processFolderContents()
            }
        }
        
        dispatchSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            close(self.fileDescriptor)
            self.fileDescriptor = -1
            print("Мониторинг папки остановлен и файловый дескриптор закрыт.")
        }
        
        dispatchSource?.resume()
        isMonitoring = true
        print("Начато отслеживание папки: \(self.folderPath)")
        
        // Проверяем содержимое папки сразу после запуска
        self.processFolderContents()
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        dispatchSource?.cancel()
        dispatchSource = nil
        isMonitoring = false
        print("Отслеживание папки остановлено.")
    }
    
    private func processFolderContents() {
        let fileManager = FileManager.default
        let mainFolderURL = URL(fileURLWithPath: folderPath)

        do {
            let contents = try fileManager.contentsOfDirectory(at: mainFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let filesToUpload = contents.filter { itemURL in
                if itemURL.lastPathComponent == "Error" || itemURL.lastPathComponent == "Uploaded" {
                    return false
                }
                var isDirectory: ObjCBool = false
                return fileManager.fileExists(atPath: itemURL.path, isDirectory: &isDirectory) && !isDirectory.boolValue
            }

            guard !filesToUpload.isEmpty else { return }

            // Запускаем новую массовую загрузку из папки
            startBatchUpload(urls: filesToUpload, isMonitored: true)

        } catch {
            print("Ошибка при чтении содержимого папки: \(error.localizedDescription)")
        }
    }
    
    func uploadFile(atPath localFilePath: String) {
        // Этот метод теперь для одиночных файлов из мониторинга
        uploadSingleFile(atPath: localFilePath, isMonitored: true)
    }

    // Новый публичный метод для запуска загрузки из AppDelegate
    func startBatchUpload(urls: [URL], isMonitored: Bool, deleteAfterUpload: Bool = false) {
        DispatchQueue.main.async {
            if urls.count > 1 {
                self.batchUploadTotalCount = urls.count
                self.batchUploadSuccessCount = 0
                self.batchUploadErrorCount = 0
                // Уведомление о начале массовой загрузки
                NotificationCenter.default.post(name: .batchUploadStarted, object: nil, userInfo: ["count": urls.count])
            }

            for url in urls {
                self.uploadSingleFile(atPath: url.path, isMonitored: isMonitored, deleteAfterUpload: deleteAfterUpload)
            }
        }
    }

    // Метод для загрузки одного файла (используется для Drag & Drop и мониторинга папки)
    func uploadSingleFile(atPath localFilePath: String, isMonitored: Bool, deleteAfterUpload: Bool = false) {
        // Проверяем размер файла перед загрузкой
        if !checkFileSizeLimit(filePath: localFilePath, isMonitored: isMonitored) {
            return // Если файл превышает лимит, прекращаем обработку
        }

        let defaults = UserDefaults.standard
        let renameFileOnUpload = defaults.bool(forKey: "renameFileOnUpload")
        let sftpHost = defaults.string(forKey: "sftpHost") ?? ""
        let sftpPort = Int(defaults.string(forKey: "sftpPort") ?? "22") ?? 22
        let sftpUser = defaults.string(forKey: "sftpUser") ?? ""
        let sftpPassword = defaults.string(forKey: "sftpPassword") ?? ""
        let sftpRemoteFolder = defaults.string(forKey: "sftpFolder") ?? "/"
        let sftpBaseUrl = defaults.string(forKey: "sftpBaseUrl") ?? ""

        guard !sftpHost.isEmpty, !sftpUser.isEmpty, !sftpPassword.isEmpty else {
            let fileName = URL(fileURLWithPath: localFilePath).lastPathComponent
            let errorMsg = "Проверьте, что SFTP-настройки заполнены и закройте окно настроек для их применения."
            print("Ошибка SFTP для файла \(fileName): \(errorMsg)")
            if isMonitored {
                moveFile(localFilePath: localFilePath, toFolder: "Error")
            }
            NotificationCenter.default.post(name: .uploadFailure, object: nil, userInfo: ["fileName": fileName, "error": errorMsg])
            return
        }

        let localFileURL = URL(fileURLWithPath: localFilePath)
        let originalFileName = localFileURL.lastPathComponent
        let fileName = renameFileOnUpload ? generateRandomFileName(for: originalFileName) : originalFileName
        let remoteFilePath = "\(sftpRemoteFolder)/\(fileName)"
        
        print("Попытка загрузки файла \(originalFileName) как \(fileName) на SFTP...")
        NotificationCenter.default.post(name: .uploadStarted, object: nil) // Уведомление о начале загрузки

        // Выполняем SFTP-операции в фоновом потоке
        monitorQueue.async { [weak self] in
            guard let self = self else { return }
            
            let sftpConnection = MFTSftpConnection(hostname: sftpHost, port: sftpPort, username: sftpUser, password: sftpPassword)
            
            do {
                // Подключение и аутентификация
                try sftpConnection.connect()
                try sftpConnection.authenticate()
                
                // Загрузка файла
                guard let inStream = InputStream(fileAtPath: localFilePath) else {
                    throw NSError(domain: "FolderMonitor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать InputStream для файла: \(fileName)"])
                }
                
                try sftpConnection.write(stream: inStream, toFileAtPath: remoteFilePath, append: false) { uploadedBytes in
                    return true // Продолжать загрузку
                }
                
                // Успешная загрузка
                print("Файл \(fileName) успешно загружен.")
                if isMonitored {
                    self.moveFile(localFilePath: localFilePath, toFolder: "Uploaded")
                }
                let publicURL = "\(sftpBaseUrl)\(fileName)"
                self.copyToPasteboard(text: publicURL)
                // Уведомляем об успехе
                self.handleUploadResult(isSuccess: true, fileName: fileName, url: publicURL, error: nil, isMonitored: isMonitored, deleteAfterUpload: deleteAfterUpload)
                
            } catch {
                // Обработка ошибок
                print("Ошибка SFTP для файла \(fileName): \(error.localizedDescription)")
                // Уведомляем об ошибке
                self.handleUploadResult(isSuccess: false, fileName: fileName, url: nil, error: error.localizedDescription, isMonitored: isMonitored, deleteAfterUpload: deleteAfterUpload)
            }
            // Отключение
            sftpConnection.disconnect()
            // Уведомление о завершении ОДНОЙ операции
            NotificationCenter.default.post(name: .uploadFinished, object: nil)
        }
    }
    
    private func moveFile(localFilePath: String, toFolder folderName: String) {
        let fileManager = FileManager.default
        let originalURL = URL(fileURLWithPath: localFilePath)
        let destinationFolderURL = URL(fileURLWithPath: folderPath).appendingPathComponent(folderName)
        let destinationURL = destinationFolderURL.appendingPathComponent(originalURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: originalURL, to: destinationURL)
            print("Файл \(originalURL.lastPathComponent) перемещен в \(folderName).")
        } catch {
            print("Ошибка при перемещении файла \(originalURL.lastPathComponent) в \(folderName): \(error.localizedDescription)")
        }
    }
    
    private func copyToPasteboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        print("URL скопирован в буфер обмена: \(text)")
    }

    private func generateRandomFileName(for originalFileName: String) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomName = String((0..<15).map{ _ in characters.randomElement()! })
        let fileExtension = URL(fileURLWithPath: originalFileName).pathExtension
        return fileExtension.isEmpty ? randomName : "\(randomName).\(fileExtension)"
    }

    // MARK: - File Size Validation
    private func checkFileSizeLimit(filePath: String, isMonitored: Bool) -> Bool {
        let defaults = UserDefaults.standard
        let isMaxFileSizeLimitEnabled = defaults.bool(forKey: "isMaxFileSizeLimitEnabled")
        let maxFileSizeLimit = defaults.integer(forKey: "maxFileSizeLimit")

        // Если ограничение размера файла не включено или лимит равен 0, всегда возвращаем true
        guard isMaxFileSizeLimitEnabled && maxFileSizeLimit > 0 else {
            return true
        }

        let maxFileSizeBytes = maxFileSizeLimit * 1024 * 1024 // Конвертируем Мб в байты

        do {
            let fileManager = FileManager.default
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            let fileSize = attributes[.size] as? Int64 ?? 0

            if fileSize > maxFileSizeBytes {
                let fileName = URL(fileURLWithPath: filePath).lastPathComponent
                let fileSizeMB = Double(fileSize) / (1024 * 1024)

                print("Файл \(fileName) (\(String(format: "%.1f", fileSizeMB)) Мб) превышает лимит в \(maxFileSizeLimit) Мб")

                // Отправляем уведомление об ошибке
                let errorMsg = "Файл (\(String(format: "%.1f", fileSizeMB)) Мб) превышает установленный лимит в \(maxFileSizeLimit) Мб."
                NotificationCenter.default.post(name: .uploadFailure, object: nil, userInfo: ["fileName": fileName, "error": errorMsg])

                // Перемещаем файл в папку Error, только если он из отслеживаемой папки
                if isMonitored {
                    let fileManager = FileManager.default
                    let originalURL = URL(fileURLWithPath: filePath)
                    let destinationFolderURL = URL(fileURLWithPath: folderPath).appendingPathComponent("Error")
                    let destinationURL = destinationFolderURL.appendingPathComponent(originalURL.lastPathComponent)

                    do {
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            try fileManager.removeItem(at: destinationURL)
                        }
                        try fileManager.moveItem(at: originalURL, to: destinationURL)
                        print("Файл \(fileName) перемещен в папку Error из-за превышения лимита размера.")
                    } catch {
                        print("Ошибка при перемещении файла \(fileName) в папку Error: \(error.localizedDescription)")
                    }
                }

                return false
            }

            return true
        } catch {
            print("Ошибка при получении размера файла \(filePath): \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - SFTP Connection Test
    func testSFTPConnection(host: String, port: Int, user: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        monitorQueue.async {
            let sftpConnection = MFTSftpConnection(hostname: host, port: port, username: user, password: password)
            do {
                try sftpConnection.connect()
                try sftpConnection.authenticate()
                sftpConnection.disconnect()
                DispatchQueue.main.async {
                    completion(.success("Соединение успешно установлено!"))
                }
            } catch {
                sftpConnection.disconnect()
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
    static let folderMonitoringStatusChanged = Notification.Name("folderMonitoringStatusChanged")
    static let requestFolderPath = Notification.Name("requestFolderPath")
    static let uploadSuccess = Notification.Name("uploadSuccess")
    static let uploadFailure = Notification.Name("uploadFailure")
    static let uploadStarted = Notification.Name("uploadStarted")
    static let uploadFinished = Notification.Name("uploadFinished")
    static let batchUploadStarted = Notification.Name("batchUploadStarted") // Новое
    static let batchUploadFinished = Notification.Name("batchUploadFinished") // Новое
}

// MARK: - Batch Upload Helper
private extension FolderMonitor {
    func handleUploadResult(isSuccess: Bool, fileName: String, url: String?, error: String?, isMonitored: Bool, deleteAfterUpload: Bool) {
        DispatchQueue.main.async {
            let fileURL = URL(fileURLWithPath: fileName)
            if isSuccess {
                if isMonitored { // Перемещаем только если файл из отслеживаемой папки
                    self.moveFile(localFilePath: fileName, toFolder: "Uploaded")
                } else if deleteAfterUpload {
                    // Удаляем временный файл после успешной загрузки
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                        print("Временный файл \(fileURL.lastPathComponent) удален после успешной загрузки.")
                    } catch {
                        print("Ошибка при удалении временного файла \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
                if !self.isBatchInProgress {
                    NotificationCenter.default.post(name: .uploadSuccess, object: nil, userInfo: ["fileName": fileName, "url": url ?? ""])
                } else {
                    self.batchUploadSuccessCount += 1
                }
            } else {
                if isMonitored { // Перемещаем только если файл из отслеживаемой папки
                    self.moveFile(localFilePath: fileName, toFolder: "Error")
                } else if deleteAfterUpload {
                    // Удаляем временный файл после неудачной загрузки
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                        print("Временный файл \(fileURL.lastPathComponent) удален после неудачной загрузки.")
                    } catch {
                        print("Ошибка при удалении временного файла \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
                if !self.isBatchInProgress {
                    NotificationCenter.default.post(name: .uploadFailure, object: nil, userInfo: ["fileName": fileName, "error": error ?? "Unknown error"])
                } else {
                    self.batchUploadErrorCount += 1
                }
            }

            if self.isBatchInProgress {
                self.checkBatchCompletion()
            }
        }
    }

    func checkBatchCompletion() {
        let processedCount = batchUploadSuccessCount + batchUploadErrorCount
        if processedCount >= batchUploadTotalCount {
            let summary: [String: Any] = [
                "total": batchUploadTotalCount,
                "success": batchUploadSuccessCount,
                "error": batchUploadErrorCount
            ]
            NotificationCenter.default.post(name: .batchUploadFinished, object: nil, userInfo: summary)

            // Сбрасываем счетчики
            self.batchUploadTotalCount = 0
            self.batchUploadSuccessCount = 0
            self.batchUploadErrorCount = 0
        }
    }
}
