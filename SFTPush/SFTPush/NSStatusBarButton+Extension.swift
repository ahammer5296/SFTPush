//
//  NSStatusBarButton+Extension.swift
//  TestUploader
//
//  Created by Alex Masibut on 25.09.2025.
//

import Cocoa
import ObjectiveC

// MARK: - Associated Keys
private var animationTimerKey: Void?
private var animationImagesKey: Void?
private var currentFrameIndexKey: Void?

extension NSStatusBarButton {

    // MARK: - Associated Properties for Animation
    private var animationTimer: Timer? {
        get {
            return objc_getAssociatedObject(self, &animationTimerKey) as? Timer
        }
        set {
            objc_setAssociatedObject(self, &animationTimerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var animationImages: [NSImage] {
        get {
            return (objc_getAssociatedObject(self, &animationImagesKey) as? [NSImage]) ?? []
        }
        set {
            objc_setAssociatedObject(self, &animationImagesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var currentFrameIndex: Int {
        get {
            return (objc_getAssociatedObject(self, &currentFrameIndexKey) as? Int) ?? 0
        }
        set {
            objc_setAssociatedObject(self, &currentFrameIndexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Animation Methods
    func startAnimating(images: [NSImage], duration: TimeInterval) {
        stopAnimating() // Останавливаем предыдущую анимацию, если есть
        self.animationImages = images
        self.currentFrameIndex = 0
        self.image = animationImages.first // Устанавливаем первый кадр

        animationTimer = Timer.scheduledTimer(withTimeInterval: duration / Double(images.count), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentFrameIndex = (self.currentFrameIndex + 1) % self.animationImages.count
            self.image = self.animationImages[self.currentFrameIndex]
        }
        RunLoop.current.add(animationTimer!, forMode: .common)
    }

    func stopAnimating() {
        animationTimer?.invalidate()
        animationTimer = nil
        animationImages = []
        currentFrameIndex = 0
        // Возвращаем исходное изображение, если оно было установлено в AppDelegate
    }

    // MARK: - NSDraggingDestination
    
    // Эти методы должны быть реализованы в AppDelegate, так как NSStatusBarButton не является NSView
    // и не может напрямую переопределять draggingEntered и т.д.
    // Вместо этого, мы будем использовать делегат или NotificationCenter для обработки Drag & Drop.
    // Для простоты, пока оставим их здесь, но в реальном приложении это потребует переработки.
    
    override open func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: nil) {
            // Подсвечиваем кнопку при входе drag операции
            self.layer?.backgroundColor = NSColor.selectedControlColor.withAlphaComponent(0.3).cgColor
            return .copy
        }
        return []
    }

    override open func draggingExited(_ sender: NSDraggingInfo?) {
        // Убираем подсветку при выходе drag операции
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }

    override open func draggingEnded(_ sender: NSDraggingInfo) {
        // Убираем подсветку при завершении drag операции
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }

    override open func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // Убираем подсветку
        self.layer?.backgroundColor = NSColor.clear.cgColor

        let pasteboard = sender.draggingPasteboard
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
              let appDelegate = NSApp.delegate as? AppDelegate else {
            return false
        }

        // Вызываем централизованный обработчик в AppDelegate
        appDelegate.handleDroppedFiles(urls: urls)

        return true
    }
}
