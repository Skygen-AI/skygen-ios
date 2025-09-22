//
//  MockData.swift
//  SkyGen
//
//  Mock data for all app sections
//

import Foundation

// MARK: - Mock Data Manager
class MockDataManager: ObservableObject {
    static let shared = MockDataManager()
    
    @Published var isUsingMockData = true
    
    private init() {}
    
    // MARK: - Chat Data
    func getChats() -> [MockChat] {
        return [
            MockChat(
                id: "chat-1",
                title: "Настройка сервера",
                lastMessage: "Сервер успешно настроен и готов к работе",
                timestamp: Date().addingTimeInterval(-3600),
                messageCount: 15,
                isPinned: true,
                folder: nil
            ),
            MockChat(
                id: "chat-2", 
                title: "Анализ логов",
                lastMessage: "Найдены потенциальные проблемы в логах...",
                timestamp: Date().addingTimeInterval(-7200),
                messageCount: 8,
                isPinned: false,
                folder: "Работа"
            ),
            MockChat(
                id: "chat-3",
                title: "Backup системы",
                lastMessage: "Создаем резервную копию базы данных",
                timestamp: Date().addingTimeInterval(-86400),
                messageCount: 23,
                isPinned: false,
                folder: "Системы"
            ),
            MockChat(
                id: "chat-4",
                title: "Мониторинг производительности",
                lastMessage: "CPU использование в норме",
                timestamp: Date().addingTimeInterval(-172800),
                messageCount: 41,
                isPinned: true,
                folder: nil
            )
        ]
    }
    
    func getChat(id: String) -> MockChat? {
        return getChats().first { $0.id == id }
    }
    
    func getMessages(for chatId: String) -> [MockMessage] {
        // Different message sets for different chats
        switch chatId {
        case "chat-1":
            return [
                MockMessage(
                    id: "msg-1",
                    content: "Привет! Как дела с автоматизацией умного дома?",
                    isFromUser: true,
                    timestamp: Date().addingTimeInterval(-3600),
                    type: .text
                ),
                MockMessage(
                    id: "msg-2",
                    content: "Привет! Отлично, что ты спросил. Я могу помочь тебе с настройкой устройств, созданием сценариев автоматизации и мониторингом системы. Что именно тебя интересует?",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-3590),
                    type: .text
                ),
                MockMessage(
                    id: "msg-3",
                    content: "Хочу настроить автоматическое включение света в прихожей когда открывается дверь",
                    isFromUser: true,
                    timestamp: Date().addingTimeInterval(-3400),
                    type: .text
                ),
                MockMessage(
                    id: "msg-4",
                    content: "Отлично! Для этого нам понадобится:\n\n1. Датчик открытия двери\n2. Умная лампочка или выключатель\n3. Настройка сценария\n\nУ тебя уже есть эти устройства?",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-3390),
                    type: .text
                ),
                MockMessage(
                    id: "msg-5",
                    content: "Да, датчик есть. А можно посмотреть список моих устройств?",
                    isFromUser: true,
                    timestamp: Date().addingTimeInterval(-3200),
                    type: .text
                ),
                MockMessage(
                    id: "msg-6",
                    content: "Конечно! Вот твои подключенные устройства:",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-3190),
                    type: .text
                ),
                MockMessage(
                    id: "msg-7",
                    content: "🏠 **Домашние устройства:**\n• Датчик двери (Прихожая) - ✅ Онлайн\n• Умная лампа Philips Hue (Прихожая) - ✅ Онлайн\n• Выключатель Xiaomi (Гостиная) - ⚠️ Слабый сигнал\n• Термостат Nest - ✅ Онлайн",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-3180),
                    type: .text
                ),
                MockMessage(
                    id: "msg-8",
                    content: "Отлично! Создать сценарий для автоматического включения света?",
                    isFromUser: true,
                    timestamp: Date().addingTimeInterval(-3000),
                    type: .text
                ),
                MockMessage(
                    id: "msg-9",
                    content: "Создаю сценарий \"Свет в прихожей\"...",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-2990),
                    type: .text,
                    isLoading: true
                )
            ]
            
        case "chat-2":
            return [
                MockMessage(
                    id: "msg-10",
                    content: "Проблема с термостатом Nest",
                    isFromUser: true,
                    timestamp: Date().addingTimeInterval(-1800),
                    type: .text
                ),
                MockMessage(
                    id: "msg-11",
                    content: "Понял, расскажи подробнее о проблеме с термостатом. Какие симптомы ты наблюдаешь?",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-1790),
                    type: .text
                ),
                MockMessage(
                    id: "msg-12",
                    content: "Не реагирует на изменения температуры через приложение",
                    isFromUser: true,
                    timestamp: Date().addingTimeInterval(-1700),
                    type: .text
                ),
                MockMessage(
                    id: "msg-13",
                    content: "Проверяю статус устройства... Нашел проблему - потеряно соединение с Wi-Fi. Попробуй перезагрузить роутер или переподключить термостат к сети.",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-1690),
                    type: .text
                )
            ]
            
        default:
            return [
                MockMessage(
                    id: "msg-welcome",
                    content: "Привет! Я твой AI-помощник для управления умным домом. Чем могу помочь?",
                    isFromUser: false,
                    timestamp: Date().addingTimeInterval(-300),
                    type: .text
                )
            ]
        }
    }
    
    // MARK: - Device Data
    func getDevices() -> [MockDevice] {
        return [
            MockDevice(
                id: "device-1",
                name: "MacBook Pro M3",
                type: .macOS,
                status: .online,
                lastSeen: Date(),
                version: "macOS 14.5",
                ipAddress: "192.168.1.100",
                location: "Офис"
            ),
            MockDevice(
                id: "device-2",
                name: "Ubuntu Server",
                type: .linux,
                status: .online,
                lastSeen: Date().addingTimeInterval(-300),
                version: "Ubuntu 22.04 LTS",
                ipAddress: "192.168.1.101",
                location: "Дата-центр"
            ),
            MockDevice(
                id: "device-3",
                name: "iPhone 15 Pro",
                type: .iOS,
                status: .offline,
                lastSeen: Date().addingTimeInterval(-3600),
                version: "iOS 17.5",
                ipAddress: "192.168.1.102",
                location: "Мобильный"
            ),
            MockDevice(
                id: "device-4",
                name: "Windows Workstation",
                type: .windows,
                status: .maintenance,
                lastSeen: Date().addingTimeInterval(-1800),
                version: "Windows 11 Pro",
                ipAddress: "192.168.1.103",
                location: "Офис"
            )
        ]
    }
    
    func getDevice(id: String) -> MockDevice? {
        return getDevices().first { $0.id == id }
    }
    
    // MARK: - Action Data
    func getActions() -> [MockAction] {
        return [
            MockAction(
                id: "action-1",
                title: "Обновление системы",
                deviceName: "Ubuntu Server",
                status: .running,
                progress: 0.65,
                startTime: Date().addingTimeInterval(-1800),
                estimatedCompletion: Date().addingTimeInterval(900)
            ),
            MockAction(
                id: "action-2",
                title: "Создание бэкапа",
                deviceName: "MacBook Pro M3",
                status: .completed,
                progress: 1.0,
                startTime: Date().addingTimeInterval(-7200),
                estimatedCompletion: Date().addingTimeInterval(-3600)
            ),
            MockAction(
                id: "action-3",
                title: "Сканирование безопасности",
                deviceName: "Windows Workstation",
                status: .failed,
                progress: 0.3,
                startTime: Date().addingTimeInterval(-3600),
                estimatedCompletion: nil
            ),
            MockAction(
                id: "action-4",
                title: "Очистка временных файлов",
                deviceName: "MacBook Pro M3",
                status: .queued,
                progress: 0.0,
                startTime: nil,
                estimatedCompletion: nil
            )
        ]
    }
    
    func getAction(id: String) -> MockAction? {
        return getActions().first { $0.id == id }
    }
    
    // MARK: - Integration Data
    func getIntegrations() -> [MockIntegration] {
        return [
            MockIntegration(
                id: "integration-1",
                name: "Gmail",
                type: .email,
                status: .connected,
                scope: "Полный доступ",
                icon: "envelope",
                description: "Доступ к почте и отправка уведомлений",
                permissions: ["Чтение писем", "Отправка писем"],
                lastSync: Date().addingTimeInterval(-1800)
            ),
            MockIntegration(
                id: "integration-2",
                name: "Telegram",
                type: .messaging,
                status: .connected,
                scope: "Отправка сообщений",
                icon: "message",
                description: "Уведомления и быстрые команды",
                permissions: ["Отправка сообщений", "Получение команд"],
                lastSync: Date().addingTimeInterval(-300)
            ),
            MockIntegration(
                id: "integration-3",
                name: "Google Calendar",
                type: .calendar,
                status: .expired,
                scope: "Чтение и запись",
                icon: "calendar",
                description: "Планирование задач и напоминания",
                permissions: ["Чтение календаря", "Создание событий"],
                lastSync: Date().addingTimeInterval(-86400 * 3)
            ),
            MockIntegration(
                id: "integration-4",
                name: "Google Drive",
                type: .storage,
                status: .disconnected,
                scope: "Управление файлами",
                icon: "folder",
                description: "Хранение файлов и резервных копий",
                permissions: ["Чтение файлов", "Создание файлов"],
                lastSync: nil
            )
        ]
    }
    
    func getIntegration(id: String) -> MockIntegration? {
        return getIntegrations().first { $0.id == id }
    }
}

// MARK: - Data Models
struct MockChat: Identifiable, Hashable {
    let id: String
    let title: String
    let lastMessage: String
    let timestamp: Date
    let messageCount: Int
    let isPinned: Bool
    let folder: String?
}

struct MockDevice: Identifiable, Hashable {
    let id: String
    let name: String
    let type: DeviceType
    let status: DeviceStatus
    let lastSeen: Date
    let version: String
    let ipAddress: String
    let location: String
    
    enum DeviceType: String, CaseIterable {
        case macOS = "macOS"
        case iOS = "iOS"
        case linux = "Linux"
        case windows = "Windows"
        case android = "Android"
        
        var icon: String {
            switch self {
            case .macOS: return "desktopcomputer"
            case .iOS: return "iphone"
            case .linux: return "terminal"
            case .windows: return "pc"
            case .android: return "phone.badge.checkmark"
            }
        }
    }
    
    enum DeviceStatus: String, CaseIterable {
        case online = "Онлайн"
        case offline = "Оффлайн"
        case maintenance = "Обслуживание"
        case error = "Ошибка"
        
        var color: String {
            switch self {
            case .online: return "success"
            case .offline: return "textSecondary"
            case .maintenance: return "warning"
            case .error: return "error"
            }
        }
    }
}

struct MockAction: Identifiable, Hashable {
    let id: String
    let title: String
    let deviceName: String
    let status: ActionStatus
    let progress: Double
    let startTime: Date?
    let estimatedCompletion: Date?
    
    enum ActionStatus: String, CaseIterable {
        case queued = "В очереди"
        case running = "Выполняется"
        case completed = "Завершено"
        case failed = "Ошибка"
        case cancelled = "Отменено"
        
        var color: String {
            switch self {
            case .queued: return "textSecondary"
            case .running: return "accent"
            case .completed: return "success"
            case .failed: return "error"
            case .cancelled: return "textTertiary"
            }
        }
        
        var icon: String {
            switch self {
            case .queued: return "clock"
            case .running: return "play.circle"
            case .completed: return "checkmark.circle"
            case .failed: return "xmark.circle"
            case .cancelled: return "stop.circle"
            }
        }
    }
}

struct MockIntegration: Identifiable, Hashable {
    let id: String
    let name: String
    let type: IntegrationType
    let status: ConnectionStatus
    let scope: String
    let icon: String
    let description: String
    let permissions: [String]
    let lastSync: Date?
    
    // Compatibility property
    var isConnected: Bool {
        return status == .connected
    }
    
    enum IntegrationType: String, CaseIterable {
        case email = "Email"
        case messaging = "Мессенджер"
        case calendar = "Календарь"
        case storage = "Хранилище"
        case social = "Социальные сети"
    }
    
    enum ConnectionStatus: String, CaseIterable {
        case connected = "Подключено"
        case disconnected = "Отключено"
        case expired = "Токен истек"
        case error = "Ошибка"
        
        var color: String {
            switch self {
            case .connected: return "success"
            case .disconnected: return "textSecondary"
            case .expired: return "warning"
            case .error: return "error"
            }
        }
    }
}

struct MockMessage: Identifiable, Hashable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let type: MessageType
    var isLoading: Bool = false
    
    enum MessageType: String, CaseIterable {
        case text = "text"
        case image = "image"
        case file = "file"
        case action = "action"
        
        var icon: String {
            switch self {
            case .text: return "text.bubble"
            case .image: return "photo"
            case .file: return "doc"
            case .action: return "play.circle"
            }
        }
    }
}
