//
//  ContentView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var videoStore = VideoStore()
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showingAddVideo = false
    @State private var showingSettings = false
    @State private var selectedVideo: Video?
    @State private var videoToDownload: Video?
    
    var body: some View {
        NavigationStack {
            Group {
                if videoStore.videos.isEmpty {
                    emptyStateView
                } else {
                    videoListView
                }
            }
            .navigationTitle("app_name".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddVideo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAddVideo) {
                AddVideoView(videoStore: videoStore)
            }
            .fullScreenCover(item: $selectedVideo) { video in
                if YouTubeHelper.isYouTubeURL(video.urlString) {
                    YouTubePlayerView(video: video)
                } else {
                    VideoPlayerView(video: video)
                }
            }
            .sheet(item: $videoToDownload) { video in
                DownloadView(video: video)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("no_videos".localized)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("tap_to_add".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showingAddVideo = true
            } label: {
                Label("add_first_video".localized, systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var videoListView: some View {
        List {
            ForEach(videoStore.videos) { video in
                VideoRow(video: video) {
                    selectedVideo = video
                }
            }
            .onDelete(perform: videoStore.deleteVideo)
        }
        .listStyle(.plain)
    }
}

struct VideoRow: View {
    let video: Video
    let onTap: () -> Void
    
    private var isYouTube: Bool {
        YouTubeHelper.isYouTubeURL(video.urlString)
    }
    
    @State private var showingDownload = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                VideoThumbnailView(video: video)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        if isYouTube {
                            Image(systemName: "youtube.square.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                            Text("youtube_video".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(video.urlString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Text(video.dateAdded, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Nút download
                if !isYouTube {
                    Button(action: {
                        showingDownload = true
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDownload) {
            DownloadView(video: video)
        }
    }
}

#Preview {
    ContentView()
}
