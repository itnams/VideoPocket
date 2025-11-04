//
//  VideoPlayerView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI
import AVKit
import AVFoundation
import CoreMedia
import Combine

@MainActor
class VideoPlayerViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var player: AVPlayer?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadVideo(url: URL) {
        isLoading = true
        hasError = false
        errorMessage = ""
        
        // Cấu hình AVAudioSession để đảm bảo audio hoạt động
        configureAudioSession()
        
        // Tạo AVPlayerItem trước với cấu hình tối ưu cho HEVC
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Cấu hình để hỗ trợ tốt hơn cho các codec mới
        playerItem.preferredForwardBufferDuration = 5.0
        
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer
        
        // Log thông tin về video để debug (sử dụng API mới)
        Task { @MainActor in
            do {
                let tracks = try await asset.load(.tracks)
                var videoInfo: [String] = []
                
                for track in tracks {
                    if track.mediaType == .video {
                        videoInfo.append("Video track: \(track.mediaType.rawValue)")
                        
                        // Load format descriptions
                        let formatDescriptions = try await track.load(.formatDescriptions)
                        if let formatDescription = formatDescriptions.first {
                            let desc = formatDescription
                            let codecType = CMFormatDescriptionGetMediaSubType(desc)
                            let codecString = String(format: "%c%c%c%c", 
                                                     (codecType >> 24) & 0xFF,
                                                     (codecType >> 16) & 0xFF,
                                                     (codecType >> 8) & 0xFF,
                                                     codecType & 0xFF)
                            videoInfo.append("Codec: \(codecString)")
                        }
                    }
                }
                
                if !videoInfo.isEmpty {
                    print("Video Info: \(videoInfo.joined(separator: ", "))")
                }
            } catch {
                // Bỏ qua lỗi khi load metadata, không ảnh hưởng đến phát video
                print("Could not load video metadata: \(error.localizedDescription)")
            }
        }
        
        // Kiểm tra trạng thái của player item
        // Sử dụng Combine để theo dõi trạng thái
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    self.isLoading = false
                    self.hasError = false
                case .failed:
                    self.hasError = true
                    let error = playerItem.error
                    self.errorMessage = self.formatErrorMessage(error)
                    self.isLoading = false
                case .unknown:
                    // Vẫn hiển thị player, chỉ đợi status thay đổi
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Kiểm tra trạng thái ban đầu (nếu đã sẵn sàng)
        if playerItem.status == .readyToPlay {
            isLoading = false
        } else if playerItem.status == .failed {
            hasError = true
            errorMessage = formatErrorMessage(playerItem.error)
            isLoading = false
        }
        
        // Timeout sau 15 giây nếu không load được
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            guard let self = self else { return }
            if self.isLoading {
                self.hasError = true
                self.errorMessage = "Video tải quá lâu. Vui lòng kiểm tra kết nối mạng hoặc URL."
                self.isLoading = false
            }
        }
        
        // Lắng nghe lỗi phát
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                    self.errorMessage = self.formatErrorMessage(error)
                    self.hasError = true
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        // Lắng nghe lỗi khi phát lại
        NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // Chỉ hiển thị cảnh báo, không coi như lỗi
                print("Video playback stalled - buffering...")
            }
            .store(in: &cancellables)
    }
    
    private func formatErrorMessage(_ error: Error?) -> String {
        guard let error = error as NSError? else {
            return "error_loading".localized
        }
        
        let errorCode = error.code
        
        // Xử lý các lỗi phổ biến
        switch errorCode {
        case -12864: // kCMFormatDescriptionError_InvalidParameter
            return "unsupported_format".localized
        case -11819: // AVErrorUnknown
            return "Lỗi không xác định khi tải video."
        case -11800: // AVErrorMediaServicesWereReset
            return "Dịch vụ media bị reset. Vui lòng thử lại."
        case -11801: // AVErrorFileFailed
            return "Không thể mở file video. Vui lòng kiểm tra URL."
        case -11802: // AVErrorServerClock
            return "Lỗi đồng bộ server. Vui lòng thử lại."
        case -11850: // AVErrorFormatNotSupported
            return "Định dạng video không được hỗ trợ trên thiết bị này."
        case -11852: // AVErrorDecodeFailed
            return "Không thể giải mã video. Codec không được hỗ trợ."
        case -11853: // AVErrorInvalidSourceFormat
            return "Định dạng nguồn không hợp lệ."
        case -1009: // NSURLErrorNotConnectedToInternet
            return "Không có kết nối internet. Vui lòng kiểm tra mạng."
        case -1001: // NSURLErrorTimedOut
            return "Kết nối quá thời gian. Vui lòng thử lại."
        case -1003: // NSURLErrorCannotFindHost
            return "Không tìm thấy máy chủ. Vui lòng kiểm tra URL."
        case -1004: // NSURLErrorCannotConnectToHost
            return "Không thể kết nối đến máy chủ."
        case 403:
            return "Không có quyền truy cập video này. Server từ chối yêu cầu."
        case 404:
            return "Không tìm thấy video tại URL này."
        default:
            // Thử lấy thông báo lỗi từ hệ thống
            let localizedDescription = error.localizedDescription
            if !localizedDescription.isEmpty {
                return localizedDescription
            }
            return "Lỗi code: \(errorCode). \(error.localizedFailureReason ?? "Vui lòng thử lại hoặc kiểm tra URL video.")"
        }
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Cấu hình category để phát video với audio
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.allowBluetoothA2DP])
            
            // Kích hoạt audio session
            try audioSession.setActive(true)
            
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}

struct VideoPlayerView: View {
    let video: Video
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VideoPlayerViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let player = viewModel.player, !viewModel.hasError {
                    VideoPlayer(player: player)
                        .ignoresSafeArea(.all, edges: .all)
                        .onAppear {
                            // Đảm bảo audio session được cấu hình trước khi phát
                            configureAudioSessionForPlayback()
                            player.play()
                        }
                        .onDisappear {
                            player.pause()
                        }
                        .overlay {
                            if viewModel.isLoading {
                                ZStack {
                                    Color.black.opacity(0.7)
                                    VStack(spacing: 20) {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .tint(.white)
                                        Text("loading_video".localized)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                } else if viewModel.hasError {
                    ScrollView {
                        errorView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("loading_video".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(video.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        viewModel.player?.pause()
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Cấu hình audio session ngay khi view xuất hiện
                configureAudioSessionForPlayback()
                
                if let url = video.url {
                    viewModel.loadVideo(url: url)
                } else {
                    viewModel.hasError = true
                    viewModel.isLoading = false
                }
            }
            .onDisappear {
                // Giữ audio session active khi đóng view
                // (không deactivate để tránh mất audio khi chuyển view)
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("error_loading".localized)
                .font(.title2)
                .fontWeight(.semibold)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Text(video.urlString)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .textSelection(.enabled)
            
            Button("tap_to_retry".localized) {
                if let url = video.url {
                    viewModel.loadVideo(url: url)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private func configureAudioSessionForPlayback() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Cấu hình category để phát video với audio
            // .playback cho phép phát audio ngay cả khi thiết bị ở chế độ silent
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.allowBluetoothA2DP])
            
            // Kích hoạt audio session
            try audioSession.setActive(true)
            
            print("Audio session configured for playback")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}

