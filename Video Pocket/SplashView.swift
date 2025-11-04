//
//  SplashView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI

struct SplashView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        Group {
            if !isActive {
                // Splash screen
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // App Icon/Logo
                        Image(systemName: "video.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .scaleEffect(size)
                            .opacity(opacity)
                        
                        // App Name
                        Text("Video Pocket")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(opacity)
                    }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                    
                    // Chuyển sang màn hình chính sau 2 giây
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            } else if !languageManager.hasSelectedLanguage {
                // Hiển thị màn hình chọn ngôn ngữ nếu chưa chọn
                LanguageSelectionView()
            } else {
                // Hiển thị màn hình chính
                ContentView()
            }
        }
    }
}

#Preview {
    SplashView()
}
