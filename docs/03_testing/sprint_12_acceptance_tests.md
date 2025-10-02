# Sprint 12 Acceptance Tests: Chat UX Improvements

**Test Date**: TBD (Target: October 10, 2025)
**Sprint**: Sprint 12 - Chat UX Improvements & Enhanced Context
**Tester**: Claude Code AI Assistant
**Device**: iPhone 16 Simulator (iOS 18.5)

## Test Overview

### User Stories Under Test
- **US-S12-001**: Production API Key Management (2 points)
- **US-S12-002**: Stop/Regenerate During Streaming (2 points)
- **US-S12-003**: Conversation Date Association (2 points)
- **US-S12-004**: Enhanced Context Display (2 points)

### Test Summary

| Category | Tests Planned | Tests Passed | Tests Failed | Notes |
|----------|---------------|--------------|--------------|-------|
| API Key Management | 5 | 0 | 0 | Not yet tested |
| Stop/Regenerate | 5 | 0 | 0 | Not yet tested |
| Date Association | 5 | 0 | 0 | Not yet tested |
| Enhanced Context | 5 | 0 | 0 | Not yet tested |
| **TOTAL** | **20** | **0** | **0** | **Sprint in progress** |

---

## US-S12-001: Production API Key Management

### Test Case 1: Settings Navigation
**Test ID**: TC-S12-001
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify settings screen is accessible from main navigation

**Pre-conditions**:
- App is installed and launched
- User is on any main screen

**Test Steps**:
1. **Locate Settings Access**
   - Check tab bar for Settings icon
   - OR check toolbar for Settings button
   - **Expected**: Settings access is clearly visible

2. **Navigate to Settings**
   - Tap Settings icon/button
   - **Expected**: Settings screen opens
   - **Expected**: Smooth transition animation

3. **Verify Settings UI**
   - Check for "API Key" section
   - **Expected**: API Key management section visible
   - **Expected**: Clean, iOS-standard layout

4. **Return to Previous Screen**
   - Tap back/done button
   - **Expected**: Returns to previous screen
   - **Expected**: Settings state preserved

**Success Criteria**:
- ✅ Settings accessible in ≤2 taps
- ✅ Navigation smooth and intuitive
- ✅ Back navigation works correctly

---

### Test Case 2: API Key Input and Validation
**Test ID**: TC-S12-002
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify API key input accepts text and validates format

**Pre-conditions**:
- Settings screen is open
- API key field is visible

**Test Steps**:
1. **Empty State**
   - View API key section when empty
   - **Expected**: Placeholder text visible
   - **Expected**: Help text explains what API key is
   - **Expected**: "Sign up for free" link visible

2. **Enter Invalid Key (too short)**
   - Tap API key field
   - Type: "sk-123"
   - **Expected**: Field accepts input
   - **Expected**: Validation error appears
   - **Expected**: Error: "API key must be at least 40 characters"

3. **Enter Invalid Key (wrong format)**
   - Clear field
   - Type: "invalid-key-format-12345678901234567890"
   - **Expected**: Validation error appears
   - **Expected**: Error: "Invalid OpenRouter API key format"

4. **Paste Valid Key**
   - Clear field
   - Paste valid OpenRouter key format
   - **Expected**: Field accepts paste
   - **Expected**: Validation shows loading
   - **Expected**: Success indicator appears

5. **Visual Feedback**
   - Check field border/background color
   - **Expected**: Red tint for invalid
   - **Expected**: Green tint for valid
   - **Expected**: Gray for neutral/loading

**Success Criteria**:
- ✅ Input accepts typing and paste
- ✅ Real-time validation (<1s)
- ✅ Clear visual states
- ✅ Error messages helpful

---

### Test Case 3: Show/Hide API Key Toggle
**Test ID**: TC-S12-003
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify API key can be shown/hidden for security

**Pre-conditions**:
- API key is entered in field

**Test Steps**:
1. **Default State (Hidden)**
   - View API key field with key entered
   - **Expected**: Key is masked (•••••)
   - **Expected**: Show/hide icon visible (👁)

2. **Show API Key**
   - Tap show/hide icon
   - **Expected**: Full key visible
   - **Expected**: Icon changes to hide state (👁‍🗨)

3. **Hide API Key**
   - Tap show/hide icon again
   - **Expected**: Key masked again
   - **Expected**: Icon returns to show state

4. **Security Test**
   - Show key
   - Navigate away from Settings
   - Return to Settings
   - **Expected**: Key is masked by default (security)

**Success Criteria**:
- ✅ Toggle works instantly
- ✅ Icons clear and intuitive
- ✅ Default state is masked
- ✅ State doesn't persist across navigation

---

### Test Case 4: Keychain Persistence
**Test ID**: TC-S12-004
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify API key persists across app restarts

**Pre-conditions**:
- Valid API key has been entered and saved

**Test Steps**:
1. **Save API Key**
   - Enter valid API key
   - Verify save confirmation
   - **Expected**: "API key saved" message
   - **Expected**: Success indicator

2. **Navigate Away**
   - Close Settings
   - Use other app features
   - **Expected**: App functions normally

3. **Force Quit App**
   - Close app completely (swipe up in app switcher)
   - **Expected**: App closes

4. **Relaunch App**
   - Open app again
   - Navigate to Settings
   - **Expected**: API key field shows masked key
   - **Expected**: No need to re-enter

5. **Test API Functionality**
   - Go to Chat tab
   - Send message
   - **Expected**: Uses saved API key
   - **Expected**: Message sends successfully

**Success Criteria**:
- ✅ Key persists across app restarts
- ✅ Keychain storage secure
- ✅ No re-authentication needed
- ✅ API calls work with saved key

---

### Test Case 5: Help Links and Onboarding
**Test ID**: TC-S12-005
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify help resources are accessible and useful

**Pre-conditions**:
- Settings screen is open
- API key section visible

**Test Steps**:
1. **Help Text Visibility**
   - View API key section
   - **Expected**: Clear explanation of what API key is
   - **Expected**: Instructions on where to get one

2. **Sign Up Link**
   - Locate "Sign up for free" link
   - **Expected**: Link is prominently displayed
   - **Expected**: Link color indicates it's tappable

3. **Tap Sign Up Link**
   - Tap "Sign up for free"
   - **Expected**: Opens OpenRouter signup in Safari
   - **Expected**: URL is correct: https://openrouter.ai/

4. **Help/Info Button**
   - Locate help icon (ⓘ or ?)
   - Tap help icon
   - **Expected**: Shows detailed instructions
   - **Expected**: Step-by-step guide
   - **Expected**: Easy to dismiss

5. **Empty State Onboarding**
   - View Settings when no key set
   - **Expected**: Friendly message
   - **Expected**: Clear call-to-action
   - **Expected**: Not intimidating for new users

**Success Criteria**:
- ✅ Help resources clear and accessible
- ✅ Links work correctly
- ✅ Instructions easy to follow
- ✅ New users can onboard successfully

---

## US-S12-002: Stop/Regenerate During Streaming

### Test Case 6: Stop During Streaming
**Test ID**: TC-S12-006
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify streaming can be stopped mid-response

**Pre-conditions**:
- Valid API key configured
- Chat interface open
- Ready to send message

**Test Steps**:
1. **Send Long Prompt**
   - Send message: "Tell me a detailed story about space exploration, make it very long"
   - **Expected**: Streaming starts
   - **Expected**: Tokens appear progressively

2. **Verify Stop Button Appears**
   - Check toolbar/message area
   - **Expected**: Stop button visible (⏹ or ✕)
   - **Expected**: Button is enabled (not grayed out)
   - **Expected**: Clear visual indicator of active streaming

3. **Tap Stop Button**
   - Wait for ~20-30 tokens to stream
   - Tap stop button
   - **Expected**: Streaming stops immediately (<500ms)
   - **Expected**: Button shows "Stopping..." feedback
   - **Expected**: No more tokens appear

4. **Verify Partial Message State**
   - Check AI message card
   - **Expected**: Partial response is visible
   - **Expected**: "Stopped by user" indicator shown
   - **Expected**: Message is in conversation history

5. **Send Another Message**
   - Send new message
   - **Expected**: New message works normally
   - **Expected**: No interference from stopped message

**Success Criteria**:
- ✅ Stop button appears when streaming active
- ✅ Stop takes <500ms
- ✅ Partial message preserved
- ✅ Can continue conversation after stop

---

### Test Case 7: Partial Message Handling
**Test ID**: TC-S12-007
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify partial messages display correctly

**Pre-conditions**:
- One or more stopped messages exist in conversation

**Test Steps**:
1. **Visual Differentiation**
   - View stopped message
   - **Expected**: Different styling than complete messages
   - **Expected**: "Stopped" badge or indicator
   - **Expected**: Faded or distinct background

2. **Message Content**
   - Read partial message content
   - **Expected**: All streamed tokens visible
   - **Expected**: No "..." or loading indicator
   - **Expected**: Content makes sense as partial response

3. **Persistence**
   - Close and reopen conversation
   - **Expected**: Stopped message still present
   - **Expected**: State preserved (shows as stopped)

4. **Scroll Behavior**
   - Scroll through conversation with stopped messages
   - **Expected**: Smooth scrolling
   - **Expected**: No UI glitches

**Success Criteria**:
- ✅ Stopped messages clearly indicated
- ✅ Content readable and sensible
- ✅ State persists correctly
- ✅ No visual glitches

---

### Test Case 8: Regenerate Last Message
**Test ID**: TC-S12-008
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify AI messages can be regenerated

**Pre-conditions**:
- Conversation with at least one AI response exists

**Test Steps**:
1. **Locate Regenerate Button**
   - View AI message card
   - Look for regenerate icon (🔄)
   - **Expected**: Button visible on AI messages
   - **Expected**: Not visible on user messages
   - **Expected**: Clear icon/label

2. **Tap Regenerate**
   - Tap regenerate button
   - **Expected**: Confirmation or immediate action
   - **Expected**: Loading indicator appears
   - **Expected**: Old message remains visible

3. **Watch Regeneration**
   - Observe new streaming response
   - **Expected**: New response streams in
   - **Expected**: Uses same user prompt
   - **Expected**: Can be different from original

4. **Verify Message History**
   - Check conversation after regeneration
   - **Expected**: Both old and new responses visible OR
   - **Expected**: Old response replaced with note
   - **Expected**: Conversation flow makes sense

5. **Test Stop During Regenerate**
   - Regenerate a message
   - Tap stop during regeneration
   - **Expected**: Regeneration stops
   - **Expected**: Can regenerate again

**Success Criteria**:
- ✅ Regenerate button easy to find
- ✅ Regeneration works reliably
- ✅ Uses correct prompt
- ✅ Can stop regeneration

---

### Test Case 9: Regenerate with Different Response
**Test ID**: TC-S12-009
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify regeneration can produce different responses

**Pre-conditions**:
- Conversation with AI response exists
- Response is deterministic prompt (not always same)

**Test Steps**:
1. **Send Varied Prompt**
   - Send: "Give me 3 creative ideas for a story"
   - Wait for response
   - Note the ideas provided

2. **Regenerate**
   - Tap regenerate on the response
   - Wait for new response
   - **Expected**: New response generated

3. **Compare Responses**
   - Compare old vs new ideas
   - **Expected**: Ideas are different (high probability)
   - **Expected**: Both responses valid
   - **Expected**: Quality similar

4. **Multiple Regenerations**
   - Regenerate 2-3 more times
   - **Expected**: Each response varies
   - **Expected**: No errors or rate limiting (within reason)
   - **Expected**: Performance stays consistent

**Success Criteria**:
- ✅ Regeneration produces variety
- ✅ Multiple regenerations work
- ✅ Quality consistent
- ✅ No technical errors

---

### Test Case 10: Edge Cases - Stop/Regenerate
**Test ID**: TC-S12-010
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Test edge cases and error conditions

**Pre-conditions**:
- Various test scenarios setup

**Test Steps**:
1. **Network Loss During Streaming**
   - Start streaming response
   - Disable network mid-stream
   - **Expected**: Graceful error message
   - **Expected**: Partial message preserved
   - **Expected**: Can retry when network returns

2. **Stop Very Short Response**
   - Send message that generates short response
   - Try to tap stop quickly
   - **Expected**: Works even if response is fast
   - **Expected**: OR message completes if too fast to stop

3. **Regenerate First Message**
   - Regenerate very first AI message in conversation
   - **Expected**: Works correctly
   - **Expected**: No special case bugs

4. **Rapid Stop/Send**
   - Stop a response
   - Immediately send new message
   - **Expected**: No race conditions
   - **Expected**: New message processes correctly

5. **Multiple Regenerations Without Stops**
   - Regenerate same message 5+ times
   - Don't stop any
   - **Expected**: No memory leaks
   - **Expected**: Performance stays good

**Success Criteria**:
- ✅ Handles network issues gracefully
- ✅ No race conditions
- ✅ No memory leaks
- ✅ Edge cases handled

---

## US-S12-003: Conversation Date Association

### Test Case 11: Create Conversation from Calendar
**Test ID**: TC-S12-011
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify conversation created from Calendar auto-links date

**Pre-conditions**:
- App open to Calendar view
- Specific date selected (e.g., October 9, 2025)

**Test Steps**:
1. **Select Date in Calendar**
   - Tap on October 9, 2025
   - **Expected**: Date is highlighted
   - **Expected**: Entry detail or create sheet opens

2. **Open Chat from Calendar**
   - Tap "Chat with AI" button
   - **Expected**: Chat opens
   - **Expected**: Context shows "Context for 9 Oct 2025"

3. **Send First Message**
   - Type: "What did I write today?"
   - Send message
   - **Expected**: AI responds with context from Oct 9

4. **Verify Date Association**
   - Open sidebar/conversation list
   - Find the new conversation
   - **Expected**: Conversation shows date badge "9 Oct"
   - **Expected**: Badge clearly visible

5. **Check Persistence**
   - Close app
   - Reopen app
   - Open conversation list
   - **Expected**: Date association still present

**Success Criteria**:
- ✅ Date auto-links when created from Calendar
- ✅ Date badge visible in conversation list
- ✅ Association persists
- ✅ Context matches date

---

### Test Case 12: Date Badge Display
**Test ID**: TC-S12-012
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify date badges display correctly in various formats

**Pre-conditions**:
- Multiple conversations with different dates exist

**Test Steps**:
1. **Today's Date**
   - Create conversation for today
   - View in conversation list
   - **Expected**: Badge shows "Today"
   - **Expected**: Special color/emphasis

2. **Yesterday's Date**
   - Create conversation for yesterday
   - **Expected**: Badge shows "Yesterday"

3. **This Week**
   - Create conversation for 3 days ago
   - **Expected**: Badge shows "Mon" or "3d ago"

4. **Older Dates**
   - Create conversation for Oct 1
   - **Expected**: Badge shows "1 Oct" or "Oct 1"

5. **No Date Association**
   - Create conversation from Chat tab (no date)
   - **Expected**: No date badge
   - **Expected**: Still distinguishable from dated conversations

**Success Criteria**:
- ✅ Date formats are relative and clear
- ✅ Today/Yesterday special cases
- ✅ Absolute dates for older
- ✅ Undated conversations clear

---

### Test Case 13: Context Loads for Associated Date
**Test ID**: TC-S12-013
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify context reflects conversation's associated date

**Pre-conditions**:
- Conversation with associated date exists
- Entry exists for that date

**Test Steps**:
1. **Open Date-Associated Conversation**
   - Open conversation linked to Oct 9
   - **Expected**: Context loads immediately
   - **Expected**: Shows "Context for 9 Oct 2025"

2. **Verify Context Content**
   - Expand context section
   - **Expected**: Shows Oct 9 entry
   - **Expected**: Shows historical Oct 9 entries (if any)
   - **Expected**: Correct date in all context notes

3. **Send Contextual Question**
   - Ask: "What was my mood on this day?"
   - **Expected**: AI references Oct 9 content
   - **Expected**: Response is date-specific

4. **Compare with Undated Conversation**
   - Open conversation without date
   - **Expected**: Context shows "Select a date" or current date
   - **Expected**: Different context than dated conversation

**Success Criteria**:
- ✅ Context matches conversation date
- ✅ Loads automatically
- ✅ AI responses use correct context
- ✅ Clear difference from undated

---

### Test Case 14: Change Conversation Date
**Test ID**: TC-S12-014
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify conversation date can be changed

**Pre-conditions**:
- Conversation with date exists

**Test Steps**:
1. **Open Date Change Menu**
   - Long press or tap menu on conversation
   - Look for "Change date" option
   - **Expected**: Option is visible and clear

2. **Select New Date**
   - Tap "Change date"
   - Date picker appears
   - Select October 15, 2025
   - **Expected**: Date picker is intuitive
   - **Expected**: Can select any date

3. **Confirm Change**
   - Confirm date change
   - **Expected**: Confirmation or immediate update
   - **Expected**: Badge updates to "15 Oct"

4. **Verify Context Update**
   - Open the conversation
   - **Expected**: Context now shows Oct 15
   - **Expected**: Context notes updated
   - **Expected**: Smooth transition

5. **Test with Future Date**
   - Change to future date (Oct 20, 2025)
   - **Expected**: Works correctly
   - **Expected**: Context shows "No note for this date yet"

**Success Criteria**:
- ✅ Date can be changed easily
- ✅ Context updates accordingly
- ✅ Badge reflects new date
- ✅ Future dates handled

---

### Test Case 15: Remove Date Association
**Test ID**: TC-S12-015
**Priority**: Low
**Status**: ⏳ NOT STARTED

**Objective**: Verify date can be removed from conversation

**Pre-conditions**:
- Conversation with date association exists

**Test Steps**:
1. **Access Remove Option**
   - Open conversation menu
   - Look for "Remove date" option
   - **Expected**: Option available for dated conversations

2. **Remove Date**
   - Tap "Remove date"
   - **Expected**: Confirmation dialog OR immediate action
   - **Expected**: Clear what will happen

3. **Verify Badge Removed**
   - Check conversation list
   - **Expected**: Date badge gone
   - **Expected**: Conversation still in list

4. **Verify Context Behavior**
   - Open the conversation
   - **Expected**: Context shows current date OR no specific date
   - **Expected**: Generic context loaded

5. **Re-Associate Date**
   - Change date back to Oct 9
   - **Expected**: Can re-link date
   - **Expected**: Works as before

**Success Criteria**:
- ✅ Can remove date association
- ✅ Badge removed from UI
- ✅ Context behavior changes appropriately
- ✅ Can re-associate later

---

## US-S12-004: Enhanced Context Display

### Test Case 16: Context Expansion Shows Notes
**Test ID**: TC-S12-016
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify context section expands to show note details

**Pre-conditions**:
- Conversation with date association exists
- Multiple entries exist for that date and related dates

**Test Steps**:
1. **Initial Collapsed State**
   - Open conversation
   - View context section at top
   - **Expected**: Shows "Context for [date]"
   - **Expected**: Shows note count "3 notes"
   - **Expected**: Chevron or expand indicator

2. **Expand Context**
   - Tap context section
   - **Expected**: Smooth expand animation
   - **Expected**: Note cards appear

3. **View Note List**
   - Count visible note cards
   - **Expected**: All context notes displayed
   - **Expected**: List is scrollable if many notes
   - **Expected**: Maximum 15 notes (as per design)

4. **Collapse Context**
   - Tap section header again
   - **Expected**: Smooth collapse animation
   - **Expected**: Returns to compact state

5. **State Persistence**
   - Expand context
   - Navigate away and back
   - **Expected**: Context starts collapsed (default)

**Success Criteria**:
- ✅ Expand/collapse works smoothly
- ✅ All notes displayed
- ✅ Animation smooth (<200ms)
- ✅ State handled correctly

---

### Test Case 17: Note Cards Display Correctly
**Test ID**: TC-S12-017
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify note cards show correct information

**Pre-conditions**:
- Context expanded
- Multiple notes visible

**Test Steps**:
1. **Card Layout**
   - View a note card
   - **Expected**: Clean, card-like design
   - **Expected**: Clear visual boundaries
   - **Expected**: Proper spacing

2. **Date Display**
   - Check date on card
   - **Expected**: Shows note date
   - **Expected**: Format: "9 Oct 2025" or relative
   - **Expected**: Easily scannable

3. **Excerpt Display**
   - Read excerpt text
   - **Expected**: Shows ~100 characters
   - **Expected**: Ends with "..." if truncated
   - **Expected**: Text is readable (not too small)

4. **Discovery Badge**
   - Check badge on card
   - **Expected**: Shows discovery method
   - **Expected**: Color coded:
     - Blue: "Today" 📅
     - Green: "Same day" 🔄
     - Purple: "Related" 🔗
   - **Expected**: Icon + text or just text

5. **Multiple Cards**
   - View all cards in list
   - **Expected**: Consistent styling
   - **Expected**: Easy to distinguish between cards
   - **Expected**: Scrollable if >5 cards

**Success Criteria**:
- ✅ Cards display all required info
- ✅ Typography readable
- ✅ Discovery methods clear
- ✅ Layout clean and consistent

---

### Test Case 18: Tap Note Opens Entry Detail
**Test ID**: TC-S12-018
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify tapping note card navigates to full entry

**Pre-conditions**:
- Context expanded with note cards visible

**Test Steps**:
1. **Tap First Note Card**
   - Tap anywhere on card
   - **Expected**: Navigation animation
   - **Expected**: EntryDetailView opens

2. **Verify Correct Entry**
   - Check entry content
   - **Expected**: Shows full entry matching card date
   - **Expected**: Content matches excerpt from card

3. **Return to Chat**
   - Tap back/done
   - **Expected**: Returns to chat
   - **Expected**: Context still expanded (or collapsed - document behavior)

4. **Tap Different Card**
   - Tap another note card
   - **Expected**: Opens different entry
   - **Expected**: Correct entry for that date

5. **Test from Chat Tab**
   - Open conversation from Chat tab
   - Expand context, tap note
   - **Expected**: Works same as from Calendar

**Success Criteria**:
- ✅ Cards are fully tappable
- ✅ Navigation works reliably
- ✅ Correct entry opens
- ✅ Back navigation smooth

---

### Test Case 19: Discovery Method Badges
**Test ID**: TC-S12-019
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify discovery method badges are accurate and meaningful

**Pre-conditions**:
- Conversation with multiple context notes
- Notes discovered via different methods

**Test Steps**:
1. **Today's Note Badge**
   - Find card for today's entry
   - **Expected**: Badge: "Today" or "📅 Today"
   - **Expected**: Blue color/emphasis

2. **Same Day History Badge**
   - Find card for same day in past year
   - **Expected**: Badge: "Same day" or "🔄 9 Oct 2024"
   - **Expected**: Green color

3. **Related Topic Badge**
   - Find card discovered by similarity
   - **Expected**: Badge: "Related" or "🔗 Related"
   - **Expected**: Purple color

4. **Badge Consistency**
   - View all badges
   - **Expected**: Consistent positioning (top-right or bottom)
   - **Expected**: Clear visual hierarchy
   - **Expected**: Don't overwhelm card design

5. **Badge Information Value**
   - Read badges while using app
   - **Expected**: Helps understand why note was included
   - **Expected**: Builds trust in AI's context selection

**Success Criteria**:
- ✅ Badges accurately reflect discovery method
- ✅ Color coding clear and consistent
- ✅ Visual design clean
- ✅ Adds value to user understanding

---

### Test Case 20: Empty State Handling
**Test ID**: TC-S12-020
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify empty state displays correctly when no context available

**Pre-conditions**:
- Conversation for date with no entries exists

**Test Steps**:
1. **No Entry for Date**
   - Create conversation for empty date
   - **Expected**: Context shows "No notes for this date"
   - **Expected**: Helpful message, not error

2. **Expand Empty Context**
   - Tap to expand context
   - **Expected**: Expands gracefully
   - **Expected**: Shows empty state illustration or message
   - **Expected**: Suggests creating a note

3. **Create Note Link**
   - Look for "Create note" or similar CTA
   - **Expected**: Link to create entry for that date
   - OR: Message explaining how to add notes

4. **Add Note and Refresh**
   - Create note for the date
   - Return to conversation
   - **Expected**: Context updates automatically
   - OR: Can manually refresh

5. **Undated Conversation**
   - Open conversation without date
   - **Expected**: Context shows generic message
   - **Expected**: Suggests linking to a date

**Success Criteria**:
- ✅ Empty states friendly and helpful
- ✅ Clear guidance for users
- ✅ No confusing errors
- ✅ Graceful handling

---

## Test Environment

### Device Configuration
- **Device**: iPhone 16 Simulator
- **iOS Version**: 18.5
- **App Version**: Sprint 12 Development Build
- **Network**: Simulator network environment
- **API**: OpenRouter service with Gemini 2.0 Flash

### Required Test Data
- Valid OpenRouter API key
- Multiple journal entries across different dates
- Conversations with various configurations:
  - Dated conversations
  - Undated conversations
  - Conversations with many messages
  - Empty conversations

---

## Performance Requirements

### Response Time Targets
- **Settings Load**: <500ms
- **API Key Validation**: <1s
- **Stop Streaming**: <500ms response time
- **Context Expansion**: <200ms animation
- **Note Card Navigation**: <1s to entry detail

### Memory & Resource Usage
- **Memory**: No leaks during streaming operations
- **Battery**: Minimal impact during normal usage
- **Network**: Efficient SSE connection management

---

## Accessibility Requirements

### VoiceOver Support
- [ ] All buttons labeled clearly
- [ ] Note cards have descriptive labels
- [ ] State changes announced
- [ ] Navigation hints provided

### Visual Accessibility
- [ ] Sufficient contrast ratios (WCAG AA)
- [ ] Text resizing supported
- [ ] No reliance on color alone
- [ ] Touch targets ≥44pt

---

## Success Criteria

### Functional Requirements
- [ ] All 20 test cases pass
- [ ] All user stories meet acceptance criteria
- [ ] No critical bugs found
- [ ] Edge cases handled gracefully

### Technical Requirements
- [ ] Code follows Swift/SwiftUI best practices
- [ ] No regressions in Sprint 11 features
- [ ] Performance targets met
- [ ] Memory usage stable

### Quality Gates
- [ ] **Build Success**: All targets compile without errors
- [ ] **UI Testing**: XcodeBuildMCP automation scenarios pass
- [ ] **Manual Testing**: All acceptance scenarios validated
- [ ] **Performance**: Response times within requirements
- [ ] **Accessibility**: VoiceOver compatible

---

## Test Execution Log

**Latest Execution Date**: TBD
**Test Environment**: iPhone 16 Simulator (iOS 18.5)
**Execution Method**: XcodeBuildMCP Automation + Manual Verification

### Test Results Summary

(To be filled during sprint execution)

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC-S12-001 | ⏳ NOT STARTED | Settings navigation |
| TC-S12-002 | ⏳ NOT STARTED | API key validation |
| TC-S12-003 | ⏳ NOT STARTED | Show/hide toggle |
| TC-S12-004 | ⏳ NOT STARTED | Keychain persistence |
| TC-S12-005 | ⏳ NOT STARTED | Help links |
| TC-S12-006 | ⏳ NOT STARTED | Stop during streaming |
| TC-S12-007 | ⏳ NOT STARTED | Partial message handling |
| TC-S12-008 | ⏳ NOT STARTED | Regenerate message |
| TC-S12-009 | ⏳ NOT STARTED | Regenerate variety |
| TC-S12-010 | ⏳ NOT STARTED | Edge cases |
| TC-S12-011 | ⏳ NOT STARTED | Create from Calendar |
| TC-S12-012 | ⏳ NOT STARTED | Date badge display |
| TC-S12-013 | ⏳ NOT STARTED | Context loads |
| TC-S12-014 | ⏳ NOT STARTED | Change date |
| TC-S12-015 | ⏳ NOT STARTED | Remove date |
| TC-S12-016 | ⏳ NOT STARTED | Context expansion |
| TC-S12-017 | ⏳ NOT STARTED | Note cards |
| TC-S12-018 | ⏳ NOT STARTED | Tap navigation |
| TC-S12-019 | ⏳ NOT STARTED | Discovery badges |
| TC-S12-020 | ⏳ NOT STARTED | Empty states |

---

## Issues Found

(To be filled during testing)

### Issue Template
**Issue #**: [Number]
**Severity**: [Critical/High/Medium/Low]
**Test Case**: [TC-ID]
**Description**: [What went wrong]
**Steps to Reproduce**: [How to reproduce]
**Expected**: [What should happen]
**Actual**: [What actually happened]
**Status**: [Open/Fixed/Wontfix]

---

## Notes

- Test execution will begin once US-S12-001 implementation is complete
- UI automation testing will use XcodeBuildMCP tools
- Performance testing will include memory profiling
- Accessibility testing will include VoiceOver validation
- Real API key required for full streaming tests

---

**Test Plan Created**: October 2, 2025
**Sprint Target**: October 10, 2025
**Related Sprint Plan**: [`docs/01_sprints/sprint_12_planning.md`](../01_sprints/sprint_12_planning.md)
