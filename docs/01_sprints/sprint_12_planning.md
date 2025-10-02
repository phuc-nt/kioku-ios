# Sprint 12 Planning: Chat UX Improvements & Enhanced Context

**Sprint Period**: October 3-10, 2025
**Epic**: EPIC-5 - Full LLM Chat Integration (Phase 3)
**Story Points**: 8 points
**Status**: 🚀 **IN PROGRESS**

**Related Documents**:
- Previous Sprint: [`docs/01_sprints/sprint_11_planning.md`](sprint_11_planning.md)
- Architecture: [`docs/00_context/03_architecture_design.md`](../00_context/03_architecture_design.md)
- Product Backlog: [`docs/00_context/02_product_backlog.md`](../00_context/02_product_backlog.md)

---

## Sprint Goals

Enhance the chat experience with production-ready features and improved transparency:

1. ⏳ **Production API Key Management** - User-friendly settings UI
2. ⏳ **Stop/Regenerate Controls** - Better control over streaming responses
3. ⏳ **Conversation Date Association** - Link conversations to calendar dates
4. ⏳ **Enhanced Context Display** - Show what AI knows and why

---

## User Stories & Tasks

### US-S12-001: Production API Key Management (2 points)

**As a user**, I want a proper settings screen to manage my OpenRouter API key so I can easily configure the app without technical knowledge.

**Problem Statement**:
- Currently only have debug APIKeySetupView screen
- No clear onboarding flow for new users
- Missing validation and helpful error messages
- Need production-quality UI

**Requirements** (FR-601, FR-602, FR-603):
- Settings screen accessible from main app navigation
- API key input field with show/hide password toggle
- Real-time validation with visual feedback
- Clear instructions and help text
- Link to OpenRouter signup page
- Secure keychain storage confirmation

**Acceptance Criteria**:
- [ ] Settings screen accessible from tab bar or menu
- [ ] API key input accepts paste and typing
- [ ] Show/hide toggle for API key text
- [ ] Real-time validation: key format check
- [ ] Success/error states clearly displayed
- [ ] Help button links to OpenRouter docs
- [ ] "Sign up for free" link to OpenRouter
- [ ] Keychain storage persists across app restarts
- [ ] Empty state shows helpful onboarding message

**Technical Tasks**:
- [ ] Create `SettingsView.swift` with proper navigation
- [ ] Add Settings tab or menu item in main navigation
- [ ] Implement API key validation logic
- [ ] Add visual states: empty, valid, invalid, saving
- [ ] Create help content with OpenRouter instructions
- [ ] Add URL links to OpenRouter signup
- [ ] Test keychain persistence
- [ ] Add error handling for keychain operations

**Design Notes**:
- Follow iOS Settings app patterns
- Use standard SF Symbols icons
- Clear visual hierarchy
- Helpful but not overwhelming text

**Testing**:
- [ ] TC-S12-001: Settings navigation
- [ ] TC-S12-002: API key input and validation
- [ ] TC-S12-003: Show/hide toggle
- [ ] TC-S12-004: Keychain persistence
- [ ] TC-S12-005: Help links and onboarding

---

### US-S12-002: Stop/Regenerate During Streaming (2 points)

**As a user**, I want to stop AI responses mid-generation and regenerate responses so I have better control over the conversation.

**Problem Statement**:
- Long AI responses can't be interrupted
- No way to retry if response quality is poor
- Infrastructure exists but not fully implemented/tested

**Requirements** (FR-604, FR-605, FR-606):
- Stop button visible during active streaming
- Cancel SSE connection immediately on stop
- Preserve or clear partial response (user choice)
- Regenerate button on completed AI messages
- Regenerate uses same user prompt
- Loading states during regeneration

**Acceptance Criteria**:
- [ ] Stop button appears when streaming starts
- [ ] Stop button positioned clearly (toolbar or inline)
- [ ] Tapping stop cancels SSE immediately (<500ms)
- [ ] Partial message shows "Stopped by user" indicator
- [ ] Regenerate button (🔄) on AI message cards
- [ ] Regenerate creates new streaming response
- [ ] Old response remains visible during regeneration
- [ ] Error handling if regenerate fails
- [ ] Loading states prevent duplicate actions

**Technical Tasks**:
- [ ] Add stop button to StreamingChatView toolbar
- [ ] Implement SSE cancellation in StreamingService
- [ ] Handle partial message state properly
- [ ] Add regenerate button to message cards
- [ ] Create regenerate action in ConversationService
- [ ] Test concurrent operations (stop + send)
- [ ] Add proper loading/disabled states
- [ ] Handle edge cases (network loss during stop)

**UI/UX Notes**:
- Stop button: Red color, clear icon (⏹ or ✕)
- Regenerate: Subtle icon, tooltip on hover
- Show "Stopping..." feedback
- Smooth transitions between states

**Testing**:
- [ ] TC-S12-006: Stop during streaming
- [ ] TC-S12-007: Partial message handling
- [ ] TC-S12-008: Regenerate last message
- [ ] TC-S12-009: Regenerate with different response
- [ ] TC-S12-010: Edge cases (network failures)

---

### US-S12-003: Conversation Date Association (2 points)

**As a user**, I want to associate conversations with specific dates so the AI has better context about what I'm discussing.

**Problem Statement**:
- Conversations created from Calendar have no date link
- Context service doesn't know which date to prioritize
- Users can't see which date a conversation relates to

**Requirements** (FR-607, FR-608, FR-609):
- Link conversation to selected date when created from Calendar
- Show date badge/label in conversation list
- Update context when conversation's associated date changes
- Allow unlinking date from conversation
- Filter/sort conversations by date

**Acceptance Criteria**:
- [ ] Conversation has `associatedDate` field (already exists in model)
- [ ] Creating conversation from Calendar → auto-links current date
- [ ] Creating from Chat tab → no date association
- [ ] Conversation list shows date badge for dated conversations
- [ ] Date badge shows relative format ("Today", "Yesterday", "Oct 9")
- [ ] Tapping conversation loads context for that date
- [ ] Menu option to change/remove associated date
- [ ] DateContextService updates when date changes
- [ ] Context notes reflect the associated date

**Technical Tasks**:
- [ ] Update Conversation creation to accept optional date
- [ ] Modify ChatTabView to pass selectedDate
- [ ] Add date badge UI in ConversationRowView
- [ ] Implement date picker for changing association
- [ ] Update ChatContextService to use conversation date
- [ ] Add "Remove date" action in menu
- [ ] Test context switching when date changes
- [ ] Handle edge cases (date in future, very old dates)

**UI/UX Notes**:
- Date badge: Subtle, secondary color
- Relative dates for recent (Today, Yesterday)
- Absolute dates for older (Oct 9, 2025)
- Clear visual distinction: dated vs undated conversations

**Testing**:
- [ ] TC-S12-011: Create conversation from Calendar
- [ ] TC-S12-012: Date badge displays correctly
- [ ] TC-S12-013: Context loads for associated date
- [ ] TC-S12-014: Change conversation date
- [ ] TC-S12-015: Remove date association

---

### US-S12-004: Enhanced Context Display (2 points)

**As a user**, I want to see what notes the AI is using as context so I understand why it gives certain responses.

**Problem Statement**:
- Context section shows "Context for [date]" but not details
- Users don't know which notes AI read
- No transparency about context discovery
- Can't verify AI has correct information

**Requirements** (FR-610, FR-611, FR-612):
- Expandable context section (already exists)
- List all notes included in context
- Show excerpt from each note (first ~100 chars)
- Display note date and title
- Tap note → navigate to full entry
- Show why note was included (similarity, graph, date)
- "No context" state when no notes found

**Acceptance Criteria**:
- [ ] Context section expands to show note list
- [ ] Each note card shows: date, excerpt, discovery method
- [ ] Excerpt truncated to ~100 characters with "..."
- [ ] Note cards tappable → opens EntryDetailView
- [ ] Discovery method badge: "Today", "Same day", "Related"
- [ ] Empty state: "No notes for this date yet"
- [ ] Context updates when date/conversation changes
- [ ] Performance: Smooth expansion animation
- [ ] Accessible: VoiceOver support for note cards

**Technical Tasks**:
- [ ] Enhance context notes in ChatContext model
- [ ] Add note metadata: excerpt, discovery reason
- [ ] Create NoteContextCard view component
- [ ] Implement navigation to EntryDetailView from card
- [ ] Add discovery method enum and labels
- [ ] Update ChatContextService to provide metadata
- [ ] Handle empty states gracefully
- [ ] Test with various note counts (0, 1, 5, 15+)
- [ ] Add smooth expand/collapse animation

**UI/UX Notes**:
- Card design: Clean, scannable
- Discovery badges: Color-coded
  - 📅 Blue: "Today's note"
  - 🔄 Green: "Same day in past"
  - 🔗 Purple: "Related topic"
- Excerpt: Gray italic text
- Tap target: Whole card, not just text

**Testing**:
- [ ] TC-S12-016: Context expansion shows notes
- [ ] TC-S12-017: Note cards display correctly
- [ ] TC-S12-018: Tap note opens entry detail
- [ ] TC-S12-019: Discovery method badges
- [ ] TC-S12-020: Empty state handling

---

## Architecture Changes

### New Views
```swift
// Settings screen
SettingsView.swift
  - API key management section
  - Links to OpenRouter
  - Help documentation

// Enhanced components
NoteContextCard.swift
  - Note preview in context section
  - Tap to navigate
  - Discovery method badge
```

### Service Updates
```swift
// StreamingService enhancements
class StreamingService {
    func stopStreaming() // Cancel active SSE
    func regenerateMessage(message: ChatMessage) // Retry generation
}

// ChatContextService enhancements
class ChatContextService {
    struct ContextNote {
        var entry: Entry
        var excerpt: String
        var discoveryMethod: DiscoveryMethod
    }

    enum DiscoveryMethod {
        case todaysNote
        case sameDayHistory
        case relatedTopic
        case graphTraversal
    }
}

// ConversationService updates
class ConversationService {
    func updateAssociatedDate(conversation: Conversation, date: Date?)
    func regenerateLastMessage(conversation: Conversation)
}
```

### Model Enhancements
```swift
// Conversation model (no changes needed - already has associatedDate)
@Model
class Conversation {
    var associatedDate: Date? // Already exists
    // ... existing fields
}
```

---

## Technical Risks & Mitigation

| Risk | Impact | Mitigation | Priority |
|------|--------|------------|----------|
| SSE cancellation timing | Medium | Test stop with various response lengths | High |
| Context note navigation | Low | Use existing EntryDetailView navigation | Low |
| API key validation accuracy | Medium | Test with various key formats, add regex | High |
| Date association conflicts | Low | Clear UI for date management | Medium |
| Performance with many notes | Medium | Limit displayed notes, add pagination | Medium |

---

## Definition of Done

### Code Quality
- [ ] All acceptance criteria met for each US
- [ ] Code compiles without warnings
- [ ] Swift 6 concurrency compliance maintained
- [ ] Follows existing code patterns and style
- [ ] No memory leaks or retain cycles

### Testing
- [ ] All UI automation tests pass (XcodeBuildMCP)
- [ ] Test scenarios documented in `docs/03_testing/sprint_12_acceptance_tests.md`
- [ ] Manual testing completed for all user flows
- [ ] Edge cases identified and tested
- [ ] Performance benchmarks met

### Documentation
- [ ] Sprint planning updated with progress
- [ ] Test report completed with evidence
- [ ] Code comments for complex logic
- [ ] ADRs created if needed
- [ ] README updated if user-facing changes

### User Experience
- [ ] UI follows iOS Human Interface Guidelines
- [ ] Accessibility: VoiceOver support
- [ ] Error messages are user-friendly
- [ ] Loading states prevent confusion
- [ ] Animations are smooth (60fps)

---

## Success Metrics

### Performance Targets
- **Settings load time**: <500ms
- **API key validation**: <1s
- **Stop streaming**: <500ms response
- **Context expansion**: <200ms smooth animation
- **Note navigation**: <1s to entry detail

### Quality Targets
- **Test pass rate**: 100% (20/20 tests)
- **Bug count**: 0 critical, <3 minor
- **Code coverage**: >80% for new code
- **Accessibility score**: VoiceOver compatible

### User Experience Goals
- **API key setup**: <2 minutes for new users
- **Context transparency**: Users understand AI's knowledge
- **Control**: Users feel in control of AI responses
- **Navigation**: Seamless flow between features

---

## Dependencies

### External
- OpenRouter API stability
- iOS 18+ for SwiftData features
- Keychain services availability

### Internal
- Sprint 11 completion (✅ Complete)
- AIChatView_OLD as unified interface (✅ Complete)
- ChatContextService infrastructure (✅ Complete)
- ConversationService base functionality (✅ Complete)

---

## Sprint Schedule

### Week 1 (Oct 3-6, 2025)
**Day 1-2**: US-S12-001 (API Key Management)
- Design SettingsView UI
- Implement validation logic
- Test keychain integration

**Day 3-4**: US-S12-002 (Stop/Regenerate)
- Implement stop button
- Test SSE cancellation
- Add regenerate functionality

### Week 2 (Oct 7-10, 2025)
**Day 5-6**: US-S12-003 (Date Association)
- Update conversation creation
- Add date badge UI
- Test context switching

**Day 7-8**: US-S12-004 (Enhanced Context)
- Build NoteContextCard
- Implement navigation
- Polish animations

**Day 9-10**: Testing & Polish
- Run full test suite
- Fix any bugs found
- Update documentation
- Prepare for review

---

## Testing Strategy

### Unit Tests
- API key validation regex
- SSE cancellation logic
- Date association updates
- Context note formatting

### Integration Tests (XcodeBuildMCP)
- End-to-end API key setup flow
- Stop streaming during long response
- Create conversation with date from Calendar
- Expand context and navigate to notes
- Regenerate message flow

### Manual Testing
- Settings UI on various screen sizes
- Accessibility with VoiceOver
- Error handling (network failures)
- Edge cases (empty states, max limits)

### Performance Testing
- Settings load time measurement
- Stop latency monitoring
- Context expansion animation smoothness
- Memory usage during streaming

---

## Risks & Contingency Plans

### High Priority Risks

**Risk 1: Stop button doesn't cancel SSE reliably**
- **Probability**: Medium
- **Impact**: High (bad UX)
- **Mitigation**: Test with various network conditions, add timeout
- **Contingency**: Fallback to "ignore remaining tokens" approach

**Risk 2: API key validation too strict/loose**
- **Probability**: Low
- **Impact**: Medium (user frustration)
- **Mitigation**: Test with real OpenRouter keys, check their docs
- **Contingency**: Allow override, show warning instead of blocking

**Risk 3: Context note cards cause performance issues**
- **Probability**: Low
- **Impact**: Medium (slow UI)
- **Mitigation**: Limit to 15 notes max, lazy loading
- **Contingency**: Add pagination, show "Load more" button

---

## Sprint Retrospective Template

(To be filled at end of sprint)

### What Went Well
- [To be completed]

### What Could Be Improved
- [To be completed]

### Action Items for Next Sprint
- [To be completed]

### Metrics Achieved
- Story points delivered: __/8
- Test pass rate: __/20
- Sprint duration: __ days
- Bugs found: __ critical, __ minor

---

**Sprint Start**: October 3, 2025
**Sprint End**: TBD (Target: October 10, 2025)
**Sprint Review**: TBD
**Test Report**: [`docs/03_testing/sprint_12_acceptance_tests.md`](../03_testing/sprint_12_acceptance_tests.md)

---

## Next Steps

1. Begin US-S12-001: Create SettingsView
2. Set up XcodeBuildMCP test scenarios
3. Daily progress updates in this document
4. Create ADRs for significant decisions
