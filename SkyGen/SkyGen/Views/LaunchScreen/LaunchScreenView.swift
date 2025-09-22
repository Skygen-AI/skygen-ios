//
//  LaunchScreenView.swift
//  SkyGen
//
//  Launch screen with app branding
//

import SwiftUI

struct LaunchScreenView: View {
    @Environment(\.theme) private var theme
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background
            theme.colors.background
                .ignoresSafeArea()
            
            VStack(spacing: theme.spacing.xl) {
                Spacer()
                
                // Logo
                VStack(spacing: theme.spacing.lg) {
                    // App Icon
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        // Lightning bolt icon
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(Color.accentColor)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // App Name
                    VStack(spacing: theme.spacing.xs) {
                        Text("SkyGen")
                            .textStyle(.displayMedium)
                            .foregroundColor(theme.colors.textPrimary)
                            .opacity(textOpacity)
                        
                        Text("AI Assistant")
                            .textStyle(.titleMedium)
                            .foregroundColor(theme.colors.textSecondary)
                            .opacity(textOpacity)
                    }
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: theme.spacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                        .scaleEffect(1.2)
                        .opacity(textOpacity)
                    
                    Text("Загрузка...")
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textTertiary)
                        .opacity(textOpacity)
                }
                .padding(.bottom, theme.spacing.xxxl)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo scale and fade in
        withAnimation(.easeOut(duration: 0.8)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text fade in with delay
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            textOpacity = 1.0
        }
        
        // Add subtle breathing animation to logo
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
            .delay(1.0)
        ) {
            isAnimating = true
        }
    }
}

// MARK: - App Logo Component
struct AppLogo: View {
    @Environment(\.theme) private var theme
    let size: CGFloat
    var showBackground: Bool = true
    
    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: size, height: size)
            }
            
            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(Color.accentColor)
        }
    }
}

// MARK: - Branded App Icon for Navigation
struct SkyGenIcon: View {
    @Environment(\.theme) private var theme
    let size: CGFloat
    
    init(_ size: CGFloat = 24) {
        self.size = size
    }
    
    var body: some View {
        AppLogo(size: size, showBackground: false)
    }
}

#Preview {
    ThemeProvider {
        LaunchScreenView()
    }
}
