//
//  OnboardingManager.swift
//  SkyGen
//
//  Onboarding flow management
//

import SwiftUI
import Foundation

// MARK: - Onboarding Steps
enum OnboardingStep: String, CaseIterable {
    case welcome = "welcome"
    case features = "features"
    case privacy = "privacy"
    case permissions = "permissions"
    case integrations = "integrations"
    case complete = "complete"
    
    var title: String {
        switch self {
        case .welcome:
            return "Добро пожаловать в SkyGen"
        case .features:
            return "Возможности"
        case .privacy:
            return "Приватность и безопасность"
        case .permissions:
            return "Разрешения"
        case .integrations:
            return "Интеграции"
        case .complete:
            return "Все готово!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome:
            return "Ваш персональный AI-помощник для управления устройствами и автоматизации задач"
        case .features:
            return "Узнайте о ключевых возможностях SkyGen"
        case .privacy:
            return "Ваши данные под надежной защитой"
        case .permissions:
            return "Для полной функциональности нужны некоторые разрешения"
        case .integrations:
            return "Подключите ваши аккаунты для расширения возможностей"
        case .complete:
            return "SkyGen настроен и готов к работе"
        }
    }
    
    var icon: String {
        switch self {
        case .welcome:
            return "hand.wave.fill"
        case .features:
            return "star.fill"
        case .privacy:
            return "lock.shield.fill"
        case .permissions:
            return "checkmark.shield.fill"
        case .integrations:
            return "link.circle.fill"
        case .complete:
            return "checkmark.circle.fill"
        }
    }
}

// MARK: - Onboarding Manager
@MainActor
class OnboardingManager: ObservableObject {
    @Published var isOnboardingCompleted: Bool = false
    @Published var currentStep: OnboardingStep = .welcome
    @Published var hasCompletedIntro: Bool = false
    @Published var hasGrantedNotifications: Bool = false
    @Published var selectedLanguage: String = "en"
    @Published var agreedToTerms: Bool = false
    @Published var agreedToPrivacy: Bool = false
    @Published var connectedIntegrations: Set<String> = []
    
    private let userDefaultsKey = "com.skygen.onboarding.completed"
    private let introCompletedKey = "com.skygen.intro.completed"
    
    init() {
        loadOnboardingState()
    }
    
    func loadOnboardingState() {
        isOnboardingCompleted = UserDefaults.standard.bool(forKey: userDefaultsKey)
        hasCompletedIntro = UserDefaults.standard.bool(forKey: introCompletedKey)
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }
    
    func completeIntro() {
        hasCompletedIntro = true
        UserDefaults.standard.set(true, forKey: introCompletedKey)
    }
    
    func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else {
            completeOnboarding()
            return
        }
        
        currentStep = OnboardingStep.allCases[currentIndex + 1]
    }
    
    func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else {
            return
        }
        
        currentStep = OnboardingStep.allCases[currentIndex - 1]
    }
    
    func skipToEnd() {
        completeOnboarding()
    }
    
    func resetOnboarding() {
        isOnboardingCompleted = false
        hasCompletedIntro = false
        currentStep = .welcome
        hasGrantedNotifications = false
        selectedLanguage = "en"
        agreedToTerms = false
        agreedToPrivacy = false
        connectedIntegrations = []
        
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: introCompletedKey)
    }
    
    // MARK: - Step Progress
    var progress: Double {
        let totalSteps = OnboardingStep.allCases.count
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else {
            return 0
        }
        return Double(currentIndex + 1) / Double(totalSteps)
    }
    
    var isFirstStep: Bool {
        currentStep == OnboardingStep.allCases.first
    }
    
    var isLastStep: Bool {
        currentStep == OnboardingStep.allCases.last
    }
    
    // MARK: - Step Validation
    func canProceedFromCurrentStep() -> Bool {
        switch currentStep {
        case .welcome, .features:
            return true
        case .privacy:
            return agreedToTerms && agreedToPrivacy
        case .permissions:
            return true // Optional permissions
        case .integrations:
            return true // Optional integrations
        case .complete:
            return true
        }
    }
}

// MARK: - Onboarding Content Data
struct OnboardingContent {
    let step: OnboardingStep
    let features: [FeatureHighlight]
    
    static let allContent: [OnboardingContent] = [
        OnboardingContent(
            step: .welcome,
            features: []
        ),
        OnboardingContent(
            step: .features,
            features: [
                FeatureHighlight(
                    icon: "message.circle.fill",
                    title: "AI Чаты",
                    description: "Общайтесь с умным ассистентом для управления устройствами"
                ),
                FeatureHighlight(
                    icon: "laptopcomputer.and.iphone",
                    title: "Управление устройствами",
                    description: "Контролируйте все ваши устройства из одного места"
                ),
                FeatureHighlight(
                    icon: "play.circle.fill",
                    title: "Автоматизация",
                    description: "Настраивайте автоматические действия и сценарии"
                ),
                FeatureHighlight(
                    icon: "link.circle.fill",
                    title: "Интеграции",
                    description: "Подключайте популярные сервисы и приложения"
                )
            ]
        ),
        OnboardingContent(
            step: .privacy,
            features: [
                FeatureHighlight(
                    icon: "lock.fill",
                    title: "Шифрование",
                    description: "Все данные защищены современным шифрованием"
                ),
                FeatureHighlight(
                    icon: "eye.slash.fill",
                    title: "Приватность",
                    description: "Мы не продаем и не передаем ваши данные третьим лицам"
                ),
                FeatureHighlight(
                    icon: "shield.checkered",
                    title: "Безопасность",
                    description: "Двухфакторная аутентификация и Face ID защита"
                )
            ]
        ),
        OnboardingContent(
            step: .permissions,
            features: [
                FeatureHighlight(
                    icon: "bell.fill",
                    title: "Уведомления",
                    description: "Получайте важные уведомления о статусе устройств"
                ),
                FeatureHighlight(
                    icon: "mic.fill",
                    title: "Микрофон",
                    description: "Для голосовых команд и диктовки сообщений"
                ),
                FeatureHighlight(
                    icon: "camera.fill",
                    title: "Камера",
                    description: "Для отправки изображений в чатах с ассистентом"
                )
            ]
        ),
        OnboardingContent(
            step: .integrations,
            features: [
                FeatureHighlight(
                    icon: "envelope.fill",
                    title: "Gmail",
                    description: "Отправка отчетов и уведомлений на email"
                ),
                FeatureHighlight(
                    icon: "message.fill",
                    title: "Telegram",
                    description: "Быстрые команды и уведомления в мессенджере"
                ),
                FeatureHighlight(
                    icon: "calendar",
                    title: "Google Calendar",
                    description: "Планирование задач и автоматических действий"
                ),
                FeatureHighlight(
                    icon: "folder.fill",
                    title: "Google Drive",
                    description: "Хранение логов и резервных копий"
                )
            ]
        ),
        OnboardingContent(
            step: .complete,
            features: []
        )
    ]
    
    static func content(for step: OnboardingStep) -> OnboardingContent? {
        return allContent.first { $0.step == step }
    }
}

struct FeatureHighlight {
    let icon: String
    let title: String
    let description: String
}
