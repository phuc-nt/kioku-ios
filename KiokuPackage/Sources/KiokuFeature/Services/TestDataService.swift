import Foundation
import SwiftData

/// Service for generating realistic test data for development and testing
@Observable
public final class TestDataService: @unchecked Sendable {

    private let dataService: DataService

    public init(dataService: DataService) {
        self.dataService = dataService
    }

    /// Generate 2 months of realistic journal entries in Vietnamese
    /// Simulates a software engineer with 2 kids writing about work and life
    public func generateTestData() async throws {
        let entries = generateVietnameseEntries()

        for entry in entries {
            dataService.modelContext.insert(entry)
        }

        try? dataService.modelContext.save()
    }

    /// Drop and recreate the entire database (nuclear option)
    /// This is the cleanest way to clear all data - completely removes the database file
    @MainActor
    public func dropDatabase() throws {
        print("🗑️ Dropping database (nuclear option)...")

        // Get the database URL
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbURL = appSupport.appendingPathComponent("default.store")

        print("  📂 Database location: \(dbURL.path)")

        // Check if database exists
        if fileManager.fileExists(atPath: dbURL.path) {
            // Delete the database file
            try fileManager.removeItem(at: dbURL)
            print("  ✅ Database file deleted successfully")
        } else {
            print("  ℹ️  Database file doesn't exist (already clean)")
        }

        // Also delete any .store-shm and .store-wal files (SQLite temporary files)
        let shmURL = appSupport.appendingPathComponent("default.store-shm")
        let walURL = appSupport.appendingPathComponent("default.store-wal")

        try? fileManager.removeItem(at: shmURL)
        try? fileManager.removeItem(at: walURL)

        print("  🎉 Database dropped! App needs to be restarted to recreate.")
    }

    /// Clear all data from the database with orphan detection
    public func clearAllData() {
        print("🗑️ Starting Clear All Data operation...")

        // Phase 1: Delete Conversations (with cascade to messages)
        let conversations = dataService.fetchAllConversations()
        print("  📋 Deleting \(conversations.count) conversations...")
        for conversation in conversations {
            dataService.modelContext.delete(conversation)
        }

        // Phase 2: Delete Insights (standalone)
        let insightDescriptor = FetchDescriptor<Insight>()
        if let insights = try? dataService.modelContext.fetch(insightDescriptor) {
            print("  💡 Deleting \(insights.count) insights...")
            for insight in insights {
                dataService.modelContext.delete(insight)
            }
        }

        // Phase 3: Delete AIAnalysis (standalone)
        let analysisDescriptor = FetchDescriptor<AIAnalysis>()
        if let analyses = try? dataService.modelContext.fetch(analysisDescriptor) {
            print("  🤖 Deleting \(analyses.count) AI analyses...")
            for analysis in analyses {
                dataService.modelContext.delete(analysis)
            }
        }

        // Phase 4: Delete EntityRelationships first (to avoid cascade issues)
        let relationshipDescriptor = FetchDescriptor<EntityRelationship>()
        if let relationships = try? dataService.modelContext.fetch(relationshipDescriptor) {
            print("  🔗 Deleting \(relationships.count) relationships...")
            for relationship in relationships {
                dataService.modelContext.delete(relationship)
            }
        }

        // Phase 5: Delete Entities (now safe to delete without relationships)
        let entityDescriptor = FetchDescriptor<Entity>()
        if let entities = try? dataService.modelContext.fetch(entityDescriptor) {
            print("  🏷️  Deleting \(entities.count) entities...")
            for entity in entities {
                dataService.modelContext.delete(entity)
            }
        }

        // Phase 6: Delete Entries (now safe to delete without entities/relationships)
        let entries = dataService.fetchAllEntries()
        print("  📝 Deleting \(entries.count) entries...")
        for entry in entries {
            dataService.modelContext.delete(entry)
        }

        // Save all changes at once
        do {
            try dataService.modelContext.save()
            print("  💾 Saved all deletion changes")
        } catch {
            print("  ❌ Error during deletion: \(error.localizedDescription)")
            return
        }

        // Phase 7: Verify no orphaned objects (safety check)
        print("  🔍 Checking for orphaned objects...")

        let remainingEntities = (try? dataService.modelContext.fetch(FetchDescriptor<Entity>())) ?? []
        let remainingRelationships = (try? dataService.modelContext.fetch(FetchDescriptor<EntityRelationship>())) ?? []

        if !remainingEntities.isEmpty || !remainingRelationships.isEmpty {
            print("  ⚠️  Warning: Found orphaned objects after clear:")
            print("     - Entities: \(remainingEntities.count)")
            print("     - Relationships: \(remainingRelationships.count)")

            // Force delete orphaned objects
            print("  🧹 Force deleting orphaned objects...")
            for entity in remainingEntities {
                dataService.modelContext.delete(entity)
            }
            for relationship in remainingRelationships {
                dataService.modelContext.delete(relationship)
            }

            // Save again
            do {
                try dataService.modelContext.save()
                print("  ✅ Orphaned objects cleaned up successfully")
            } catch {
                print("  ❌ Error cleaning up orphans: \(error.localizedDescription)")
            }
        } else {
            print("  ✅ No orphaned objects found - clean deletion!")
        }

        print("🎉 Clear All Data completed successfully")
    }

    // MARK: - Test Data Generation

    private func generateVietnameseEntries() -> [Entry] {
        var entries: [Entry] = []
        let calendar = Calendar.current

        // Create 10 entries with overlapping dates in September and October 2025
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Define specific dates: some in Sep, some in Oct, some on same day of different months
        let testDates = [
            dateFormatter.date(from: "2025-09-15")!, // Sep 15
            dateFormatter.date(from: "2025-10-15")!, // Oct 15 (same day)
            dateFormatter.date(from: "2025-09-20")!, // Sep 20
            dateFormatter.date(from: "2025-10-20")!, // Oct 20 (same day)
            dateFormatter.date(from: "2025-09-25")!, // Sep 25
            dateFormatter.date(from: "2025-10-25")!, // Oct 25 (same day)
            dateFormatter.date(from: "2025-09-10")!, // Sep 10
            dateFormatter.date(from: "2025-10-10")!, // Oct 10 (same day)
            dateFormatter.date(from: "2025-09-05")!, // Sep 5
            dateFormatter.date(from: "2025-10-05")!, // Oct 5 (same day)
        ]

        for date in testDates {
            let entry = generateEntry(for: date)
            entries.append(entry)
        }

        return entries
    }

    private func generateEntry(for date: Date) -> Entry {
        let templates = getVietnameseTemplates()
        let template = templates.randomElement()!

        // Create entry with just content and date
        let entry = Entry(content: template.content, date: date)

        // Set additional properties after creation
        // Note: mood, weather, title would need to be added to Entry model
        // For now, we'll include them in the content
        let fullContent = """
        # \(template.title)

        \(template.content)

        ---
        Tâm trạng: \(template.mood)
        Thời tiết: \(template.weather)
        """

        entry.content = fullContent

        return entry
    }

    private func getVietnameseTemplates() -> [EntryTemplate] {
        return [
            // Work entries
            EntryTemplate(
                title: "Sprint Planning hôm nay",
                content: """
                Hôm nay team có sprint planning cho sprint mới. Anh Minh - tech lead của team - đã assign cho mình task làm feature search mới cho app.

                Công việc chính:
                - Implement search API với Elasticsearch
                - Tối ưu query performance
                - Làm UI search với SwiftUI

                Dự án đang dùng microservices architecture, nên mình phải coordinate với team Backend. Anh Tuấn ở team Backend sẽ support mình về API design.

                Estimate khoảng 8 story points, deadline 2 tuần nữa. Hơi gấp nhưng ổn, có thể làm được.
                """,
                mood: "focused",
                weather: "cloudy"
            ),

            EntryTemplate(
                title: "Code review với anh Minh",
                content: """
                Sáng nay có code review session với anh Minh. Anh comment khá nhiều về code quality và best practices.

                Feedback chính:
                - Nên dùng dependency injection thay vì singleton
                - Refactor code để giảm coupling
                - Thêm unit tests cho các edge cases

                Mình học được nhiều từ anh Minh, đặc biệt là cách structure code cho maintainable. Anh đã làm iOS developer 10 năm rồi nên kinh nghiệm rất tốt.

                Chiều nay sẽ refactor lại theo feedback.
                """,
                mood: "motivated",
                weather: "sunny"
            ),

            EntryTemplate(
                title: "Debug bug production",
                content: """
                Hôm nay production có incident nghiêm trọng - app crash cho nhiều users. Sếp gọi họp gấp lúc 10h sáng.

                Root cause:
                - Memory leak ở image caching service
                - Không release resources đúng cách
                - Ảnh hưởng đến 15% users

                Team đã phải hotfix gấp. Mình với anh Tuấn pair programming để fix bug. Sau 3 tiếng debug cuối cùng cũng tìm ra lỗi và deploy fix.

                Bài học: Phải test kỹ hơn với large dataset trước khi release. Sẽ thêm performance tests vào CI/CD pipeline.

                Stress cực nhưng team work tốt nên resolve nhanh.
                """,
                mood: "stressed",
                weather: "rainy"
            ),

            // Family entries
            EntryTemplate(
                title: "Cuối tuần đưa các con đi công viên",
                content: """
                Sáng nay đưa Minh và Hằng đi công viên Thống Nhất chơi. Trời đẹp nên cả nhà quyết định đi picnic.

                Các con rất vui:
                - Minh (8 tuổi) thích chạy nhảy, chơi bóng
                - Hằng (5 tuổi) thích chơi xích đu
                - Vợ mình chuẩn bị đồ ăn rất ngon

                Chiều về ghé nhà hàng Pizza 4P's ăn tối. Các con kêu pizza ngon lắm, muốn ăn mãi.

                Những ngày cuối tuần như thế này rất quý giá. Công việc bận rộn nên ít khi có thời gian cho gia đình.
                """,
                mood: "happy",
                weather: "sunny"
            ),

            EntryTemplate(
                title: "Minh thi xong học kỳ",
                content: """
                Hôm nay Minh thi xong học kỳ 1. Con rất hào hứng vì được nghỉ hè.

                Kết quả học tập:
                - Toán: 9.5 điểm (giỏi)
                - Tiếng Việt: 9.0 điểm
                - Tiếng Anh: 8.5 điểm

                Thầy chủ nhiệm khen con học tiến bộ, đặc biệt là môn Toán. Con thích toán logic, có lẽ sau này sẽ theo ngành IT như bố.

                Hè này dự định cho con học thêm lập trình Scratch để phát triển tư duy logic.
                """,
                mood: "proud",
                weather: "sunny"
            ),

            EntryTemplate(
                title: "Hằng bị ốm",
                content: """
                Đêm qua Hằng sốt cao 39 độ, vợ chồng mình lo lắm. Sáng sớm đưa con đi bệnh viện Nhi Đồng 1 khám.

                Bác sĩ Lan khám và cho biết:
                - Con bị viêm họng
                - Kê đơn thuốc hạ sốt và kháng sinh
                - Cần nghỉ ngơi 3-4 ngày

                Mình xin nghỉ phép 2 ngày để ở nhà chăm con. Vợ mình cũng nghỉ làm. May mà công ty flexible về work from home.

                Tối nay con đã bớt sốt, ăn được cháo. Thấy con khỏe lại mừng lắm.
                """,
                mood: "worried",
                weather: "cloudy"
            ),

            // Learning entries
            EntryTemplate(
                title: "Học SwiftUI mới",
                content: """
                Chiều nay sau khi về nhà, mình dành 2 tiếng học SwiftUI mới trên Apple Developer tutorials.

                Nội dung học:
                - Observable macro thay thế ObservableObject
                - SwiftData thay thế CoreData
                - New navigation APIs

                SwiftUI ngày càng mature và dễ dùng hơn. Mình rất thích declarative UI programming paradigm này.

                Dự án tiếp theo ở công ty sẽ migrate sang SwiftUI hoàn toàn. Cần phải master framework này.

                Planning: Sẽ làm pet project để practice - một app quản lý chi tiêu gia đình.
                """,
                mood: "curious",
                weather: "night"
            ),

            EntryTemplate(
                title: "Đọc Clean Architecture",
                content: """
                Đang đọc cuốn Clean Architecture của Uncle Bob. Cuốn sách rất hay về software design principles.

                Key takeaways:
                - Separation of Concerns
                - Dependency Inversion Principle
                - SOLID principles trong thực tế

                Mình nhận ra nhiều mistakes trong code của mình. Đặc biệt là việc couple business logic với UI layer.

                Sẽ apply những nguyên tắc này vào dự án mới. Anh Minh cũng recommend cuốn này, bảo là must-read cho senior developer.
                """,
                mood: "inspired",
                weather: "rainy"
            ),

            // Daily life entries
            EntryTemplate(
                title: "Cafe sáng với team",
                content: """
                Sáng nay team đi cafe Highlands trước khi vào công ty làm việc. Tinh thần team building rất tốt.

                Có mặt:
                - Anh Minh (Tech Lead)
                - Anh Tuấn (Backend)
                - Chị Hương (QA)
                - Mình và 2 bạn iOS khác

                Tụi mình chat về technical stuff, project roadmap, và cả chuyện đời. Chị Hương kể về kinh nghiệm test automation rất hay.

                Môi trường làm việc tốt, đồng nghiệp support nhau. Mình rất thích văn hóa công ty hiện tại.
                """,
                mood: "relaxed",
                weather: "sunny"
            ),

            EntryTemplate(
                title: "Tập gym sau làm việc",
                content: """
                Tối nay đi tập gym như thường lệ. Ngồi code cả ngày nên phải tập thể dục để giữ sức khỏe.

                Workout hôm nay:
                - Bench press: 4 sets x 10 reps (60kg)
                - Squats: 4 sets x 8 reps (80kg)
                - Deadlifts: 3 sets x 6 reps (100kg)

                PT Khoa hướng dẫn kỹ thuật nâng tạ đúng cách. Phải focus vào form thay vì tăng weight quá nhanh.

                Sau 3 tháng tập đều đặn, cảm thấy cơ thể khỏe hơn nhiều. Tinh thần làm việc cũng tốt hơn.
                """,
                mood: "energetic",
                weather: "night"
            ),

            // Weekend entries
            EntryTemplate(
                title: "Họp gia đình nhà vợ",
                content: """
                Cuối tuần này về nhà vợ ở Bình Dương họp mặt gia đình. Bố mẹ vợ nấu cơm rất nhiều món ngon.

                Có mặt:
                - Bố mẹ vợ
                - Anh chị vợ và các cháu
                - Cả nhà mình

                Bữa cơm ấm cúng, mọi người chia sẻ về công việc và cuộc sống. Bố vợ khen Minh học giỏi, Hằng ngoan.

                Chiều cả nhà ra sông Sài Gòn dạo chơi. Trời mát mẻ, không khí trong lành.

                Những dịp sum họp gia đình như thế này rất quý giá.
                """,
                mood: "grateful",
                weather: "sunny"
            ),

            // Reflection entries
            EntryTemplate(
                title: "Suy nghĩ về career path",
                content: """
                Tối nay ngồi một mình suy nghĩ về career path 5 năm tới. Mình đã làm iOS developer được 5 năm.

                Options:
                1. Tiếp tục technical path → Senior/Staff Engineer
                2. Chuyển sang management → Engineering Manager
                3. Khởi nghiệp startup công nghệ

                Ưu điểm technical path:
                - Mình thích coding và technical challenges
                - Cơ hội học hỏi công nghệ mới
                - Ít meeting, focus vào delivery

                Nhược điểm:
                - Thu nhập tăng chậm hơn management
                - Impact nhỏ hơn

                Cần thời gian suy nghĩ thêm. Sẽ discuss với vợ và anh Minh.
                """,
                mood: "thoughtful",
                weather: "night"
            )
        ]
    }
}

// MARK: - Supporting Types

private struct EntryTemplate {
    let title: String
    let content: String
    let mood: String
    let weather: String
}
