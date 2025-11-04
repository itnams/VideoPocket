//
//  YouTubePlayerView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI
import AVKit
import WebKit

struct YouTubePlayerView: View {
    let video: Video
    @Environment(\.dismiss) var dismiss
    @State private var videoID: String?
    @State private var showingOpenOptions = false
    @State private var playMode: PlayMode = .options
    
    enum PlayMode {
        case options
        case webView
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if playMode == .webView, let videoID = videoID {
                    YouTubeWebView(videoID: videoID)
                        .navigationTitle(video.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("close".localized) {
                                    dismiss()
                                }
                            }
                        }
                } else {
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        
                        Text("youtube_video".localized)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Video này là link YouTube. YouTube không cho phép phát trực tiếp video qua AVPlayer vì DRM. Bạn có thể:")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    
                        VStack(spacing: 15) {
                            // Phát trong app (WebView)
                            if let videoID = videoID {
                                Button(action: {
                                    playMode = .webView
                                }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title3)
                                        Text("play_in_app".localized)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Mở trong YouTube app
                            if let videoID = videoID,
                               let youtubeURL = YouTubeHelper.createYouTubeAppURL(videoID: videoID),
                               UIApplication.shared.canOpenURL(youtubeURL) {
                                Button(action: {
                                    openInYouTubeApp(videoID: videoID)
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.right.square.fill")
                                            .font(.title3)
                                        Text("open_youtube".localized)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Mở trong Safari
                            if let videoID = videoID,
                               let webURL = YouTubeHelper.createYouTubeWebURL(videoID: videoID) {
                                Button(action: {
                                    openInBrowser(url: webURL)
                                }) {
                                    HStack {
                                        Image(systemName: "safari.fill")
                                            .font(.title3)
                                        Text("open_safari".localized)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    
                        Spacer()
                        
                        // Hiển thị video ID
                        if let videoID = videoID {
                            Text("Video ID: \(videoID)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .navigationTitle(video.title)
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
            .onAppear {
                videoID = YouTubeHelper.extractVideoID(from: video.urlString)
            }
        }
    }
    
    func openInYouTubeApp(videoID: String) {
        if let youtubeURL = YouTubeHelper.createYouTubeAppURL(videoID: videoID) {
            if UIApplication.shared.canOpenURL(youtubeURL) {
                UIApplication.shared.open(youtubeURL)
            } else {
                // Fallback to web if app not available
                if let webURL = YouTubeHelper.createYouTubeWebURL(videoID: videoID) {
                    openInBrowser(url: webURL)
                }
            }
        }
    }
    
    func openInBrowser(url: URL) {
        UIApplication.shared.open(url)
    }
}

// WebView để embed YouTube player
struct YouTubeWebView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background-color: black;
                }
                .video-container {
                    position: relative;
                    width: 100%;
                    height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }
                iframe {
                    width: 100%;
                    height: 100%;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe
                    src="https://www.youtube.com/embed/\(videoID)?playsinline=1&autoplay=1"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("YouTube WebView loaded successfully")
        }
    }
}

