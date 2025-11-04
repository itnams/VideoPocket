//
//  SettingsView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        Button(action: {
                            languageManager.currentLanguage = language
                        }) {
                            HStack {
                                Text(language.flag)
                                    .font(.title2)
                                
                                Text(language.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if languageManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("language".localized)
                } footer: {
                    Text("select_language".localized)
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

