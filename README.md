# Kioku - Nhật ký cá nhân với trợ lý AI

**Kioku** (記憶 - tiếng Nhật nghĩa là "ký ức") là ứng dụng ghi nhật ký kết hợp trí tuệ nhân tạo, giúp bạn phản chiếu suy nghĩ và khám phá các mối liên hệ trong cuộc sống.

## 🎯 Tại sao cần Kioku?

Bạn có bao giờ:
- Viết nhật ký nhưng **quên mất những gì đã viết** trước đây?
- Muốn **nhìn lại quá khứ** để hiểu rõ hơn về bản thân?
- Cần **AI trò chuyện thông minh** về cuộc sống của chính bạn, không phải câu hỏi chung chung?
- Lo lắng về **quyền riêng tư** khi sử dụng ứng dụng nhật ký online?

Kioku giải quyết những vấn đề này bằng cách:
- ✅ Lưu trữ **100% dữ liệu trên máy** của bạn (không cloud, không server)
- ✅ AI **đọc và hiểu toàn bộ nhật ký** để trò chuyện có ngữ cảnh
- ✅ **Tự động phát hiện** người, địa điểm, sự kiện quan trọng trong cuộc sống bạn
- ✅ **Xuất/nhập dữ liệu** dễ dàng - bạn luôn sở hữu 100% dữ liệu của mình

## ✨ Tính năng

### 📝 Ghi nhật ký thông minh
- Lịch trực quan theo ngày/tháng/năm
- Ghi chú nhanh với giao diện đơn giản
- Tự động lưu, không lo mất dữ liệu

### 🤖 Trò chuyện với AI về cuộc sống bạn
- AI đọc nhật ký và **trả lời câu hỏi cá nhân hóa**
- "Em có nhớ lần trước tôi gặp Minh không?" → AI trích dẫn đúng ngày, đúng ngữ cảnh
- AI phát hiện **xu hướng, mối liên hệ** trong cuộc sống bạn
- **Minh bạch**: Bạn thấy rõ AI đọc những nhật ký nào để trả lời

### 🧠 Kiến thức từ nhật ký
- Tự động nhận diện **người, địa điểm, sự kiện** trong nhật ký
- Xem **mối quan hệ** giữa các thực thể (ví dụ: Minh - bạn thân - gặp ở quán café)
- AI tạo **nhận xét sâu sắc** về các mối quan hệ

### ⚙️ Linh hoạt với AI models
- Chọn model AI phù hợp: **Claude 3.5 Sonnet, GPT-4o, Gemini 2.0, v.v.**
- Mỗi cuộc trò chuyện có thể dùng **model khác nhau**
- Hỗ trợ **OpenRouter** - truy cập hàng chục models AI tiên tiến

### 💾 Sở hữu hoàn toàn dữ liệu
- **Xuất JSON**: Backup toàn bộ dữ liệu (nhật ký, AI insights, entities)
- **Xuất Markdown**: Đọc nhật ký dạng text thuần, mở bằng bất kỳ app nào
- **Nhập JSON**: Khôi phục dữ liệu với tùy chọn xử lý xung đột thông minh
- **Tích hợp Files app**: Lưu trực tiếp vào iCloud Drive, Dropbox, v.v.

### 🔒 Bảo mật & Riêng tư
- **Dữ liệu lưu 100% trên iPhone** của bạn
- **Mã hóa** hỗ trợ sẵn
- AI chỉ nhận dữ liệu khi bạn hỏi, **không tự động upload**
- Không có account, không có cloud sync - **bạn kiểm soát hoàn toàn**

## 📲 Cài đặt

### Yêu cầu hệ thống
- **iOS 18.0+** (iPhone)
- **Xcode 16+** (để build từ source code)

### Hướng dẫn cài đặt

1. **Clone repository**:
   ```bash
   git clone https://github.com/phuc-nt/kioku-ios.git
   cd kioku-ios
   ```

2. **Mở workspace trong Xcode**:
   ```bash
   open Kioku.xcworkspace
   ```

3. **Cấu hình OpenRouter API** (để dùng AI):
   - Tạo tài khoản tại [openrouter.ai](https://openrouter.ai)
   - Lấy API key
   - Vào **Settings** trong app → nhập API key

4. **Build & Run**:
   - Chọn iPhone simulator hoặc device
   - Nhấn **Run** (⌘R)

## 🚀 Sử dụng

### Bước 1: Viết nhật ký
- Mở tab **Calendar** (📅)
- Chọn ngày, nhập suy nghĩ của bạn
- Tự động lưu khi bạn rời khỏi

### Bước 2: Trò chuyện với AI
- Chuyển sang tab **Chat** (💬)
- Hỏi AI về nhật ký: "Tuần này tôi có vui không?", "Tôi hay gặp ai nhất?"
- AI sẽ đọc nhật ký và trả lời dựa trên dữ liệu thực tế

### Bước 3: Khám phá Insights
- Vào **Insights** để xem người/địa điểm/sự kiện AI phát hiện
- Xem **mối quan hệ** giữa các thực thể
- Đọc **AI-generated insights** về cuộc sống bạn

### Bước 4: Backup dữ liệu
- Vào **Settings** → **Data Management**
- **Export to JSON**: Backup toàn bộ
- **Export to Markdown**: Xuất dạng text để đọc
- **Import from JSON**: Khôi phục từ backup

## 🛠️ Dành cho Developers

### Tech Stack
- **SwiftUI** + **SwiftData** (iOS native)
- **OpenRouter API** (AI integration)
- **Swift Package Manager** (modular architecture)
- **Encryption support** (local data security)

### Project Structure
```
Kioku.xcworkspace          # Mở file này trong Xcode
├── Kioku/                 # App target
├── KiokuPackage/          # Feature modules (SPM)
│   └── Sources/KiokuFeature/
│       ├── Models/        # Entry, Entity, ChatMessage
│       ├── Services/      # DataService, ExportService, AI
│       └── Views/         # Calendar, Chat, Settings
└── docs/                  # Architecture & sprint docs
```

### Development Workflow
1. Đọc `docs/00_context/03_architecture_design.md` để hiểu kiến trúc
2. Xem `docs/01_sprints/` để biết sprint hiện tại
3. Code chủ yếu trong `KiokuPackage/Sources/KiokuFeature/`

### Testing
- **UI Tests**: Sử dụng XcodeBuildMCP automation
- **Unit Tests**: Swift Testing framework
- Xem `docs/03_testing/` để biết test scenarios

## 📄 License

MIT License - Xem file [LICENSE](LICENSE) để biết chi tiết.

## 🙏 Credits

- Scaffolded với [XcodeBuildMCP](https://github.com/cameroncooke/XcodeBuildMCP)
- AI models via [OpenRouter](https://openrouter.ai)

---

**Made with ❤️ for people who love journaling and self-reflection**
