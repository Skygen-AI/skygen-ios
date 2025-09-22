//
//  InitialSetupView.swift
//  SkyGen
//
//  Initial setup and tips view
//

import SwiftUI

struct InitialSetupView: View {
    @Environment(\.theme) private var theme
    @State private var currentStep = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating: Bool = false
    
    // Данные для карточек с советами и настройками
    private let setupSteps: [SetupStep] = [
        SetupStep(
            title: "Добро пожаловать в Skygen",
            description: "Давайте настроим ваш профиль и познакомимся с основными возможностями приложения.",
            icon: "hand.wave.fill",
            type: .welcome
        ),
        SetupStep(
            title: "Set appearance",
            description: "Получайте важные уведомления о новых сообщениях и обновлениях системы.",
            icon: "bell.fill",
            type: .notifications
        ),
        SetupStep(
            title: "Безопасность данных",
            description: "Включите двухфакторную аутентификацию для защиты вашего аккаунта.",
            icon: "shield.fill",
            type: .security
        ),
        SetupStep(
            title: "Готово к работе",
            description: "Отлично! Теперь вы готовы использовать все возможности Skygen.",
            icon: "checkmark.circle.fill",
            type: .completion
        )
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            // Карточка с настройкой/советом (свайпабельная)
            GeometryReader { geometry in
                SetupCard(step: setupSteps[currentStep])
                    .offset(x: dragOffset)
                    .animation(.easeInOut(duration: 0.3), value: isAnimating)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isAnimating {
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if !isAnimating {
                                    handleSwipeGesture(value: value, screenWidth: geometry.size.width)
                                }
                            }
                    )
            }
            .frame(height: 400) // Увеличенная высота для единообразия карточек
            
            Spacer()
            
            // Прогресс-бар с кнопкой
            VStack(spacing: theme.spacing.xl) {
                // Прогресс-бар
                ProgressBarView(
                    currentStep: currentStep,
                    totalSteps: setupSteps.count
                )
                
                // Кнопка продолжения
                Button(action: {
                    nextStep()
                }) {
                    Text(currentStep == setupSteps.count - 1 ? "Завершить" : "Продолжить")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, 20)
            }
            .padding(.bottom, theme.spacing.xl)
        }
        .background(theme.colors.background)
        .ignoresSafeArea()
    }
    
    private func nextStep() {
        if currentStep < setupSteps.count - 1 {
            animateToNextStep()
        } else {
            // TODO: Завершить настройку
        }
    }
    
    private func animateToNextStep() {
        isAnimating = true
        
        // Анимация карточки справа налево
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = -UIScreen.main.bounds.width
        }
        
        // Смена шага и возврат карточки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep += 1
            dragOffset = UIScreen.main.bounds.width
            
            withAnimation(.easeInOut(duration: 0.3)) {
                dragOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
    
    private func handleSwipeGesture(value: DragGesture.Value, screenWidth: CGFloat) {
        let threshold: CGFloat = screenWidth * 0.3
        
        if value.translation.width < -threshold && currentStep < setupSteps.count - 1 {
            // Свайп влево - следующий шаг
            animateToNextStep()
        } else if value.translation.width > threshold && currentStep > 0 {
            // Свайп вправо - предыдущий шаг
            animateToPreviousStep()
        } else {
            // Возврат в исходное положение
            withAnimation(.easeInOut(duration: 0.2)) {
                dragOffset = 0
            }
        }
    }
    
    private func animateToPreviousStep() {
        isAnimating = true
        
        // Анимация карточки слева направо
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = UIScreen.main.bounds.width
        }
        
        // Смена шага и возврат карточки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep -= 1
            dragOffset = -UIScreen.main.bounds.width
            
            withAnimation(.easeInOut(duration: 0.3)) {
                dragOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        }
    }
    
    private func goToStep(_ step: Int) {
        // Разрешаем переход на любой шаг (и вперед, и назад)
        if step >= 0 && step < setupSteps.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = step
            }
        }
    }
}

// MARK: - Setup Step Model
struct SetupStep {
    let title: String
    let description: String
    let icon: String
    let type: SetupStepType
}

enum SetupStepType {
    case welcome
    case notifications
    case security
    case completion
}

// MARK: - Setup Card Component
struct SetupCard: View {
    let step: SetupStep
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.xl) {
            // Иконка (скрыта для notifications)
            if step.type != .notifications {
                Image(systemName: step.icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(theme.colors.accent)
            }
            
            // Контент
            VStack(spacing: theme.spacing.md) {
                Text(step.title)
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Описание (скрыто для notifications)
                if step.type != .notifications {
                    Text(step.description)
                        .textStyle(.bodyMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
            }
            
            // Дополнительный контент в зависимости от типа
            switch step.type {
            case .notifications:
                notificationSettings
            case .security:
                securitySettings
            default:
                Spacer() // Заполняем пустое пространство для карточек без настроек
            }
        }
        .padding(theme.spacing.xl)
        .background(theme.colors.surface)
        .cornerRadius(theme.radius.card)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, theme.spacing.screenPadding)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    @ViewBuilder
    private var notificationSettings: some View {
        VStack(spacing: theme.spacing.lg) {
            // Верхний ряд - две фотки с подписями
            HStack(spacing: theme.spacing.lg) {
                VStack(spacing: theme.spacing.sm) {
                    WelcomeIconPreview(isDark: true, size: 120) // В 2 раза больше
                    Text("Dark theme")
                        .textStyle(.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: theme.spacing.sm) {
                    WelcomeIconPreview(isDark: false, size: 120) // В 2 раза больше
                    Text("Light theme")
                        .textStyle(.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity) // Центрирование
            
            // Нижний ряд - одна совмещенная фотка с подписью
            VStack(spacing: theme.spacing.sm) {
                WelcomeIconCombined(size: 120) // Совмещенная фотка
                Text("Adaptive theme")
                    .textStyle(.caption)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity) // Центрирование
            
            Spacer() // Заполняем оставшееся пространство
        }
        .frame(maxWidth: .infinity) // Общее центрирование
    }
    
    @ViewBuilder
    private var securitySettings: some View {
        VStack(spacing: theme.spacing.sm) {
            SettingToggle(title: "Двухфакторная аутентификация", isOn: .constant(false))
            SettingToggle(title: "Биометрическая разблокировка", isOn: .constant(true))
            Spacer() // Заполняем оставшееся пространство
        }
    }
}

// MARK: - Setting Toggle Component
struct SettingToggle: View {
    let title: String
    @Binding var isOn: Bool
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            Text(title)
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.backgroundSecondary)
        .cornerRadius(theme.radius.sm)
    }
}

// MARK: - Progress Bar Component
struct ProgressBarView: View {
    let currentStep: Int
    let totalSteps: Int
    @Environment(\.theme) private var theme
    
    private var progress: CGFloat {
        CGFloat(currentStep + 1) / CGFloat(totalSteps)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фоновая полоска
                Rectangle()
                    .fill(theme.colors.borderSubtle)
                    .frame(height: 8)
                
                // Заполненная часть с градиентом
                Rectangle()
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
            .cornerRadius(4) // Применяем закругление ко всему контейнеру
        }
        .frame(height: 8)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, theme.spacing.screenPadding)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0/255, green: 201/255, blue: 159/255),    // #00C99F (более синий)
                Color(red: 82/255, green: 174/255, blue: 111/255)    // #52AE6F (более зеленый)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Welcome Icon Preview Components
struct WelcomeIconPreview: View {
    let isDark: Bool
    let size: CGFloat
    @Environment(\.theme) private var theme
    
    init(isDark: Bool, size: CGFloat = 60) {
        self.isDark = isDark
        self.size = size
    }
    
    var body: some View {
        Image(isDark ? "WelcomeIconDark" : "WelcomeIconLight")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .cornerRadius(theme.radius.sm)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct WelcomeIconCombined: View {
    let size: CGFloat
    @Environment(\.theme) private var theme
    
    init(size: CGFloat = 120) {
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Левая половина (тёмная)
            GeometryReader { geometry in
                Image("WelcomeIconDark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .offset(x: 0) // Показываем левую половину
                    .clipped()
            }
            .frame(width: size/2, height: size)
            
            // Правая половина (светлая)
            GeometryReader { geometry in
                Image("WelcomeIconLight")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .offset(x: -size/2) // Сдвиг для показа правой половины
                    .clipped()
            }
            .frame(width: size/2, height: size)
        }
        .frame(width: size, height: size)
        .cornerRadius(theme.radius.sm)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    ThemeProvider {
        InitialSetupView()
    }
}
