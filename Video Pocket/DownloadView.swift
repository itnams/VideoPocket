//
//  DownloadView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI
import UIKit

struct DownloadView: View {
    let video: Video
    @Environment(\.dismiss) var dismiss
    @StateObject private var downloadManager = DownloadManager.shared
    @State private var showingSuccess = false
    @State private var downloadedURL: URL?
    @State private var errorMessage: String?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if downloadManager.isDownloading {
                    // Hiển thị progress
                    VStack(spacing: 20) {
                        ProgressView(value: downloadManager.downloadProgress) {
                            HStack {
                                Text("downloading".localized)
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(downloadManager.downloadProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        
                        if let fileName = downloadManager.currentDownload {
                            Text(fileName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding()
                } else if showingSuccess, let downloadedURL = downloadedURL {
                    // Hiển thị thành công
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("download_complete".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            Text(downloadedURL.lastPathComponent)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("saved_in".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                showingShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("open_files".localized)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                } else if let errorMessage = errorMessage {
                    // Hiển thị lỗi
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("download_failed".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    // Hiển thị options
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("download_video".localized)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(video.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            // Tải video
                            Button(action: {
                                downloadVideo(type: .video)
                            }) {
                                HStack {
                                    Image(systemName: "video.fill")
                                        .font(.title3)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("download_full".localized)
                                            .fontWeight(.semibold)
                                        Text("Video và âm thanh")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("download_video".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let downloadedURL = downloadedURL {
                    ShareSheet(items: [downloadedURL])
                }
            }
        }
    }
    
    private func downloadVideo(type: DownloadType) {
        guard let url = video.url else {
            errorMessage = "invalid_url".localized
            return
        }
        
        // Kiểm tra nếu là YouTube
        if YouTubeHelper.isYouTubeURL(video.urlString) {
            errorMessage = "Không thể tải video YouTube trực tiếp. Vui lòng sử dụng ứng dụng YouTube hoặc công cụ khác."
            return
        }
        
        downloadManager.downloadVideo(url: url, type: type) { result in
            switch result {
            case .success(let fileURL):
                downloadedURL = fileURL
                showingSuccess = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// SwiftUI wrapper cho UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Cấu hình cho iPad
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topController.view
                popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Không cần update
    }
}

