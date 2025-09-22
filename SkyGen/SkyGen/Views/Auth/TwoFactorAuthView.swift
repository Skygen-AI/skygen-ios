//
//  TwoFactorAuthView.swift
//  SkyGen
//
//  Two-factor authentication view
//

import SwiftUI

enum TwoFactorMethod: String, CaseIterable {
    case email = "email"
    case totp = "totp"
    
    var title: String {
        switch self {
        case .email: return "Email код"
        case .totp: return "Authenticator"
        }
    }
    
    var icon: String {
        switch self {
        case .email: return "envelope"
        case .totp: return "shield"
        }
    }
    
    var description: String {
        switch self {
        case .email: return "Код будет отправлен на ваш email"
        case .totp: return "Используйте приложение Authenticator"
        }
    }
}

struct TwoFactorAuthView: View {
    @Environment(\.theme) private var theme
    @State private var selectedMethod: TwoFactorMethod = .email
    @State private var showCodeEntry = false
    @State private var isLoading = false
    
    let email: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.xl) {
                // Header
                VStack(spacing: theme.spacing.lg) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 64))
                        .foregroundColor(Color.accentColor)
                    
                    VStack(spacing: theme.spacing.sm) {
                        Text("Двухфакторная аутентификация")
                            .textStyle(.headlineLarge)
                            .foregroundColor(theme.colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Выберите способ подтверждения для дополнительной защиты аккаунта")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Method selection
                VStack(spacing: theme.spacing.md) {
                    ForEach(TwoFactorMethod.allCases, id: \.rawValue) { method in
                        TwoFactorMethodCard(
                            method: method,
                            isSelected: selectedMethod == method,
                            email: email
                        ) {
                            selectedMethod = method
                        }
                    }
                }
                
                Spacer()
                
                // Continue button
                Button {
                    proceedWithSelectedMethod()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Продолжить")
                        }
                    }
                }
                .buttonStyle(.primary)
                .disabled(isLoading)
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle("2FA")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showCodeEntry) {
            CodeEntryView(
                method: selectedMethod,
                email: email
            )
        }
    }
    
    private func proceedWithSelectedMethod() {
        isLoading = true
        
        // Simulate API call to initiate 2FA
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            showCodeEntry = true
        }
    }
}

struct TwoFactorMethodCard: View {
    @Environment(\.theme) private var theme
    
    let method: TwoFactorMethod
    let isSelected: Bool
    let email: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: theme.spacing.md) {
                // Icon
                Image(systemName: method.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color.accentColor : theme.colors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        (isSelected ? Color.accentColor : theme.colors.textSecondary)
                            .opacity(0.1)
                    )
                    .cornerRadius(theme.radius.sm)
                
                // Content
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(method.title)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(method == .email ? "Код на \(email)" : method.description)
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.accentColor : theme.colors.textTertiary)
                    .font(.system(size: 20))
            }
            .padding(theme.spacing.md)
            .background(theme.colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.card)
                    .stroke(
                        isSelected ? Color.accentColor : theme.colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .cornerRadius(theme.radius.card)
            .animation(theme.motion.easing.standard, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CodeEntryView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var timeRemaining = 300 // 5 minutes
    @State private var canResend = false
    
    let method: TwoFactorMethod
    let email: String
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.xl) {
                // Header
                VStack(spacing: theme.spacing.lg) {
                    Image(systemName: method.icon)
                        .font(.system(size: 64))
                        .foregroundColor(Color.accentColor)
                    
                    VStack(spacing: theme.spacing.sm) {
                        Text("Введите код")
                            .textStyle(.headlineLarge)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Text(getInstructionText())
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Code input
                VStack(spacing: theme.spacing.md) {
                    SkyOTPField(
                        code: $code,
                        length: 6
                    )
                    
                    if showError {
                        Text(errorMessage)
                            .textStyle(.caption)
                            .foregroundColor(theme.colors.error)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Timer and resend
                if method == .email {
                    VStack(spacing: theme.spacing.sm) {
                        Text(getTimerText())
                            .textStyle(.bodySmall)
                            .foregroundColor(theme.colors.textSecondary)
                        
                        if canResend {
                            Button("Отправить код повторно") {
                                resendCode()
                            }
                            .buttonStyle(.tertiary)
                        }
                    }
                }
                
                Spacer()
                
                // Verify button
                Button {
                    verifyCode()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Подтвердить")
                        }
                    }
                }
                .buttonStyle(.primary)
                .disabled(code.count != 6 || isLoading)
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle(method.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Назад") {
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
        .onChange(of: code) { newValue in
            if newValue.count == 6 {
                hideError()
            }
        }
    }
    
    private func getInstructionText() -> String {
        switch method {
        case .email:
            return "Введите 6-значный код, отправленный на \(email)"
        case .totp:
            return "Введите 6-значный код из вашего приложения Authenticator"
        }
    }
    
    private func getTimerText() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return "Код действителен \(minutes):\(String(format: "%02d", seconds))"
    }
    
    private func verifyCode() {
        hideError()
        isLoading = true
        
        // Simulate API verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // Simulate different outcomes
            if code == "123456" {
                // Success - would navigate to main app
                dismiss()
            } else {
                showError(message: "Неверный код. Попробуйте еще раз.")
                code = ""
            }
        }
    }
    
    private func resendCode() {
        canResend = false
        timeRemaining = 300
        
        // Show success feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func hideError() {
        showError = false
        errorMessage = ""
    }
}

#Preview("Method Selection") {
    ThemeProvider {
        TwoFactorAuthView(email: "user@example.com")
    }
}

#Preview("Code Entry - Email") {
    ThemeProvider {
        CodeEntryView(method: .email, email: "user@example.com")
    }
}

#Preview("Code Entry - TOTP") {
    ThemeProvider {
        CodeEntryView(method: .totp, email: "user@example.com")
    }
}
