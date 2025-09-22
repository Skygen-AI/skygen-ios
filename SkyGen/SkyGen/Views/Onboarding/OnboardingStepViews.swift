//
//  OnboardingStepViews.swift
//  SkyGen
//
//  Individual step views for onboarding
//

import SwiftUI

// MARK: - Privacy Step
struct OnboardingPrivacyContent: View {
    @Environment(\.theme) private var theme
    @ObservedObject var onboardingManager: OnboardingManager
    
    private let privacyFeatures = OnboardingContent.content(for: .privacy)?.features ?? []
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            // Features
            VStack(spacing: theme.spacing.md) {
                ForEach(privacyFeatures, id: \.title) { feature in
                    FeatureCard(feature: feature)
                }
            }
            
            // Agreements
            VStack(spacing: theme.spacing.md) {
                SkyCard(backgroundColor: theme.colors.surfaceElevated) {
                    VStack(spacing: theme.spacing.md) {
                        HStack(spacing: theme.spacing.sm) {
                            Button {
                                onboardingManager.agreedToTerms.toggle()
                            } label: {
                                Image(systemName: onboardingManager.agreedToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(onboardingManager.agreedToTerms ? Color.accentColor : theme.colors.textTertiary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text("Я согласен с Условиями использования")
                                    .textStyle(.bodyMedium)
                                    .foregroundColor(theme.colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button("Прочитать условия") {
                                    // TODO: Show terms
                                }
                                .font(theme.typography.bodySmall)
                                .foregroundColor(Color.accentColor)
                            }
                        }
                        
                        HStack(spacing: theme.spacing.sm) {
                            Button {
                                onboardingManager.agreedToPrivacy.toggle()
                            } label: {
                                Image(systemName: onboardingManager.agreedToPrivacy ? "checkmark.square.fill" : "square")
                                    .foregroundColor(onboardingManager.agreedToPrivacy ? Color.accentColor : theme.colors.textTertiary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text("Я согласен с Политикой конфиденциальности")
                                    .textStyle(.bodyMedium)
                                    .foregroundColor(theme.colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button("Прочитать политику") {
                                    // TODO: Show privacy policy
                                }
                                .font(theme.typography.bodySmall)
                                .foregroundColor(Color.accentColor)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Permissions Step
struct OnboardingPermissionsContent: View {
    @Environment(\.theme) private var theme
    @ObservedObject var onboardingManager: OnboardingManager
    
    private let permissionFeatures = OnboardingContent.content(for: .permissions)?.features ?? []
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Text("Разрешения помогают SkyGen работать лучше, но они не обязательны. Вы можете настроить их позже в настройках.")
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: theme.spacing.md) {
                ForEach(permissionFeatures, id: \.title) { feature in
                    PermissionCard(
                        feature: feature,
                        isGranted: getPermissionStatus(for: feature.title),
                        onToggle: {
                            requestPermission(for: feature.title)
                        }
                    )
                }
            }
        }
    }
    
    private func getPermissionStatus(for permission: String) -> Bool {
        switch permission {
        case "Уведомления":
            return onboardingManager.hasGrantedNotifications
        default:
            return false
        }
    }
    
    private func requestPermission(for permission: String) {
        switch permission {
        case "Уведомления":
            requestNotificationPermission()
        case "Микрофон":
            // TODO: Request microphone permission
            break
        case "Камера":
            // TODO: Request camera permission
            break
        default:
            break
        }
    }
    
    private func requestNotificationPermission() {
        // Simulate permission request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onboardingManager.hasGrantedNotifications = true
        }
    }
}

struct PermissionCard: View {
    @Environment(\.theme) private var theme
    let feature: FeatureHighlight
    let isGranted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        SkyCard {
            HStack(spacing: theme.spacing.md) {
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isGranted ? theme.colors.success : Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background((isGranted ? theme.colors.success : Color.accentColor).opacity(0.1))
                    .cornerRadius(theme.radius.sm)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(feature.title)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(feature.description)
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Group {
                    if isGranted {
                        Button("Разрешено") {
                            // Already granted
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(true)
                    } else {
                        Button("Разрешить") {
                            onToggle()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .font(theme.typography.labelSmall)
            }
        }
    }
}

// MARK: - Integrations Step
struct OnboardingIntegrationsContent: View {
    @Environment(\.theme) private var theme
    @ObservedObject var onboardingManager: OnboardingManager
    
    private let integrationFeatures = OnboardingContent.content(for: .integrations)?.features ?? []
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Text("Подключите ваши аккаунты для расширения возможностей SkyGen. Это необязательно — вы можете сделать это позже.")
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: theme.spacing.md) {
                ForEach(integrationFeatures, id: \.title) { feature in
                    OnboardingIntegrationCard(
                        feature: feature,
                        isConnected: onboardingManager.connectedIntegrations.contains(feature.title),
                        onToggle: {
                            toggleIntegration(feature.title)
                        }
                    )
                }
            }
        }
    }
    
    private func toggleIntegration(_ integration: String) {
        if onboardingManager.connectedIntegrations.contains(integration) {
            onboardingManager.connectedIntegrations.remove(integration)
        } else {
            // Simulate connection
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onboardingManager.connectedIntegrations.insert(integration)
            }
        }
    }
}

struct OnboardingIntegrationCard: View {
    @Environment(\.theme) private var theme
    let feature: FeatureHighlight
    let isConnected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        SkyCard {
            HStack(spacing: theme.spacing.md) {
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isConnected ? theme.colors.success : Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background((isConnected ? theme.colors.success : Color.accentColor).opacity(0.1))
                    .cornerRadius(theme.radius.sm)
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(feature.title)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(feature.description)
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Group {
                    if isConnected {
                        Button("Подключено") {
                            // Already connected
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(true)
                    } else {
                        Button("Подключить") {
                            onToggle()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .font(theme.typography.labelSmall)
            }
        }
    }
}

// MARK: - Complete Step
struct OnboardingCompleteContent: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Text("SkyGen настроен и готов помочь вам управлять устройствами и автоматизировать задачи.")
                .textStyle(.bodyLarge)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: theme.spacing.md) {
                SkyStatusCard(
                    status: .success,
                    title: "Настройка завершена",
                    message: "Все компоненты SkyGen готовы к работе"
                )
                
                SkyCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(theme.colors.warning)
                            Text("Совет")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                        }
                        
                        Text("Начните с создания первого чата с AI-ассистентом. Он поможет вам настроить устройства и автоматизацию.")
                            .textStyle(.bodySmall)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview("Privacy") {
    ThemeProvider {
        ScrollView {
            OnboardingPrivacyContent(onboardingManager: OnboardingManager())
                .padding()
        }
        .background(Color.background)
    }
}

#Preview("Permissions") {
    ThemeProvider {
        ScrollView {
            OnboardingPermissionsContent(onboardingManager: OnboardingManager())
                .padding()
        }
        .background(Color.background)
    }
}

#Preview("Integrations") {
    ThemeProvider {
        ScrollView {
            OnboardingIntegrationsContent(onboardingManager: OnboardingManager())
                .padding()
        }
        .background(Color.background)
    }
}
