# Kioku iOS - Architecture Design Document

**Version**: 1.0  
**Date**: September 30, 2025  
**Status**: Current (Post Sprint 10)  

## Overview

Kioku là một ứng dụng journaling cá nhân với tích hợp AI, được xây dựng bằng SwiftUI và SwiftData. Ứng dụng cho phép người dùng viết nhật ký theo ngày và tương tác với AI để phân tích patterns, insights từ các entries.

## Core Architecture

### Technology Stack
- **UI Framework**: SwiftUI (iOS 18.0+)
- **Data Persistence**: SwiftData with local SQLite
- **Encryption**: Built-in encryption support for sensitive data
- **AI Integration**: OpenRouter API for chat functionality
- **Navigation**: Tab-based architecture with NavigationStack

### App Structure

```
KiokuApp (Main)
├── ContentView (TabView Container)
│   ├── CalendarTabView → CalendarView
│   └── ChatTabView → AIChatView
└── DataService (SwiftData Environment)
```

## Data Architecture

### Core Models

#### 1. Entry (Journal Entry)
```swift
@Model
class Entry {
    var content: String           // User's journal content
    var date: Date?              // Explicit date (optional)
    var createdAt: Date          // Auto timestamp
    var updatedAt: Date          // Last modified
    var mood: String?            // User mood (optional)
    var tags: [String]           // Associated tags
    // Encryption support built-in
}
```

#### 2. AIAnalysis (AI Insights)
```swift
@Model  
class AIAnalysis {
    var entryId: String          // Reference to Entry
    var analysisType: String     // Type of analysis
    var result: String           // AI analysis result
    var confidence: Double       // Analysis confidence score
    var createdAt: Date          // Analysis timestamp
}
```

#### 3. ChatMessage (AI Chat History)
```swift
struct AIChatMessage {
    var content: String          // Message content
    var isFromUser: Bool         // Message direction
    var timestamp: Date          // Message time
    var contextData: String?     // Context metadata
}
```

### Data Storage Strategy

**Local-First Architecture**:
- All data stored locally using SwiftData/SQLite
- No cloud sync currently implemented
- Encryption enabled for sensitive content
- Data persists across app launches

**Data Relationships**:
- Entry ↔ AIAnalysis: One-to-many (một entry có thể có nhiều analysis)
- Entry → Date: Date-based grouping cho calendar view
- ChatMessage: Context-aware, linked to current date

## Feature Architecture

### 1. Calendar & Journaling
**Components**: `CalendarView`, `EntryDetailView`
- Calendar grid hiển thị entries theo tháng
- Dot indicators cho ngày có entries
- Entry creation/editing với rich text support
- Date normalization để handle timezone issues

### 2. AI Chat Integration (Sprint 10)
**Components**: `ChatTabView`, `AIChatView`, `ChatContextService`

**Context Discovery System**:
```
Selected Date → DateContextService → ChatContextService → AI API
     ↓               ↓                      ↓              ↓
Current Note → Historical Notes → Context Package → Chat Response
```

**Context Types**:
- **Current Note**: Entry cho ngày được chọn
- **Historical Notes**: Entries từ cùng ngày trong các tháng trước (up to 12 months)
- **Recent Notes**: Entries từ tuần vừa qua
- **Context Transparency**: User thấy được data nào AI đang sử dụng

### 3. Navigation Architecture
**Tab-Based Structure**:
- **Calendar Tab**: Primary journaling interface
- **Chat Tab**: AI interaction with date context
- **Shared State**: `selectedDate` binding between tabs
- **Independent Navigation**: Mỗi tab có NavigationStack riêng

## Services Architecture

### DataService
- SwiftData ModelContainer wrapper
- Encryption support
- Database operations centralization
- Environment injection cho toàn app

### DateContextService
- Date-based entry discovery
- Historical notes aggregation
- Timezone normalization
- Calendar integration logic

### ChatContextService  
- Context aggregation từ DateContextService
- AI prompt generation với context injection
- Context transparency management

### OpenRouterService
- External AI API integration
- Request/response handling
- Error management

## Key Design Patterns

### 1. Observable Architecture
```swift
@Observable class Service { }  // SwiftData @Observable
@Environment(Service.self)     // Environment injection
```

### 2. Date Consistency
**Critical**: Tất cả date operations phải dùng `calendar.isDate(_:inSameDayAs:)` thay vì range comparison để tránh timezone issues.

### 3. Context-Aware AI
- AI luôn nhận context của ngày hiện tại
- Context được hiển thị transparent cho user
- Historical pattern recognition

### 4. Error Handling
- Graceful fallbacks cho API failures
- Local-first approach đảm bảo app hoạt động offline
- User-friendly error messages

## Security & Privacy

### Data Protection
- Local encryption cho sensitive data
- No cloud storage by default
- User có full control over data
- AI context có thể được configured privacy levels

### API Security
- OpenRouter API key management
- Request encryption
- No personal data logging

## Development Guidelines

### Adding New Features
1. **Data Models**: Extend existing hoặc tạo new @Model classes
2. **Services**: Create Observable services for business logic
3. **Views**: Follow SwiftUI best practices with Environment injection
4. **Context**: Always consider date context cho AI features

### Testing Strategy
- XcodeBuildMCP automation cho UI testing
- Manual testing scenarios documented in `docs/03_testing/`
- Performance validation: <2s app launch, smooth interactions

### Code Organization
```
KiokuPackage/Sources/KiokuFeature/
├── Models/           # Data models (@Model classes)
├── Services/         # Business logic (@Observable services)  
├── Views/
│   ├── Calendar/     # Calendar-related views
│   ├── Chat/         # AI chat interface
│   └── Navigation/   # Tab navigation components
└── Utils/            # Helper utilities
```

## Future Architecture Considerations

### Knowledge Graph Integration
**Data Foundation Ready**:
- Entry model có tags system
- Historical relationships đã established
- Date-based connections available
- AI analysis results có thể được indexed

**Potential Extensions**:
- Entity extraction từ journal content
- Relationship mapping between entries
- Semantic search capabilities
- Pattern recognition across time

### Scalability Considerations
- Current architecture supports large datasets
- SwiftData performance optimization needed cho >1000 entries
- Consider pagination cho calendar views
- AI context aggregation có thể cần optimization

### Integration Points
- Cloud sync capability (optional)
- Export/import functionality  
- Advanced AI models integration
- Multi-device synchronization

## Maintenance Notes

### Critical Dependencies
- SwiftData compatibility với iOS versions
- OpenRouter API availability và pricing
- XcodeBuildMCP cho testing automation

### Performance Monitoring
- App launch time: Target <2s
- Chat context loading: Target <1s  
- Calendar rendering: Smooth scrolling
- Memory usage: Monitor for large datasets

### Known Technical Debt
- Calendar view có thể optimize better cho large datasets
- Error handling có thể improve user experience
- AI context có thể cache để improve performance

---

**Next Development Phase**: AI Features Enhancement (Knowledge Graph, Advanced Analytics, Pattern Recognition)