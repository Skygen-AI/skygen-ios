//
//  WelcomeView.swift
//  SkyGen
//
//  Welcome screen with app introduction
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ZStack {
            // Background
            theme.colors.background
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Welcome content
                VStack(spacing: theme.spacing.lg) {
                    // Welcome icon from assets
                    Image("WelcomeIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.black.opacity(0.6), radius: 60, x: 10, y: 25)
                    
                    // Welcome text
                    VStack(spacing: theme.spacing.xs) {
                        Text("Welcome to")
                            .textStyle(.titleLarge)
                            .foregroundColor(theme.colors.textSecondary)
                        
                        Text("SkyGen")
                            .textStyle(.displayLarge)
                            .foregroundColor(theme.colors.textPrimary)
                    }
                    .padding(.top, 40)
                }
                
                Spacer()
                
                // Login button
                Button("Get Started") {
                    // TODO: Navigate to login
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.screenPadding)
                
            }
        }
    }
}

#Preview {
    ThemeProvider {
        WelcomeView()
    }
}
