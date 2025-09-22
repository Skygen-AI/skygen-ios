//
//  MagicLinkSentView.swift
//  SkyGen
//
//  Magic link sent confirmation view
//

import SwiftUI

struct MagicLinkSentView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var timeRemaining = 60
    @State private var canResend = false
    @State private var isResending = false
    @State private var isSkipping = false
    
    let email: String
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.xl) {
                Spacer()
                
                // Success illustration
                VStack(spacing: theme.spacing.lg) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(theme.colors.success)
                    
                    VStack(spacing: theme.spacing.sm) {
                        Text("Ссылка отправлена!")
                            .textStyle(.headlineLarge)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        VStack(spacing: theme.spacing.xs) {
                            Text("Мы отправили ссылку для входа на:")
                                .textStyle(.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
                            
                            Text(email)
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                        }
                    }
                }
                
                // Instructions
                SkyCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.accentColor)
                            Text("Инструкция")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            InstructionStep(
                                number: "1",
                                text: "Откройте почтовое приложение"
                            )
                            InstructionStep(
                                number: "2",
                                text: "Найдите письмо от SkyGen"
                            )
                            InstructionStep(
                                number: "3",
                                text: "Нажмите на ссылку в письме"
                            )
                        }
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: theme.spacing.md) {
                    // Test skip button (for development)
                    Button {
                        skipEmailVerification()
                    } label: {
                        HStack {
                            if isSkipping {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                    .scaleEffect(0.8)
                            }
                            Text("🧪 Пропустить (тест)")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isSkipping)
                    
                    // Resend button
                    Button {
                        resendMagicLink()
                    } label: {
                        HStack {
                            if isResending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                                    .scaleEffect(0.8)
                            }
                            
                            if canResend {
                                Text("Отправить повторно")
                            } else {
                                Text("Отправить повторно (\(timeRemaining)с)")
                            }
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(!canResend || isResending)
                    
                    // Change email button
                    Button("Изменить email") {
                        dismiss()
                    }
                    .buttonStyle(TertiaryButtonStyle())
                }
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Color.accentColor)
                }
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
                timer.upstream.connect().cancel()
            }
        }
    }
    
    private func resendMagicLink() {
        isResending = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isResending = false
            canResend = false
            timeRemaining = 60
            
            // Show success feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func skipEmailVerification() {
        isSkipping = true
        
        Task {
            do {
                // Simulate successful magic link verification
                try await authManager.verifyMagicLink(token: "test_token_12345")
                
                // Haptic feedback
                await MainActor.run {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            } catch {
                // Handle error if needed
                print("Test auth completion failed: \(error)")
            }
            
            await MainActor.run {
                isSkipping = false
            }
        }
    }
}

struct InstructionStep: View {
    @Environment(\.theme) private var theme
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Text(number)
                .textStyle(.labelSmall)
                .foregroundColor(Color.accentColor)
                .frame(width: 20, height: 20)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(theme.radius.full)
            
            Text(text)
                .textStyle(.bodySmall)
                .foregroundColor(theme.colors.textSecondary)
            
            Spacer()
        }
    }
}

#Preview {
    ThemeProvider {
        MagicLinkSentView(email: "user@example.com")
    }
}
