# SFTPush

Магистральное SFTP-приложение для macOS для автоматической загрузки файлов на сервер.

## Обзор

SFTPush - это удобное приложение для macOS, которое позволяет автоматически загружать файлы на SFTP-сервер при добавлении их в определенную папку. Поддерживает наблюдение за файлами, управление настройками и многоязычный интерфейс.

## Особенности

- 🔍 Автоматическое отслеживание папок
- �� Поддержка SFTP-протокола  
- 🖥️ Status bar приложение
- ⌨️ Глобальные горячие клавиши
- 🌍 Многоязычный интерфейс (RU/EN)
- 🚀 Автозапуск при входе в систему

## Требования

- macOS 11.5 или новее
- Xcode 13+

## Установка

1. Скачайте проект:
   ```bash
   git clone https://github.com/yourusername/SFTPush.git
   cd SFTPush
   ```

2. Откройте проект в Xcode:
   ```bash
   open SFTPush.xcodeproj
   ```

3. Соберите и запустите приложение (⌘+R)

## Структура проекта

```
SFTPush/
├── SFTPush/                    # Основное приложение
│   ├── AppDelegate.swift
│   ├── FolderMonitor.swift
│   ├── HotkeyManager.swift
│   └── ...
├── mft-main/                   # Библиотека MFT
│   ├── mft.xcodeproj
│   ├── mft/
│   │   ├── MFTSftpConnection.swift
│   │   └── MFTSftpItem.swift
│   ├── libssh/
│   └── openssl/
├── mft_macos_build/           # Сборочные артефакты
└── mft.framework/             # Фреймворк MFT
```

## Сборка

Для полной сборки проекта выполните:

```bash
# Сборка приложения
xcodebuild -project SFTPush.xcodeproj -scheme SFTPush -configuration Debug clean build
```

## Настройка

1. Запустите приложение
2. Щелкните правой кнопкой мыши на иконке в status bar
3. Выберите "Настройки" (Settings)
4. Введите ваши SFTP-сервер настройки:
   - Хост (Host)
   - Порт (Port)
   - Имя пользователя (Username) 
   - Пароль (Password)
   - Путь на сервере (Remote Path)

## Использование

1. Настройте отслеживаемую локальную папку
2. Перетащите файлы в отслеживаемую папку
3. Файлы автоматически загрузятся на сервер

## Разработка

### Зависимости

- **MFT Framework**: Кастомная библиотека для SFTP
- **libssh2**: Для SSH/SFTP подключений
- **OpenSSL**: Для шифрования

### Сборка зависимостей

```bash
cd mft-main
./build.sh
```

## Contributing

1. Fork репозиторий
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push branch (`git push origin feature/AmazingFeature`)
5. Создайте Pull Request

## Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE.md](mft-main/LICENSE.md) для деталей.

## Поддержка

Если у вас возникли проблемы или вопросы:

1. Проверьте [Issues](https://github.com/yourusername/SFTPush/issues) 
2. Создайте новый issue с детальным описанием проблемы
3. Включите логи и информацию о вашей среде

## Версии

- **v1.1.4** (последняя стабильная)
- **v1.1.3** (предыдущая версия)

Сборочные архивы доступны в [Releases](https://github.com/yourusername/SFTPush/releases).
