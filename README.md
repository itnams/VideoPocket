# Video Pocket

Video Pocket là ứng dụng quản lý và xem video miễn phí, giúp bạn lưu trữ, xem và tải video một cách dễ dàng.

**Video Pocket - Your Smart Video Collection**

Video Pocket is a completely free video management and viewing app that helps you store, watch, and download videos easily.

## Tính năng chính / Key Features

### Xem Video Từ Mọi Nguồn / Watch Videos From Any Source
- Xem video trực tiếp từ URL bất kỳ
- Hỗ trợ đầy đủ các định dạng video phổ biến
- Phát video mượt mà với chất lượng cao
- Watch videos directly from any URL
- Full support for popular video formats
- Smooth playback with high quality

### Quản Lý Video Dễ Dàng / Easy Video Management
- Lưu trữ video yêu thích dưới dạng URL
- Tự động tạo thumbnail cho mỗi video
- Cache thumbnail thông minh để tải nhanh hơn
- Giao diện đẹp mắt, dễ sử dụng
- Store favorite videos as URLs
- Automatic thumbnail generation for each video
- Smart thumbnail caching for faster loading
- Beautiful, user-friendly interface

### Tải Video / Download Videos
- Tải video về máy để xem offline
- Theo dõi tiến trình tải với thanh progress
- Dễ dàng chia sẻ file đã tải
- Download videos to your device for offline viewing
- Track download progress with progress bar
- Easily share downloaded files

### Đa Ngôn Ngữ / Multilingual
- Hỗ trợ Tiếng Việt và Tiếng Anh
- Chọn ngôn ngữ ngay khi mở app lần đầu
- Tất cả giao diện đều được dịch đầy đủ
- Supports Vietnamese and English
- Choose language on first launch
- All interfaces fully translated

### Giao Diện Đẹp Mắt / Beautiful Interface
- Splash screen với animation mượt mà
- Thiết kế hiện đại, thân thiện với người dùng
- Tối ưu cho mọi kích thước màn hình
- Smooth animated splash screen
- Modern, user-friendly design
- Optimized for all screen sizes

## Yêu cầu hệ thống / System Requirements

- iOS 16.0 trở lên
- Xcode 15.0 trở lên (để phát triển)
- Swift 5.9+

## Cài đặt / Installation

### Yêu cầu / Requirements
- macOS với Xcode
- iOS device hoặc Simulator

### Các bước cài đặt / Steps

1. **Clone repository:**
```bash
git clone <repository-url>
cd "Video Pocket"
```

2. **Mở project trong Xcode:**
```bash
open "Video Pocket.xcodeproj"
```

3. **Cấu hình Signing & Capabilities:**
   - Mở project trong Xcode
   - Chọn target "Video Pocket"
   - Vào tab "Signing & Capabilities"
   - Chọn Team của bạn
   - Xcode sẽ tự động quản lý provisioning profile

4. **Build và chạy:**
   - Chọn device hoặc simulator
   - Nhấn Cmd + R để build và chạy

## Cấu trúc dự án / Project Structure

```
Video Pocket/
├── Video Pocket/
│   ├── Video_PocketApp.swift          # Entry point của app
│   ├── ContentView.swift              # Màn hình chính
│   ├── AddVideoView.swift              # Màn hình thêm video
│   ├── VideoPlayerView.swift           # Màn hình phát video
│   ├── YouTubePlayerView.swift         # Màn hình YouTube
│   ├── DownloadView.swift              # Màn hình tải video
│   ├── SettingsView.swift              # Màn hình cài đặt
│   ├── LanguageSelectionView.swift     # Màn hình chọn ngôn ngữ
│   ├── SplashView.swift                # Màn hình splash
│   ├── VideoThumbnailView.swift        # Component hiển thị thumbnail
│   ├── Video.swift                     # Model Video
│   ├── VideoStore.swift                # Quản lý danh sách video
│   ├── DownloadManager.swift           # Quản lý tải video
│   ├── LanguageManager.swift           # Quản lý ngôn ngữ
│   └── YouTubeHelper.swift             # Helper cho YouTube
└── README.md
```

## Công nghệ sử dụng / Technologies Used

- **SwiftUI**: Framework UI hiện đại của Apple
- **AVKit/AVFoundation**: Phát video và xử lý media
- **Combine**: Reactive programming
- **UserDefaults**: Lưu trữ dữ liệu local
- **URLSession**: Tải video và thumbnail
- **FileManager**: Quản lý file system
- **WKWebView**: Hiển thị YouTube videos

## Cách sử dụng / How to Use

### Thêm video / Add Video
1. Nhấn nút "+" ở góc trên bên phải
2. Nhập URL video và tiêu đề (tùy chọn)
3. Nhấn "Thêm" để lưu

### Xem video / Watch Video
1. Chọn video từ danh sách
2. Video sẽ tự động phát
3. Nhấn nút đóng để quay lại

### Tải video / Download Video
1. Nhấn nút download trên video (không phải YouTube)
2. Chọn "Tải toàn bộ video"
3. Theo dõi tiến trình tải
4. Nhấn "Mở Files / Chia sẻ" để truy cập file đã tải

### Thay đổi ngôn ngữ / Change Language
1. Nhấn nút Settings (⚙️) ở góc trên bên trái
2. Chọn ngôn ngữ mong muốn
3. App sẽ tự động cập nhật

## Tính năng kỹ thuật / Technical Features

- **Thumbnail Caching**: Cache thumbnail vào disk để tăng hiệu suất
- **Audio Session Configuration**: Cấu hình đúng để audio hoạt động trên device thật
- **Error Handling**: Xử lý lỗi chi tiết với thông báo rõ ràng
- **Progress Tracking**: Theo dõi tiến trình tải video real-time
- **Memory Management**: Quản lý memory hiệu quả với weak references

## Phát triển / Development

### Thêm tính năng mới
1. Tạo branch mới từ `main`
2. Phát triển tính năng
3. Test kỹ lưỡng
4. Tạo Pull Request

### Code Style
- Tuân thủ Swift Style Guide
- Sử dụng SwiftUI best practices
- Comment code khi cần thiết

## Giấy phép / License

Dự án này là mã nguồn mở và có sẵn dưới giấy phép MIT.

This project is open source and available under the MIT License.

## Người phát triển / Developer

Nam Nguyễn

## Đóng góp / Contributing

Mọi đóng góp đều được chào đón! Vui lòng tạo issue hoặc pull request.

Contributions are welcome! Please feel free to submit an issue or pull request.

## Lịch sử phiên bản / Version History

### Version 1.0.0
- Tính năng xem video từ URL
- Quản lý danh sách video
- Tải video về máy
- Hỗ trợ đa ngôn ngữ (Tiếng Việt, Tiếng Anh)
- Màn hình chọn ngôn ngữ khi mở app lần đầu
- Splash screen với animation
- Thumbnail caching

## Liên hệ / Contact

Nếu có câu hỏi hoặc đề xuất, vui lòng tạo issue trên GitHub.

If you have questions or suggestions, please create an issue on GitHub.

