//
//  LanguageSelectionView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: AppLanguage = .vietnamese
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon
                Image(systemName: "video.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // Title - Hiển thị cả 2 ngôn ngữ vì chưa chọn
                VStack(spacing: 12) {
                    Text("Chọn ngôn ngữ / Select Language")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Vui lòng chọn ngôn ngữ của bạn\nPlease select your language")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Language Options
                VStack(spacing: 20) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        LanguageOptionCard(
                            language: language,
                            isSelected: selectedLanguage == language
                        ) {
                            selectedLanguage = language
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Continue Button - Hiển thị cả 2 ngôn ngữ
                Button(action: {
                    languageManager.currentLanguage = selectedLanguage
                }) {
                    HStack {
                        Text(selectedLanguage == .vietnamese ? "Tiếp tục" : "Continue")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct LanguageOptionCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 40))
                
                // Language Name
                Text(language.displayName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Checkmark if selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguageSelectionView()
}

