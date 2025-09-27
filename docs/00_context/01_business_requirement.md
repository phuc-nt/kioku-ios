# Business Requirements Document (BRD)
## AI-Powered Personal Journal iOS App

**Version:** 3.0  
**Date:** September 27, 2025  
**Major Update:** Calendar-Based Journal Design  
**Document Type:** Business Requirements Document  
**Project Type:** Personal Development Project

***

## Concept & Inspiration

### Ý Tưởng Gốc
Ứng dụng được lấy cảm hứng từ **sổ nhật ký vật lý 10 năm trên 2 trang** - một concept độc đáo cho phép người dùng viết cùng một ngày qua nhiều năm trên cùng một spread, tạo ra **hiệu ứng "nhìn lại"** tự nhiên khi thấy những gì đã viết vào cùng ngày này những năm trước.

### Digital Calendar Implementation
Chuyển đổi concept vật lý thành **calendar-based digital experience** với:
- **One Entry Per Day**: Mỗi ngày chỉ có một entry, phản ánh thực tế cuộc sống hàng ngày
- **Calendar Navigation**: Apple Calendar-style interface cho intuitive date navigation
- **Time Travel Feature**: Dễ dàng xem "same day" từ previous months/years
- **Visual Content Indicators**: Dots hiển thị ngày có content để quick overview

### Triết Lý Thiết Kế
- **Daily Focus**: Mỗi ngày một entry duy nhất, khuyến khích reflection sâu sắc thay vì multiple scattered thoughts
- **Calendar-First Navigation**: Date-centric experience giống physical journal thật sự
- **Nostalgic Time Travel**: Dễ dàng compare cùng một ngày qua các năm để thấy personal growth
- **AI-Enhanced Memory**: Sử dụng AI để tạo connections giữa các entries theo dates và themes (future feature)

### Vấn Đề Được Giải Quyết
Trong thời đại số, chúng ta thường có **những suy nghĩ thoáng qua** cần ghi lại nhưng không phải lúc nào cũng có sổ vật lý bên cạnh. App này tạo ra **cầu nối kỹ thuật số** cho phép capture nhanh những moments này, đồng thời sử dụng AI để biến chúng thành **knowledge graph cá nhân** - một bản đồ trí tuệ về cuộc sống và sự phát triển của bản thân.

***

## 1. Executive Summary

### 1.1 Project Overview
Phát triển ứng dụng nhật ký cá nhân trên iOS với tính năng AI thông minh, được thiết kế để hỗ trợ **capture nhanh suy nghĩ** và tạo ra trải nghiệm **self-reflection sâu sắc** thông qua **knowledge graph** và **conversational AI**.

### 1.2 Personal Value Proposition
- **Immediate Capture**: Ghi lại thoughts ngay khi chúng xuất hiện, không bị giới hạn bởi việc có sổ vật lý hay không
- **AI-Powered Insights**: Transform raw thoughts thành structured knowledge với khả năng tự động tìm patterns và connections
- **Conversational Memory**: Tương tác với AI như một người bạn hiểu biết về personal journey để nhận insights và guidance
- **Flexible AI Experience**: Thử nghiệm với different AI models để có different perspectives về cùng một set memories

### 1.3 Vision Statement
Tạo ra **digital companion** giúp người dùng không chỉ ghi lại ký ức mà còn **hiểu sâu hơn về bản thân**, **khám phá patterns trong cuộc sống**, và **phát triển khả năng self-reflection** thông qua việc đối thoại với AI về chính những trải nghiệm cá nhân của mình.

***

## 2. Project Context & Objectives

### 2.1 Personal Development Context
- **Self-Reflection Trend**: Ngày càng nhiều người quan tâm đến mental wellness và personal growth
- **Digital Native Behavior**: Xu hướng sử dụng mobile device để capture và organize personal information  
- **AI Integration**: Sự phát triển của LLM models tạo cơ hội mới cho personalized AI experiences

### 2.2 Project Objectives

#### Core Objectives:
1. **Create Calendar-Based Digital Journal** với Apple Calendar-style navigation và one-entry-per-day constraint
2. **Enable Date-Focused Writing** với immediate access to any specific date và seamless editing experience
3. **Implement Time Travel Features** để compare same days across months/years cho nostalgic reflection
4. **Build Personal Knowledge Graph** để tạo connections giữa entries theo dates và themes (future phase)

#### Technical Objectives:
1. **Implement Calendar Architecture** với efficient date-based data storage và navigation
2. **Ensure Privacy-First Design** với local storage, encryption, và optional cloud backup
3. **Create Intuitive Calendar UX** flows: calendar navigation → date selection → entry editing → time travel
4. **Build Migration System** để chuyển existing entries sang calendar-based structure

***

## 3. High-Level Requirements

### 3.1 Epic-Level Features

#### **EPIC-1: Calendar-Based Journal Foundation** *(PRIORITY: CRITICAL)*
**Business Value**: Core experience foundation với natural date-centric workflow  
**Description**: Apple Calendar-style interface với one entry per day, month/year views, và efficient date navigation

#### **EPIC-2: Time Travel & Historical Navigation** *(PRIORITY: HIGH)*
**Business Value**: Enhanced nostalgic experience và personal growth insights  
**Description**: Quick access to same day previous months/years, date pickers, và temporal comparison features

#### **EPIC-3: Data Migration & Architecture Transition** *(PRIORITY: CRITICAL)*
**Business Value**: Seamless transition từ current implementation sang calendar structure  
**Description**: Migrate existing entries, update data models, và maintain data integrity during transition

#### **EPIC-4: AI Knowledge Processing** *(PRIORITY: MEDIUM - Future Phase)*
**Business Value**: Transform date-based entries thành actionable insights  
**Description**: AI analysis với date-aware connections, temporal patterns, và knowledge graph generation

#### **EPIC-5: Advanced Calendar Features** *(PRIORITY: LOW)*
**Business Value**: Enhanced usability và power user features  
**Description**: Search across dates, content indicators, bulk operations, và calendar customization

#### **EPIC-6: Privacy & Data Control** *(PRIORITY: HIGH)*
**Business Value**: User trust và data sovereignty  
**Description**: Maintain encryption, local storage, và backup systems trong calendar architecture

### 3.2 Technical Constraints & Assumptions

#### **Platform Constraints:**
- **iOS 17.0+** exclusively initially
- **SwiftUI** framework cho modern, maintainable UI  
- **SwiftData** cho modern local persistence
- **OpenRouter API** cho AI model access

#### **Key Assumptions:**
- Users will write **2-3 times per week minimum** để generate meaningful patterns
- **Internet connectivity** available cho AI features (graceful offline degradation)
- Users comfortable với **AI analyzing personal content** với proper privacy controls
- **OpenRouter API** remains stable và cost-effective long-term

***

## 4. Non-Functional Requirements

### 4.1 Performance Standards
- **App Launch**: <2 seconds on average iOS devices
- **Entry Creation**: Immediate responsiveness, <1 second save time  
- **AI Processing**: <5 seconds cho knowledge graph updates
- **Search & Navigation**: <1 second response time

### 4.2 Security & Privacy
- **Data Encryption**: AES-256 encryption cho all stored content
- **API Security**: Secure API key management via iOS Keychain
- **Privacy-First**: No data sharing với third parties without explicit user consent
- **Local Processing**: Maximum data processing on-device when feasible

### 4.3 Reliability & Availability  
- **Data Integrity**: 99.9% data preservation với backup verification
- **App Stability**: <0.1% crash rate during normal operation
- **Offline Capability**: Core journaling functions work without internet
- **Sync Reliability**: 99% success rate cho optional cloud backups

### 4.4 Usability Standards
- **Learning Curve**: New users productive trong <5 minutes
- **Accessibility**: Full VoiceOver support và Dynamic Type compatibility
- **Writing Flow**: Zero friction từ app launch đến writing first words
- **Natural Interface**: Conversation với AI feels intuitive và helpful

***

## 5. Success Definition

### 5.1 Personal Success Metrics
- **Consistency**: Personal usage 3+ times per week for 3+ months
- **Insight Quality**: AI provides meaningful patterns và actionable suggestions
- **Habit Formation**: App becomes integral part của personal reflection routine
- **Data Growth**: 50+ meaningful entries trong first 6 months

### 5.2 Technical Success Criteria  
- **Feature Completion**: All MVP epics implemented và tested
- **Performance Benchmarks**: All non-functional requirements met
- **Security Validation**: No data breaches, proper encryption verification
- **User Experience**: Smooth, intuitive flows với minimal friction

### 5.3 Long-term Vision Validation
- **AI Enhancement**: Clear evidence rằng AI adds value beyond simple storage
- **Pattern Discovery**: Ability to surface insights không visible through manual review
- **Behavioral Impact**: Positive influence on self-awareness và personal growth
- **Technical Foundation**: Architecture supports future enhancements và scaling

***

## 6. Cross-References & Related Documents

### 6.1 Detailed Implementation
→ **Feature Breakdown**: Product-Backlog.md  
→ **Sprint Implementation**: Sprint-X-Planning.md files  
→ **Architecture Decisions**: /docs/adrs/ directory

### 6.2 Document Relationships
```
BRD (This Document) - Strategic Foundation
├── Informs → Product Backlog (Feature prioritization)
├── Validates → Sprint Goals (Business alignment) 
└── References ← Sprint Retrospectives (Assumption validation)
```

### 6.3 Living Document Updates
- **Epic Scope Changes**: Update Section 3.1 với new business requirements
- **Assumption Validation**: Update Section 3.2 based on development learnings  
- **Success Metric Evolution**: Refine Section 5 với actual usage data
- **Vision Refinement**: Adjust Section 1.3 với user feedback và market changes

***

## 7. Approval & Next Steps

### 7.1 Document Status
- **Current Status**: Draft for Review
- **Review Required**: Self-validation của business objectives và technical feasibility
- **Approval Criteria**: Alignment với personal goals và available development resources

### 7.2 Immediate Next Steps
1. **Validate BRD** với personal objectives và time constraints
2. **Create Product Backlog** với detailed feature breakdown
3. **Plan Sprint 1** với foundational features và technical setup

### 7.3 Documentation Roadmap
- **Next Document**: Product-Backlog.md (detailed epic breakdown)
- **Development Docs**: Sprint planning documents per development cycle
- **Architecture Records**: ADRs documenting key technical decisions

***

**Document Prepared By**: AI Requirements Analyst  
**Document Type**: Personal Project Business Requirements  
**Version Control**: v2.0 - Restructured for agile development approach  
**Last Updated**: September 11, 2025  
**Next Review**: Upon Product Backlog completion