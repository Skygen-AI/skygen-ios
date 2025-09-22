//
//  SignInView.swift
//  SkyGen
//
//  Sign in screen with magic link authentication
//

import SwiftUI

struct SignInView: View {
    @Environment(\.theme) private var theme
    @State private var email = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showMagicLinkSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: theme.spacing.lg) {
                    Spacer()
                    
                    // Logo placeholder
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.accentColor)
                    
                    VStack(spacing: theme.spacing.sm) {
                        Text("SkyGen")
                            .textStyle(.displayMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Text("Ваш AI-помощник для управления устройствами")
                            .textStyle(.bodyLarge)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                
                // Sign In Form
                VStack(spacing: theme.spacing.lg) {
                    VStack(spacing: theme.spacing.md) {
                        SkyTextField(
                            title: "",
                            text: $email,
                            placeholder: "Введите ваш email",
                            keyboardType: .emailAddress,
                            autocapitalization: .never,
                            isError: showError && !errorMessage.isEmpty,
                            errorMessage: showError ? errorMessage : nil
                        )
                        
                        Button {
                            signInWithMagicLink()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Войти")
                                }
                            }
                        }
                        .buttonStyle(.primary)
                        .disabled(isLoading || email.isEmpty)
                    }
                    
                    // Terms and Privacy
                    VStack(spacing: theme.spacing.xs) {
                        Text("Продолжая, вы соглашаетесь с")
                            .textStyle(.caption)
                            .foregroundColor(theme.colors.textTertiary)
                        
                        HStack(spacing: 4) {
                            Button("Условиями использования") {
                                // TODO: Show terms
                            }
                            .buttonStyle(.tertiary)
                            .font(theme.typography.caption)
                            
                            Text("и")
                                .textStyle(.caption)
                                .foregroundColor(theme.colors.textTertiary)
                            
                            Button("Политикой конфиденциальности") {
                                // TODO: Show privacy policy
                            }
                            .buttonStyle(.tertiary)
                            .font(theme.typography.caption)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.screenPadding)
            }
            .background(theme.colors.background)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $showMagicLinkSent) {
            MagicLinkSentView(email: email)
        }
    }
    
    private func signInWithMagicLink() {
        guard isValidEmail(email) else {
            showError(message: "Введите корректный email адрес")
            return
        }
        
        hideError()
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // In real app, this would call the backend
            showMagicLinkSent = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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

#Preview {
    ThemeProvider {
        SignInView()
    }
}
