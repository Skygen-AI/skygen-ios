//
//  AnimationExtensions.swift
//  SkyGen
//
//  Custom animations and transitions
//

import SwiftUI

// MARK: - Custom Animations
extension View {
    /// Gentle spring animation for interactive elements
    func gentleSpring() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
    }
    
    /// Quick bounce for button taps
    func quickBounce() -> Animation {
        .spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0)
    }
    
    /// Smooth ease for transitions
    func smoothEase() -> Animation {
        .easeInOut(duration: 0.3)
    }
    
    /// Pressable button animation
    func pressableButton() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.spring(response: 0.1, dampingFraction: 0.6), value: UUID())
    }
    
    /// Floating animation for cards
    func floatingCard(isPressed: Bool = false) -> some View {
        self
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
    }
    
    /// Shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.4),
                                Color.white.opacity(0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: isActive ? 200 : -200)
                    .animation(
                        Animation
                            .linear(duration: 1.2)
                            .repeatForever(autoreverses: false),
                        value: isActive
                    )
                    .clipped()
            )
    }
}

// MARK: - Loading Animations
struct LoadingDots: View {
    @State private var animationAmount = 0.0
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationAmount == Double(index) ? 1.3 : 0.8)
                    .opacity(animationAmount == Double(index) ? 1.0 : 0.6)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .onAppear {
            animationAmount = 2
        }
    }
}

struct PulsingIcon: View {
    @State private var isPulsing = false
    let icon: String
    let color: Color
    let size: CGFloat
    
    init(icon: String, color: Color = .blue, size: CGFloat = 24) {
        self.icon = icon
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size))
            .foregroundColor(color)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                Animation
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Transition Effects
struct SlideInTransition: ViewModifier {
    let isVisible: Bool
    let edge: Edge
    let distance: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? (isVisible ? 0 : -distance) : 
                   edge == .trailing ? (isVisible ? 0 : distance) : 0,
                y: edge == .top ? (isVisible ? 0 : -distance) : 
                   edge == .bottom ? (isVisible ? 0 : distance) : 0
            )
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
    }
}

extension View {
    func slideIn(isVisible: Bool, from edge: Edge = .bottom, distance: CGFloat = 100) -> some View {
        modifier(SlideInTransition(isVisible: isVisible, edge: edge, distance: distance))
    }
}

// MARK: - Interactive Feedback
struct HapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// MARK: - Button Styles with Animations
struct AnimatedButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    HapticFeedback.light()
                }
            }
    }
}

struct FloatingButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .shadow(
                color: Color.accentColor.opacity(configuration.isPressed ? 0.3 : 0.2),
                radius: configuration.isPressed ? 8 : 12,
                x: 0,
                y: configuration.isPressed ? 4 : 6
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    HapticFeedback.medium()
                }
            }
    }
}

// MARK: - Progress Animations
struct AnimatedProgressBar: View {
    @Environment(\.theme) private var theme
    let progress: Double
    let height: CGFloat
    let cornerRadius: CGFloat
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, height: CGFloat = 8, cornerRadius: CGFloat = 4) {
        self.progress = progress
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.colors.surface)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress, height: height)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newProgress in
            animatedProgress = newProgress
        }
    }
}

// MARK: - Tab Bar Animations
struct TabBarBadge: View {
    @Environment(\.theme) private var theme
    let count: Int
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .frame(minWidth: 18, minHeight: 18)
                .background(theme.colors.error)
                .clipShape(Circle())
                .scaleEffect(scale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
                .onAppear {
                    scale = 1.0
                }
        }
    }
}
