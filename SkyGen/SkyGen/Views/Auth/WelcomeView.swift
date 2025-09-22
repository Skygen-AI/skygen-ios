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
            
            // Decorative animated lines
            AnimatedLinesBackground()
                .scaleEffect(1.5)
                .rotationEffect(.degrees(-30))
                .offset(x: 20, y: -85)
            
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

// MARK: - Animated Lines Background Component
struct AnimatedLinesBackground: View {
    @Environment(\.theme) private var theme
    @State private var lineOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let lineSpacing: CGFloat = screenHeight / 14 // 14 линий на экран
            
            ForEach(0..<20, id: \.self) { index in
                AnimatedLine(
                    isEven: index % 2 == 0,
                    offset: lineOffset,
                    screenWidth: screenWidth
                )
                .position(
                    x: screenWidth / 2,
                    y: CGFloat(index) * lineSpacing + lineSpacing / 2
                )
            }
        }
        .onAppear {
            // Первый шаг: устанавливаем начальное значение
            lineOffset = -750
            
            // Первый шаг: от -750 до 250 за 7 секунд
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 5)) {
                    lineOffset = 250
                }
                
                // Второй шаг: циклическая анимация от 250 до -300 и обратно
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                    withAnimation(.easeInOut(duration: 25).repeatForever(autoreverses: true)) {
                        lineOffset = -300
                    }
                }
            }
        }
        
    }
}

// MARK: - Single Animated Line Component
struct AnimatedLine: View {
    let isEven: Bool
    let offset: CGFloat
    let screenWidth: CGFloat
    @Environment(\.theme) private var theme
    
    private let deviceIcons = [
        "iphone", "ipad", "macbook", "applewatch", "appletv",
        "airpods", "homepod", "camera", "display", "keyboard",
        "gamecontroller", "printer", "tv", "router", "cpu",
        "mouse", "headphones", "speaker.wave.3", "externaldrive", "internaldrive",
        "memorychip", "battery.100", "powercord", "cable.connector", "antenna.radiowaves.left.and.right",
        "iphone.gen1", "ipad.gen1", "macbook.gen1", "imac", "mac.studio",
        "airpods.pro", "beats.headphones", "ipod", "apple.logo", "finder",
        "safari", "mail", "messages", "facetime", "phone", "photos",
        "music", "app.store", "network", "wifi", "airtag", "scanner"
    ]
    
    // Создаем рандомный массив иконок для каждой линии
    @State private var randomizedIcons: [String] = []
    
    var body: some View {
        let xOffset = isEven ? -offset : offset
        
        return ZStack {
            // Первая копия линии
            createIconLine()
                .offset(x: xOffset)
            
            // Вторая копия для непрерывности
            createIconLine()
                .offset(
                    x: xOffset + (isEven ? screenWidth * 3.0 : -screenWidth * 3.0)
                )
            
            // Третья копия для непрерывности
            createIconLine()
                .offset(
                    x: xOffset + (isEven ? screenWidth * 6.0 : -screenWidth * 6.0)
                )
        }
        .opacity(0.2)
        .clipped()
        .onAppear {
            // Создаем уникальный рандомный массив иконок без дубликатов
            var shuffledIcons = deviceIcons.shuffled()
            
            // Если нужно больше иконок чем есть в пуле, дублируем массив
            while shuffledIcons.count < 30 {
                shuffledIcons += deviceIcons.shuffled()
            }
            
            // Берем первые 30 уникальных иконок
            randomizedIcons = Array(shuffledIcons.prefix(30))
        }
    }
    
    private func createIconLine() -> some View {
        HStack(spacing: 10) {
            ForEach(0..<30, id: \.self) { iconIndex in
                if !randomizedIcons.isEmpty {
                    Image(systemName: randomizedIcons[iconIndex % randomizedIcons.count])
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundColor(theme.colors.textTertiary.opacity(0.8))
                }
            }
        }
    }
}

#Preview {
    ThemeProvider {
        WelcomeView()
    }
}
