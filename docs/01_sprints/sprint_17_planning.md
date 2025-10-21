# Sprint 17: Flexible Model Configuration & Export System

**Sprint Period**: October 11-13, 2025
**Epic**: EPIC-7 - User Empowerment & Data Portability
**Story Points**: 9 points (2 user stories)
**Status**: 🔄 IN PROGRESS (Part 1 Complete, Part 2 Deferred)

## Sprint Goal
Empower users with flexible AI model selection for chat conversations and comprehensive data export/import capabilities, ensuring user control over both AI experience and data ownership.

**Strategic Value**: Users can optimize their AI chat experience by choosing models that best fit their needs (cost, quality, speed), while export/import features build trust through data portability and protection against data loss.

---

## User Stories

### US-S16-002: Flexible Model Configuration (3 points)

**As a** user
**I want** to configure which AI model is used for chat conversations
**So that** I can choose models that best fit my needs (cost, quality, speed)

**Priority**: HIGH
**Status**: ✅ COMPLETED (2025-10-13)

**Problem Statement**:
- Currently hardcoded to specific OpenAI models
- OpenRouter supports 200+ models but we're not leveraging this
- Different users have different needs (cost-conscious, quality-focused, speed-focused)
- Users cannot experiment with new models as they become available

**Solution Approach**:
1. Add model configuration in chat settings
2. Allow users to enter any OpenRouter-supported model identifier
3. Validate model availability through OpenRouter API
4. Persist user's model choice per conversation
5. Keep entity extraction and relationship discovery on fixed models for stability

**Scope Clarification**:
- ✅ Model configuration for chat conversations ONLY
- ❌ Entity extraction remains on fixed model (gpt-4o-mini for stability)
- ❌ Relationship discovery remains on fixed model (gpt-4o-mini for stability)
- ✅ Per-conversation model selection (different conversations can use different models)

**Acceptance Criteria**:
- [x] Users can enter custom model identifier in chat settings
- [x] System validates model format (provider/model-name pattern)
- [x] Model choice persisted per conversation
- [x] Helpful error messages if model format invalid
- [x] Default model: gpt-4o-mini (current default)
- [x] Chat UI shows which model is being used (model badge)
- [x] Entity extraction and relationship discovery remain on gpt-4o-mini

**Technical Requirements**:

**FR-S17-001: Model Configuration UI**
- Add "AI Model" field in conversation settings
- Dropdown with popular models + custom text input option
- Popular models:
  - GPT-4o-mini (default, cost-effective)
  - GPT-4o (higher quality)
  - Claude 3.5 Sonnet (high quality alternative)
  - Claude 3 Haiku (fast & cheap)
  - Llama 3.1 70B (open source)
- Custom input accepts any OpenRouter model ID
- Show model description and pricing info if available

**FR-S17-002: Model Validation**
- Validate model ID format: `provider/model-name`
- Query OpenRouter `/models` endpoint for validation
- Cache valid model list (1 hour TTL)
- Show error toast if model invalid/unavailable
- Fallback to default if validation fails during chat

**FR-S17-003: Model Persistence**
- Add `modelIdentifier: String?` to `Conversation` model
- Default: nil (uses system default gpt-4o-mini)
- Store user's choice when explicitly selected
- Load model identifier when resuming conversation

**FR-S17-004: Chat Integration**
- Update `AIChatService.sendMessage()` to use conversation's model
- Pass model identifier in OpenRouter API request
- Display current model in chat header (small badge)
- Handle model-specific errors gracefully

**Technical Tasks**:
- [x] Update `Conversation` model with `modelIdentifier` field
- [x] Create `ModelConfigurationView` for model selection UI
- [x] Implement OpenRouter model validation service
- [x] Update `AIChatView` to use conversation-specific model
- [x] Add model display badge in chat UI
- [x] Integration test: Chat with different models (XcodeBuildMCP automated test)
- [x] Error handling: Model format validation with clear messages
- [x] Fix conversation persistence in AIChatView (added ensureConversationExists)
- [x] Fix SwiftData predicate error (use in-memory filtering)
- [x] Implement CPU button polling to enable model configuration access

**Files Created**:
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/Chat/ModelConfigurationView.swift` (236 lines)
- ✅ `KiokuPackage/Sources/KiokuFeature/Services/ModelValidationService.swift` (169 lines)

**Files Modified**:
- ✅ `KiokuPackage/Sources/KiokuFeature/Models/Conversation.swift` - Added modelIdentifier field
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/Chat/AIChatView.swift` - Model parameter, badge UI, conversation persistence
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/Chat/ChatTabView.swift` - CPU button, lazy conversation creation, model config sheet
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/EntryDetailView.swift` - CPU button in note detail chat, conversation management
- ✅ `KiokuPackage/Sources/KiokuFeature/Services/DataService.swift` - Fixed fetchConversation predicate error

**Implementation Summary**:
- ✅ Model configuration UI with 5 popular presets
- ✅ Custom model ID validation (format: provider/model-name)
- ✅ Model badge displays in chat UI (CPU icon + model name)
- ✅ Per-conversation model persistence
- ✅ Default model: openai/gpt-4o-mini
- ✅ CPU button always enabled with lazy conversation creation
- ✅ CPU button available in both Calendar tab and Note Detail chat
- ✅ Conversation/message persistence added to AIChatView
- ✅ SwiftData predicate fixed with in-memory filtering
- ✅ Full end-to-end integration test passed with XcodeBuildMCP

**Known Limitations**:
- No real-time API availability check (format validation only)
- No model-specific error parsing from OpenRouter
- No per-message model override (conversation-level only)

**Dependencies**:
- Sprint 10: AI Chat Integration ✅
- OpenRouter API `/models` endpoint

**Definition of Done**:
- [x] Code compiles and app builds successfully
- [x] Users can select from popular models or enter custom model ID
- [x] Model validation works (format validation)
- [x] Model choice persisted per conversation
- [x] Chat uses selected model for API calls
- [x] Error handling for invalid/unavailable models
- [x] Entity extraction still uses gpt-4o-mini (not affected)
- [x] XcodeBuildMCP integration test passed (full workflow validated)
- [x] All changes committed and pushed
- [x] Sprint planning document updated

---

### US-046: Export & Backup (6 points)

**As a** user
**I want** to export all my journal data to external files
**So that** I can backup my data and have peace of mind about data portability

**Priority**: HIGH
**Status**: ✅ COMPLETED (2025-10-21)

**Problem Statement**:
- Users have no way to backup their journal data
- Concern about losing data if app deleted or device lost
- No data portability if users want to switch apps
- Trust issue: Users feel "locked in" to the app

**Solution Approach**:
1. Export all entries to JSON format (structured, machine-readable)
2. Export to Markdown format (human-readable, preserves formatting)
3. Include all metadata: entities, relationships, insights
4. Save to Files app (iOS standard file picker)
5. Import from JSON for data restoration

**Acceptance Criteria**:
- [x] Export all entries to JSON format with complete metadata
- [x] Export to Markdown format (human-readable)
- [x] JSON includes: entries, entities, relationships, insights, conversations
- [x] Markdown organized by date with sections for each entry
- [x] Export triggers iOS file save dialog (Files app integration)
- [x] Import from JSON validates and restores data
- [x] Import handles conflicts gracefully (skip duplicates or merge)
- [x] Progress indicator during export/import for large datasets
- [x] Export/import accessible from Settings

**Technical Requirements**:

**FR-S17-005: JSON Export Format**
```json
{
  "version": "1.0",
  "exported_at": "2025-10-11T10:30:00Z",
  "entries": [
    {
      "id": "uuid",
      "date": "2025-10-11",
      "content": "encrypted or plain based on user setting",
      "created_at": "2025-10-11T09:00:00Z",
      "modified_at": "2025-10-11T09:30:00Z",
      "entities": [
        {
          "id": "uuid",
          "type": "people",
          "value": "Minh",
          "confidence": 0.95
        }
      ],
      "relationships": [
        {
          "from_entity": "uuid",
          "to_entity": "uuid",
          "type": "causal",
          "confidence": 0.8
        }
      ],
      "insights": [
        {
          "type": "temporal",
          "description": "Weekly pattern detected",
          "confidence": 0.75
        }
      ]
    }
  ],
  "conversations": [
    {
      "id": "uuid",
      "created_at": "2025-10-11T10:00:00Z",
      "messages": [
        {
          "role": "user",
          "content": "How am I doing?",
          "timestamp": "2025-10-11T10:00:00Z"
        }
      ]
    }
  ]
}
```

**FR-S17-006: Markdown Export Format**
```markdown
# Journal Export - October 11, 2025

## October 11, 2025

Today I met with Minh to discuss the project...

**Entities**: Minh (Person), Project Alpha (Topic)
**Insights**: Working on weekends pattern

---

## October 10, 2025

...
```

**FR-S17-007: Export Service**
- Create `ExportService` with async export methods
- Progress tracking: 0-100% for large datasets
- Error handling: Disk space, permissions, encryption
- Chunked export for large datasets (avoid memory issues)

**FR-S17-008: Import Service**
- Create `ImportService` with JSON validation
- Detect duplicate entries by ID or date+content hash
- Conflict resolution:
  - Skip duplicates (default)
  - Merge: keep newer modified_at timestamp
  - Replace: overwrite existing
- Restore relationships correctly (UUID mapping)

**FR-S17-009: Settings Integration**
- Add "Data Management" section in Settings
- "Export to JSON" button
- "Export to Markdown" button
- "Import from JSON" button
- Show last export/import timestamp
- Show storage usage stats

**Technical Tasks**:
- [x] Create `ExportService` with JSON/Markdown formatters
- [x] Create `ImportService` with validation and conflict resolution
- [x] Add SwiftUI `FileExporter` for save dialog
- [x] Add SwiftUI `FileImporter` for open dialog
- [x] Update Settings view with Data Management section
- [x] Add progress indicator UI for long exports
- [x] Handle encryption: export plain or encrypted based on user choice
- [x] Integration test: Export → Import → Verify data integrity

**Files to Create**:
- `KiokuPackage/Sources/KiokuFeature/Services/ExportService.swift`
- `KiokuPackage/Sources/KiokuFeature/Services/ImportService.swift`
- `KiokuPackage/Sources/KiokuFeature/Views/Settings/DataManagementView.swift`

**Files to Modify**:
- `KiokuApp/Views/SettingsView.swift`

**Dependencies**:
- SwiftData models stable (Entry, Entity, Relationship, Insight, Conversation)
- FileExporter/FileImporter available in iOS 17+

**Definition of Done**:
- [x] Export to JSON includes all data with complete metadata
- [x] Export to Markdown is human-readable
- [x] Import validates JSON schema
- [x] Import handles duplicates gracefully
- [x] Progress indicators work for large datasets
- [x] File save/open dialogs work correctly
- [x] XcodeBuildMCP integration test: Export → Delete all → Import → Verify
- [ ] All changes committed and pushed
- [ ] Sprint planning document updated

---

## Testing Strategy

### Unit Tests
- Model validation (Conversation with modelIdentifier)
- Export JSON format validation
- Markdown formatting correctness
- Import duplicate detection logic

### Integration Tests

**Test 1: Flexible Model Configuration**
1. Build and run app
2. Create new conversation
3. Open model settings
4. Select Claude 3.5 Sonnet
5. Send chat message
6. Verify API call uses correct model
7. Close and reopen conversation
8. Verify model persisted

**Test 2: Export to JSON**
1. Create 5-10 test entries with entities and relationships
2. Navigate to Settings → Data Management
3. Tap "Export to JSON"
4. Save to Files app
5. Verify JSON file created
6. Read file and validate structure

**Test 3: Import from JSON**
1. Export data to JSON (Test 2)
2. Delete all data in app
3. Navigate to Settings → Data Management
4. Tap "Import from JSON"
5. Select exported file
6. Verify all entries, entities, relationships restored
7. Verify AI chat still works with restored data

**Test 4: Markdown Export**
1. Create entries with various content
2. Export to Markdown
3. Open in text editor
4. Verify human-readable formatting
5. Check date grouping and metadata display

### XcodeBuildMCP Test Scenarios

**Scenario 1**: Model Configuration Workflow
```swift
// 1. Launch app
build_run_sim()

// 2. Navigate to chat
tap(x: chatTab, y: chatTab)

// 3. Open model settings
tap(x: settingsButton, y: settingsButton)

// 4. Select model from dropdown
tap(x: modelDropdown, y: modelDropdown)
tap(x: claudeOption, y: claudeOption)

// 5. Send test message
type_text("Hello, test message")
tap(x: sendButton, y: sendButton)

// 6. Verify response received
screenshot() // Visual verification
```

**Scenario 2**: Export-Import Round Trip
```swift
// 1. Launch app with test data
build_run_sim()

// 2. Navigate to Settings
tap(x: settingsTab, y: settingsTab)
tap(x: dataManagement, y: dataManagement)

// 3. Export to JSON
tap(x: exportButton, y: exportButton)
// File picker appears - automated testing limited here

// 4. Clear all data
tap(x: clearDataButton, y: clearDataButton)
tap(x: confirmButton, y: confirmButton)

// 5. Import from JSON
tap(x: importButton, y: importButton)
// Select file - automated testing limited here

// 6. Verify data restored
tap(x: calendarTab, y: calendarTab)
screenshot() // Verify entries visible
```

---

## Success Metrics

- **Model Flexibility**: Users can successfully use 3+ different models
- **Export Completeness**: 100% of user data included in exports
- **Import Accuracy**: Imported data matches exported data (no loss)
- **User Trust**: Export feature increases confidence in app
- **Performance**: Export/Import < 10 seconds for 100 entries

---

## Technical Notes

### Model Configuration Decisions

**Why Per-Conversation Model Selection?**
- Users may want different models for different types of conversations
- Example: Quick daily check-in (fast, cheap model) vs deep reflection (high-quality model)
- Flexibility without overwhelming default settings

**Why Fixed Models for Entity Extraction?**
- Consistency: All entries processed with same model ensures consistent entity quality
- Cost: Batch processing requires cost-effective model
- Stability: Entity extraction prompts optimized for specific model behavior
- Future: Can make configurable later if needed

### Export/Import Design Decisions

**Why JSON + Markdown?**
- JSON: Machine-readable, complete metadata, import capability
- Markdown: Human-readable, nice formatting, no import (read-only)
- Both formats serve different user needs

**Why Include Encrypted Content?**
- User choice: Export with encryption (secure) or plain text (readable)
- Default: Encrypted (preserve security)
- Warning: Plain text export warns about security implications

**Import Conflict Resolution**:
- Default: Skip duplicates (safest)
- Advanced: User can choose merge or replace
- Duplicate detection: UUID match or content hash match

---

## Sprint Retrospective

**Status**: Sprint 17 Part 1 - COMPLETED (2025-10-13)
- ✅ Part 1: Flexible Model Configuration (3 points) - COMPLETED
- ⏳ Part 2: Export & Backup (6 points) - DEFERRED to next sprint

**What Went Well**:
- ✅ Model configuration feature fully implemented and tested
- ✅ Full end-to-end integration test with XcodeBuildMCP automation
- ✅ All bugs discovered during testing were fixed (conversation persistence, SwiftData predicate)
- ✅ Clear separation of concerns (Service, View, Model)
- ✅ Good documentation created (test scenarios, design docs)
- ✅ UI/UX polished with model badge and CPU button

**What Could Be Improved**:
- ⚠️ No unit tests created (validation logic should have tests)
- ⚠️ Debug logging left in code (should be removed or made conditional)

**Bugs Fixed During Testing**:
1. **Conversation persistence missing in AIChatView** - Added ensureConversationExists() and message persistence
2. **SwiftData predicate error with captured variables** - Switched to in-memory filtering
3. **CPU button disabled state** - Implemented polling mechanism to detect conversation creation
4. **CPU button always disabled for new dates** - Removed `.disabled(currentConversation == nil)`, added ensureConversationExists() on button tap
5. **CPU button missing from Note Detail chat** - Added CPU button to EntryDetailView sheet toolbar with conversation management

**Key Learnings**:
1. **SwiftUI @Bindable**: Works well for conversation model binding in configuration view
2. **SwiftData Predicates**: Cannot use captured variables in comparisons - use in-memory filtering instead
3. **Lazy Conversation Creation**: Create on demand (button tap) rather than first message - better UX
4. **Button State Management**: Always-enabled buttons with lazy resource creation work better than disabled states
5. **Consistent UX**: Ensure feature parity across all entry points (Calendar tab and Note Detail)
6. **XcodeBuildMCP Testing**: Full UI automation possible - caught bugs that manual testing might miss

**Technical Decisions**:
- ✅ Store modelIdentifier as optional String in Conversation
- ✅ Validate format only (no API availability check for MVP)
- ✅ Display model badge when conversation has custom model
- ✅ Use ModelValidationService.popularModels for presets
- ✅ Lazy conversation creation on CPU button tap (better than polling)
- ✅ In-memory filtering for date-based queries (SwiftData predicate limitation)
- ✅ Consistent CPU button implementation across all chat entry points

---

**Document Control**

- **Version**: 1.0
- **Author**: AI Assistant
- **Reviewed**: Pending
- **Approved**: Pending
- **Next Review**: After sprint completion
