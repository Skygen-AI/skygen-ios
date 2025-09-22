//
//  OnboardingView.swift
//  SkyGen
//
//  Main onboarding flow view
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var currentPageIndex = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                OnboardingProgressBar(progress: onboardingManager.progress)
                    .padding(.horizontal, theme.spacing.screenPadding)
                    .padding(.top, theme.spacing.md)
                
                // Content
                TabView(selection: $currentPageIndex) {
                    ForEach(Array(OnboardingStep.allCases.enumerated()), id: \.element) { index, step in
                        OnboardingPageView(
                            step: step,
                            onboardingManager: onboardingManager
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPageIndex) { newIndex in
                    if newIndex < OnboardingStep.allCases.count {
                        onboardingManager.currentStep = OnboardingStep.allCases[newIndex]
                    }
                }
                .onChange(of: onboardingManager.currentStep) { newStep in
                    if let newIndex = OnboardingStep.allCases.firstIndex(of: newStep) {
                        currentPageIndex = newIndex
                    }
                }
                
                // Navigation controls
                OnboardingNavigationControls(
                    onboardingManager: onboardingManager,
                    currentIndex: currentPageIndex
                )
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.screenPadding)
            }
            .background(theme.colors.background)
        }
        .environmentObject(onboardingManager)
    }
}

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    @Environment(\.theme) private var theme
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack {
                Text("Настройка")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: theme.radius.xs)
                        .fill(theme.colors.surface)
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: theme.radius.xs)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(theme.motion.easing.emphasized, value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Page View
struct OnboardingPageView: View {
    @Environment(\.theme) private var theme
    let step: OnboardingStep
    @ObservedObject var onboardingManager: OnboardingManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.xl) {
                Spacer(minLength: theme.spacing.lg)
                
                // Icon
                Image(systemName: step.icon)
                    .font(.system(size: 80))
                    .foregroundColor(Color.accentColor)
                
                // Header
                VStack(spacing: theme.spacing.sm) {
                    Text(step.title)
                        .textStyle(.displayMedium)
                        .foregroundColor(theme.colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(step.subtitle)
                        .textStyle(.bodyLarge)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Step-specific content
                stepContent
                
                Spacer(minLength: theme.spacing.xl)
            }
            .padding(.horizontal, theme.spacing.screenPadding)
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            OnboardingWelcomeContent()
        case .features:
            OnboardingFeaturesContent()
        case .privacy:
            OnboardingPrivacyContent(onboardingManager: onboardingManager)
        case .permissions:
            OnboardingPermissionsContent(onboardingManager: onboardingManager)
        case .integrations:
            OnboardingIntegrationsContent(onboardingManager: onboardingManager)
        case .complete:
            OnboardingCompleteContent()
        }
    }
}

// MARK: - Navigation Controls
struct OnboardingNavigationControls: View {
    @Environment(\.theme) private var theme
    @ObservedObject var onboardingManager: OnboardingManager
    let currentIndex: Int
    
    var body: some View {
        VStack(spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.md) {
                // Back button
                if !onboardingManager.isFirstStep {
                    Button("Назад") {
                        onboardingManager.previousStep()
                    }
                    .buttonStyle(TertiaryButtonStyle())
                } else {
                    Spacer()
                }
                
                Spacer()
                
                // Next/Complete button
                Button(onboardingManager.isLastStep ? "Начать использовать" : "Продолжить") {
                    if onboardingManager.isLastStep {
                        onboardingManager.completeOnboarding()
                    } else {
                        onboardingManager.nextStep()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!onboardingManager.canProceedFromCurrentStep())
            }
            
            // Skip button
            if !onboardingManager.isLastStep {
                Button("Пропустить настройку") {
                    onboardingManager.skipToEnd()
                }
                .buttonStyle(TertiaryButtonStyle())
                .font(theme.typography.bodySmall)
            }
        }
    }
}

// MARK: - Step Content Views
struct OnboardingWelcomeContent: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Text("Приложение поможет вам управлять устройствами, автоматизировать задачи и получать помощь от AI-ассистента.")
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            SkyCard {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color.accentColor)
                        Text("Что нового")
                            .textStyle(.titleMedium)
                            .foregroundColor(theme.colors.textPrimary)
                    }
                    
                    Text("• Умный AI-помощник\n• Управление устройствами\n• Автоматизация задач\n• Безопасная синхронизация")
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
        }
    }
}

struct OnboardingFeaturesContent: View {
    @Environment(\.theme) private var theme
    
    private let features = OnboardingContent.content(for: .features)?.features ?? []
    
    var body: some View {
        VStack(spacing: theme.spacing.md) {
            ForEach(features, id: \.title) { feature in
                FeatureCard(feature: feature)
            }
        }
    }
}

struct FeatureCard: View {
    @Environment(\.theme) private var theme
    let feature: FeatureHighlight
    
    var body: some View {
        SkyCard {
            HStack(spacing: theme.spacing.md) {
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor.opacity(0.1))
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
            }
        }
    }
}

#Preview {
    ThemeProvider {
        OnboardingView()
            .environmentObject(OnboardingManager())
    }
}
