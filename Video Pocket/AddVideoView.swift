//
//  AddVideoView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI

struct AddVideoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var videoStore: VideoStore
    
    @State private var urlString: String = ""
    @State private var title: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("video_title".localized, text: $title)
                        .submitLabel(.next)
                    TextField("video_url".localized, text: $urlString)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            if !urlString.isEmpty {
                                addVideo()
                            }
                        }
                }
                
                Section {
                    Button(action: addVideo) {
                        HStack {
                            Spacer()
                            Text("add".localized)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(urlString.isEmpty)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("add_video".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
            }
            .alert("error_loading".localized, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addVideo() {
        guard !urlString.isEmpty else { return }
        
        // Làm sạch và chuẩn hóa URL
        var cleanedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Tự động thêm http:// hoặc https:// nếu thiếu
        if !cleanedURL.hasPrefix("http://") && !cleanedURL.hasPrefix("https://") {
            cleanedURL = "https://" + cleanedURL
        }
        
        // Validate URL
        guard URL(string: cleanedURL) != nil else {
            errorMessage = "invalid_url".localized
            showError = true
            return
        }
        
        videoStore.addVideo(urlString: cleanedURL, title: title.isEmpty ? cleanedURL : title)
        dismiss()
    }
}

