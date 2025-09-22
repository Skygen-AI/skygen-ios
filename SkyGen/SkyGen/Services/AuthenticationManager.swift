//
//  AuthenticationManager.swift
//  SkyGen
//
//  Authentication state management
//

import SwiftUI
import Combine

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var authState: AuthenticationState = .unauthenticated
    @Published var currentUser: User?
    @Published var isAppLockEnabled = false
    @Published var needsBiometricAuth = false
    
    private let userDefaultsKey = "com.skygen.isAuthenticated"
    private let biometricKey = "com.skygen.biometricAuth"
    
    init() {
        // Check if user was previously authenticated
        if UserDefaults.standard.bool(forKey: userDefaultsKey) {
            // In a real app, you'd verify the token here
            authState = .authenticated
            loadMockUser()
        }
        
        // Check biometric setting
        isAppLockEnabled = UserDefaults.standard.bool(forKey: biometricKey)
        
        // If biometric is enabled and user is authenticated, require biometric auth
        if isAppLockEnabled && authState == .authenticated {
            needsBiometricAuth = true
        }
    }
    
    func signIn(email: String) async throws {
        authState = .authenticating
        
        // Simulate API call
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // In a real app, this would make an actual API call
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
        authState = .authenticated
        loadMockUser()
    }
    
    func verifyMagicLink(token: String) async throws {
        authState = .authenticating
        
        // Simulate verification
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
        authState = .authenticated
        loadMockUser()
    }
    
    func verifyTwoFactor(code: String, method: TwoFactorMethod) async throws {
        // Simulate 2FA verification
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // In a real app, verify the code with backend
        if code == "123456" {
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
            authState = .authenticated
            loadMockUser()
        } else {
            throw AuthenticationError.invalidCode
        }
    }
    
    func signOut() {
        authState = .unauthenticated
        currentUser = nil
        needsBiometricAuth = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func enableAppLock() {
        isAppLockEnabled = true
        UserDefaults.standard.set(true, forKey: biometricKey)
    }
    
    func disableAppLock() {
        isAppLockEnabled = false
        needsBiometricAuth = false
        UserDefaults.standard.set(false, forKey: biometricKey)
    }
    
    func authenticateWithBiometrics() async throws {
        // In a real app, this would use LocalAuthentication framework
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        needsBiometricAuth = false
    }
    
    private func loadMockUser() {
        currentUser = User(
            id: "mock-user-id",
            email: "user@example.com",
            name: "John Doe",
            avatar: nil
        )
    }
}

struct User {
    let id: String
    let email: String
    let name: String
    let avatar: String?
}

enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case invalidCode
    case networkError
    case biometricAuthFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неверные учетные данные"
        case .invalidCode:
            return "Неверный код подтверждения"
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету"
        case .biometricAuthFailed:
            return "Не удалось выполнить биометрическую аутентификацию"
        }
    }
}
