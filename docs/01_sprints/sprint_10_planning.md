# Sprint 10 Planning: AI Chat Integration

**Sprint Duration**: September 28 - October 11, 2025  
**Sprint Goal**: Implement AI chat functionality with context-aware assistance and tab-based navigation  
**Story Points**: 13  
**Team Velocity**: 8-12 points per sprint  

## Sprint Overview

### 🎯 **Sprint Objective**
Implement AI chat integration to transform Kioku from a standalone journaling app into an AI-powered personal reflection assistant. Users will be able to access intelligent chat features both from note details and through dedicated chat navigation.

### 📈 **Business Value**
- **Enhanced User Engagement**: AI chat creates interactive experience beyond static journaling
- **Personalized Insights**: Context-aware chat provides tailored guidance based on journal patterns
- **Seamless Workflow**: Tab navigation allows smooth transition between journaling and AI assistance
- **Foundation for Future**: Establishes chat infrastructure for advanced AI features

### 🏗 **Architecture Foundation**
This sprint builds upon:
- **Sprint 3-4**: AI service integration (OpenRouter API, analysis models)
- **Sprint 9**: Enhanced time travel (historical notes context)
- **Existing**: SwiftUI navigation, SwiftData persistence

---

## User Stories Breakdown

### **US-038: AI Chat Access from Note Detail** 
**Story Points**: 5 | **Priority**: High | **Complexity**: High

#### **Acceptance Criteria**
✅ **AC-1**: "Chat with AI" button/action in note detail screen  
✅ **AC-2**: Chat opens with full context: current note + historical notes from same day  
✅ **AC-3**: Context includes note content, dates, and emotional patterns  
✅ **AC-4**: Smooth transition from note detail to chat interface  
✅ **AC-5**: Return navigation to original note detail  

#### **Technical Tasks**
- [ ] **T-038-1**: Design ChatContextService for note + historical data aggregation
- [ ] **T-038-2**: Create AIChatView with message threading UI
- [ ] **T-038-3**: Implement context injection for OpenRouter API calls
- [ ] **T-038-4**: Add "Chat with AI" action to EntryDetailView
- [ ] **T-038-5**: Create navigation flow from note detail to chat
- [ ] **T-038-6**: Implement context-aware chat initialization

#### **Dependencies**
- EntryDetailView.swift (existing)
- HistoricalNotesView.swift logic (Sprint 9)
- AIService from Sprint 3-4
- OpenRouter API integration

#### **Definition of Done**
- [ ] User can tap "Chat with AI" from any note detail
- [ ] Chat loads with current note + historical notes context
- [ ] AI responses are contextually relevant to journal content
- [ ] Navigation back to original note works smoothly
- [ ] UI follows Apple design guidelines

---

### **US-039: Tab-Based Navigation Architecture**
**Story Points**: 5 | **Priority**: High | **Complexity**: Medium  

#### **Acceptance Criteria**
✅ **AC-1**: Two primary tabs: Calendar (default) and Chat  
✅ **AC-2**: Calendar tab contains existing calendar and note functionality  
✅ **AC-3**: Chat tab provides AI interaction with current date context  
✅ **AC-4**: State preservation when switching between tabs  
✅ **AC-5**: Consistent navigation patterns and UI design  

#### **Technical Tasks**
- [ ] **T-039-1**: Refactor ContentView to TabView architecture
- [ ] **T-039-2**: Extract existing calendar functionality to CalendarTabView
- [ ] **T-039-3**: Create ChatTabView with standalone chat interface
- [ ] **T-039-4**: Implement tab state management with @StateObject
- [ ] **T-039-5**: Design tab bar icons and visual identity
- [ ] **T-039-6**: Ensure date selection state persists across tabs

#### **Dependencies**
- ContentView.swift (main app structure)
- CalendarView.swift (existing calendar implementation)
- AIChatView from US-038

#### **Definition of Done**
- [ ] App has two tabs: Calendar and Chat
- [ ] Calendar tab preserves existing functionality
- [ ] Chat tab provides independent AI interaction
- [ ] Selected date state maintained across tab switches
- [ ] Tab navigation follows iOS HIG patterns

---

### **US-040: Context-Aware AI Chat Mode**
**Story Points**: 3 | **Priority**: Medium | **Complexity**: High

#### **Acceptance Criteria**
✅ **AC-1**: Chat mode automatically loads context based on current selected date  
✅ **AC-2**: AI has access to current day notes and historical patterns  
✅ **AC-3**: Context includes recent journal entries and emotional trends  
✅ **AC-4**: Proactive AI suggestions based on journal patterns  
✅ **AC-5**: Privacy-conscious context handling  

#### **Technical Tasks**
- [ ] **T-040-1**: Create DateContextService for current date awareness
- [ ] **T-040-2**: Implement automatic context loading in Chat tab
- [ ] **T-040-3**: Design context aggregation: current + recent + historical
- [ ] **T-040-4**: Create AI prompting system for proactive suggestions
- [ ] **T-040-5**: Implement privacy controls for context sharing
- [ ] **T-040-6**: Add context visualization in chat interface

#### **Dependencies**
- ChatTabView from US-039
- Historical notes logic from Sprint 9
- AI analysis models from Sprint 4
- Date selection state management

#### **Definition of Done**
- [ ] Chat tab automatically understands current selected date
- [ ] AI suggestions are relevant to journal patterns
- [ ] Context includes current + recent + historical notes
- [ ] Privacy settings control context sharing depth
- [ ] User can see what context AI is using

---

## Technical Architecture

### **New Components**
```
KiokuPackage/Sources/KiokuFeature/
├── Views/
│   ├── Chat/
│   │   ├── AIChatView.swift          # Core chat interface
│   │   ├── ChatTabView.swift         # Standalone chat tab
│   │   ├── ChatMessageView.swift     # Individual message UI
│   │   └── ChatContextView.swift     # Context display component
│   └── Navigation/
│       └── MainTabView.swift         # Tab-based app structure
├── Services/
│   ├── ChatContextService.swift     # Context aggregation
│   └── DateContextService.swift     # Date-aware context
└── Models/
    ├── ChatMessage.swift            # Chat message model
    └── ChatContext.swift            # Context data structure
```

### **Modified Components**
- **ContentView.swift**: Refactored to TabView architecture
- **EntryDetailView.swift**: Added "Chat with AI" action
- **AIService.swift**: Extended for chat-specific API calls

### **Data Flow Architecture**
```
Selected Date → DateContextService → ChatContextService → AI API
     ↓               ↓                      ↓              ↓
Current Note → Historical Notes → Context Package → Chat Response
```

---

## Sprint Planning Details

### **Sprint Capacity**
- **Available Development Days**: 14 days
- **Estimated Velocity**: 10-13 story points
- **Sprint Stories**: 13 story points (optimal fit)

### **Story Priority & Sequencing**
1. **US-039** (Tab Navigation) - **Day 1-5**: Foundation for all chat features
2. **US-038** (Note Detail Chat) - **Day 6-10**: Core chat functionality
3. **US-040** (Context-Aware Chat) - **Day 11-14**: Enhanced AI experience

### **Risk Assessment**
- **🔴 High Risk**: AI context aggregation complexity
- **🟡 Medium Risk**: Tab state management across complex navigation
- **🟢 Low Risk**: UI implementation (existing SwiftUI patterns)

### **Mitigation Strategies**
- **Context Complexity**: Start with simple context, iterate to advanced
- **State Management**: Use @StateObject and ObservableObject patterns
- **Integration Risk**: Build chat UI first, add AI integration incrementally

---

## Acceptance Testing Strategy

### **Manual Testing Scenarios**
1. **Chat Access Flow**:
   - Navigate to any note detail
   - Tap "Chat with AI" button
   - Verify chat opens with relevant context
   - Send test message and receive AI response
   - Navigate back to original note

2. **Tab Navigation Flow**:
   - Switch between Calendar and Chat tabs
   - Verify date selection persists
   - Create note in Calendar tab
   - Switch to Chat tab and verify context updates

3. **Context Awareness Testing**:
   - Select date with multiple historical notes
   - Open Chat tab
   - Verify AI has context of current + historical notes
   - Ask AI about patterns and verify relevant responses

### **XcodeBuildMCP Automation Plan**
```javascript
// Sprint 10 Test Automation
build_run_sim({ scheme: "Kioku", simulatorName: "iPhone 16" })
screenshot({ simulatorUuid })  // Verify tab bar appears
tap({ x: chatTabX, y: chatTabY })  // Switch to Chat tab
type_text({ text: "What patterns do you see in my journaling?" })
// Verify AI response includes context from current date
```

### **Performance Requirements**
- **Chat Loading**: <2 seconds for context aggregation
- **Tab Switching**: <500ms transition time
- **AI Response**: <5 seconds for initial response
- **Memory Usage**: No significant increase over existing features

---

## Definition of Sprint Success

### **Functional Success Criteria**
✅ All 3 user stories completed with acceptance criteria met  
✅ Tab navigation provides seamless experience  
✅ AI chat provides contextually relevant responses  
✅ Chat access from note detail works smoothly  
✅ Context-aware chat demonstrates journal pattern understanding  

### **Technical Success Criteria**
✅ Code follows existing Swift/SwiftUI patterns  
✅ No regressions in existing calendar functionality  
✅ XcodeBuildMCP automation tests pass  
✅ Performance requirements met  
✅ Architecture supports future chat enhancements  

### **Quality Gates**
- [ ] **Build Success**: All targets compile without errors
- [ ] **UI Testing**: XcodeBuildMCP automation scenarios pass
- [ ] **Manual Testing**: All acceptance scenarios validated
- [ ] **Performance**: Response times within requirements
- [ ] **Code Review**: Architecture review completed

---

## Sprint Retrospective Planning

### **Key Questions for Retrospective**
1. How effectively did tab navigation enhance user workflow?
2. Did AI context aggregation provide meaningful insights?
3. What challenges emerged in integrating chat with existing architecture?
4. How can we improve context quality for future sprints?

### **Metrics to Track**
- **Development Velocity**: Story points completed vs planned
- **Technical Debt**: Architecture decisions requiring future refactoring
- **User Experience**: Smoothness of chat integration with journaling workflow
- **AI Quality**: Relevance and usefulness of context-aware responses

---

## Dependencies & Integration Points

### **External Dependencies**
- **OpenRouter API**: Chat completions with context injection
- **Apple Frameworks**: SwiftUI TabView, NavigationStack patterns
- **XcodeBuildMCP**: UI automation for testing chat workflows

### **Internal Dependencies**
- **Sprint 3-4 AI Infrastructure**: AIService, model management
- **Sprint 9 Historical Notes**: Context aggregation foundation
- **Existing Calendar Architecture**: Date selection, entry management

### **Future Integration Points**
- **Sprint 11+**: Enhanced conversation memory
- **Sprint 12+**: Multi-model chat support
- **Sprint 13+**: Voice chat integration

---

**Sprint Planning Completed**: September 28, 2025  
**Next Planning Session**: October 11, 2025  
**Sprint Review**: October 11, 2025