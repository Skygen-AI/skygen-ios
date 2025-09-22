//
//  RootView.swift
//  SkyGen
//
//  Root view that manages authentication state
//

import SwiftUI

struct RootView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var onboardingManager = OnboardingManager()
    @Environment(\.theme) private var theme
    @State private var showWelcome = true
    
    var body: some View {
        Group {
            if showWelcome {
                WelcomeView(onGetStarted: {
                    withAnimation(theme.motion.easing.emphasized) {
                        showWelcome = false
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .leading)
                ))
            } else {
                switch authManager.authState {
                case .unauthenticated:
                    SignInView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                case .authenticating:
                    SkyLoadingState(message: "Вход в систему...")
                        .transition(.opacity)
                    
                case .authenticated:
                    if authManager.needsBiometricAuth {
                        BiometricAuthView()
                            .transition(.opacity)
                    } else if !onboardingManager.isOnboardingCompleted {
                        OnboardingView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                            .environmentObject(onboardingManager)
                    } else {
                        MainTabView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    }
                }
            }
        }
        .animation(theme.motion.easing.emphasized, value: showWelcome)
        .animation(theme.motion.easing.emphasized, value: authManager.authState)
        .animation(theme.motion.easing.standard, value: authManager.needsBiometricAuth)
        .animation(theme.motion.easing.emphasized, value: onboardingManager.isOnboardingCompleted)
        .environmentObject(authManager)
        .environmentObject(onboardingManager)
    }
}

struct BiometricAuthView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: theme.spacing.xl) {
            Spacer()
            
            // Biometric icon
            Image(systemName: "faceid")
                .font(.system(size: 80))
                .foregroundColor(Color.accentColor)
            
            VStack(spacing: theme.spacing.sm) {
                Text("App Lock")
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Используйте Face ID для разблокировки приложения")
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if showError {
                Text(errorMessage)
                    .textStyle(.bodySmall)
                    .foregroundColor(theme.colors.error)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: theme.spacing.md) {
                Button {
                    authenticateWithBiometrics()
                } label: {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "faceid")
                            Text("Разблокировать")
                        }
                    }
                }
                .buttonStyle(.primary)
                .disabled(isAuthenticating)
                
                Button("Выйти из аккаунта") {
                    authManager.signOut()
                }
                .buttonStyle(.tertiary)
            }
        }
        .padding(theme.spacing.screenPadding)
        .background(theme.colors.background)
        .onAppear {
            // Auto-trigger biometric auth on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authenticateWithBiometrics()
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        guard !isAuthenticating else { return }
        
        hideError()
        isAuthenticating = true
        
        Task {
            do {
                try await authManager.authenticateWithBiometrics()
            } catch {
                await MainActor.run {
                    showError(message: error.localizedDescription)
                }
            }
            
            await MainActor.run {
                isAuthenticating = false
            }
        }
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
        RootView()
    }
}
