import SwiftUI

struct PaywallView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PricingPlan = .monthly
    @State private var showingRestorePurchases = false
    @State private var toast: SkyToast?
    
    enum PricingPlan: String, CaseIterable {
        case monthly = "monthly"
        case yearly = "yearly"
        case lifetime = "lifetime"
        
        var title: String {
            switch self {
            case .monthly: return "Ежемесячно"
            case .yearly: return "Ежегодно"
            case .lifetime: return "Навсегда"
            }
        }
        
        var price: String {
            switch self {
            case .monthly: return "₽599/мес"
            case .yearly: return "₽4990/год"
            case .lifetime: return "₽14990"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Экономия 30%"
            case .lifetime: return "Лучшее предложение"
            }
        }
        
        var description: String {
            switch self {
            case .monthly: return "₽599 в месяц, отмена в любое время"
            case .yearly: return "₽416 в месяц, выставляется ежегодно"
            case .lifetime: return "Единоразовый платеж, навсегда"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.xl) {
                    // Header
                    VStack(spacing: theme.spacing.lg) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(Color.accentColor)
                        
                        VStack(spacing: theme.spacing.sm) {
                            Text("SkyGen Pro")
                                .textStyle(.headlineLarge)
                                .foregroundColor(theme.colors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Разблокируйте весь потенциал вашего умного дома")
                                .textStyle(.bodyLarge)
                                .foregroundColor(theme.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        FeatureRow(
                            icon: "infinity",
                            title: "Безлимитные чаты",
                            description: "Создавайте сколько угодно AI-помощников"
                        )
                        
                        FeatureRow(
                            icon: "icloud.and.arrow.up",
                            title: "Облачная синхронизация",
                            description: "Доступ к чатам с любого устройства"
                        )
                        
                        FeatureRow(
                            icon: "speedometer",
                            title: "Приоритетная обработка",
                            description: "Быстрые ответы и выполнение команд"
                        )
                        
                        FeatureRow(
                            icon: "shield.checkerboard",
                            title: "Расширенная безопасность",
                            description: "Шифрование данных и приватные модели"
                        )
                        
                        FeatureRow(
                            icon: "app.connected.to.app.below.fill",
                            title: "Больше интеграций",
                            description: "Подключайте любые сервисы и устройства"
                        )
                        
                        FeatureRow(
                            icon: "headphones",
                            title: "Приоритетная поддержка",
                            description: "Техническая поддержка 24/7"
                        )
                    }
                    .padding(.horizontal, theme.spacing.screenPadding)
                    
                    // Pricing Plans
                    VStack(spacing: theme.spacing.md) {
                        Text("Выберите план")
                            .textStyle(.titleMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        VStack(spacing: theme.spacing.sm) {
                            ForEach(PricingPlan.allCases, id: \.self) { plan in
                                PricingPlanCard(
                                    plan: plan,
                                    isSelected: selectedPlan == plan,
                                    onSelect: {
                                        selectedPlan = plan
                                        HapticFeedback.light()
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, theme.spacing.screenPadding)
                    
                    // Action Buttons
                    VStack(spacing: theme.spacing.md) {
                        Button("Продолжить с \(selectedPlan.title)") {
                            // Mock purchase
                            simulatePurchase()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, theme.spacing.screenPadding)
                        
                        Button("Восстановить покупки") {
                            showingRestorePurchases = true
                            simulateRestorePurchases()
                        }
                        .buttonStyle(TertiaryButtonStyle())
                        .padding(.horizontal, theme.spacing.screenPadding)
                    }
                    
                    // Legal Links
                    VStack(spacing: theme.spacing.sm) {
                        Text("Подписка автоматически продлевается. Отмена в любое время в настройках App Store.")
                            .textStyle(.caption)
                            .foregroundColor(theme.colors.textTertiary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: theme.spacing.lg) {
                            Button("Условия использования") {
                                // Open terms
                            }
                            .foregroundColor(Color.accentColor)
                            .textStyle(.caption)
                            
                            Button("Политика конфиденциальности") {
                                // Open privacy policy
                            }
                            .foregroundColor(Color.accentColor)
                            .textStyle(.caption)
                        }
                    }
                    .padding(.horizontal, theme.spacing.screenPadding)
                }
                .padding(.vertical, theme.spacing.lg)
            }
            .background(theme.colors.background)
            .navigationTitle("SkyGen Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Пропустить") {
                        dismiss()
                    }
                    .foregroundColor(theme.colors.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
            }
        }
        .toastOverlay(toast: $toast)
    }
    
    private func simulatePurchase() {
        HapticFeedback.success()
        toast = SkyToast(
            message: "Покупка успешно завершена! Добро пожаловать в SkyGen Pro 🎉",
            style: .success,
            duration: 4.0,
            isPresented: .constant(true)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
    
    private func simulateRestorePurchases() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingRestorePurchases = false
            toast = SkyToast(
                message: "Покупки восстановлены",
                style: .info,
                isPresented: .constant(true)
            )
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: theme.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.accentColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text(description)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Pricing Plan Card
struct PricingPlanCard: View {
    @Environment(\.theme) private var theme
    let plan: PaywallView.PricingPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: theme.spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack {
                            Text(plan.title)
                                .textStyle(.titleSmall)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            if let savings = plan.savings {
                                Text(savings)
                                    .textStyle(.captionSmall)
                                    .foregroundColor(Color.accentColor)
                                    .padding(.horizontal, theme.spacing.xs)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(theme.radius.xs)
                            }
                            
                            Spacer()
                        }
                        
                        Text(plan.description)
                            .textStyle(.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    
                    Text(plan.price)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                }
                
                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.accentColor)
                        
                        Text("Выбрано")
                            .textStyle(.caption)
                            .foregroundColor(Color.accentColor)
                        
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(theme.spacing.md)
            .background(isSelected ? Color.accentColor.opacity(0.1) : theme.colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .stroke(
                        isSelected ? Color.accentColor : theme.colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(theme.radius.md)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    ThemeProvider {
        PaywallView()
    }
}
