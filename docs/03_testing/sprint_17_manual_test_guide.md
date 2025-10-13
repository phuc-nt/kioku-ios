# Sprint 17 Part 1: Manual Testing Guide
**Feature**: Flexible AI Model Configuration
**Date**: October 13, 2025
**Tester**: Manual validation required

---

## Pre-Test Setup

### Requirements:
- ✅ Xcode project built successfully
- ✅ iPhone simulator running (iPhone 16 or similar)
- ✅ OpenRouter API key configured in app
- ✅ Clean app state (optional: reset simulator for fresh start)

### Test Data Preparation:
No special test data needed. App will create conversations on the fly.

---

## Test Case 1: CPU Button Behavior

### Objective:
Verify that the CPU button (model configuration) is properly disabled/enabled based on conversation state.

### Steps:
1. **Launch App**
   - Open Kioku app in simulator
   - Navigate to Calendar tab (should be default)

2. **Switch to Chat Tab**
   - Tap on "Chat" tab at bottom
   - Observe the navigation bar

3. **Verify Initial State**
   - ✅ **Expected**: CPU button (🖥️ icon) in top-right corner is **DISABLED** (grayed out)
   - ❌ **Fail If**: Button is enabled before any messages sent

4. **Send First Message**
   - Tap on text field at bottom
   - Type: "Hello, this is a test message"
   - Tap send button (↑ arrow icon)

5. **Wait for AI Response**
   - Wait ~5-10 seconds for AI to respond
   - ✅ **Expected**: AI response appears with streaming effect

6. **Check CPU Button After Message**
   - Wait 2-3 seconds (polling interval)
   - ✅ **Expected**: CPU button becomes **ENABLED** (full color)
   - ❌ **Fail If**: Button remains disabled after 5+ seconds

### Acceptance Criteria:
- [x] CPU button disabled when no conversation exists
- [x] CPU button enables within 2-3 seconds after first message sent
- [x] Button state persists when navigating away and back

### Notes:
- The 2-3 second delay is by design (polling mechanism)
- If button doesn't enable, check database for conversation creation

---

## Test Case 2: Model Configuration UI

### Objective:
Verify that ModelConfigurationView displays correctly and allows model selection.

### Prerequisites:
- CPU button must be enabled (complete Test Case 1 first)

### Steps:
1. **Open Model Configuration**
   - Tap the CPU button (🖥️) in top-right corner
   - ✅ **Expected**: Sheet slides up from bottom with "AI Model Configuration" title

2. **Verify UI Elements**
   Check that the following are visible:
   - ✅ Title: "AI Model Configuration"
   - ✅ Section header: "ABOUT AI MODELS"
   - ✅ Description text explaining model selection
   - ✅ Section header: "SELECT MODEL"
   - ✅ List of 5 models with checkmark on current selection

3. **Verify Model List**
   Confirm all 5 models are displayed:
   - ✅ **GPT-4o Mini** - OpenAI, $0.15/M tokens, "DEFAULT" badge
   - ✅ **GPT-4o** - OpenAI, $2.50/M tokens
   - ✅ **Claude 3.5 Sonnet** - Anthropic, $3.00/M tokens
   - ✅ **Claude 3 Haiku** - Anthropic, $0.25/M tokens
   - ✅ **Llama 3.1 70B** - Meta, $0.35/M tokens

4. **Verify Default Selection**
   - ✅ **Expected**: Blue checkmark (✓) next to **GPT-4o Mini**
   - ✅ **Expected**: "DEFAULT" badge displayed for GPT-4o Mini

5. **Scroll to Bottom**
   - Scroll down to see all models
   - ✅ **Expected**: "Custom Model" section visible
   - ✅ **Expected**: Text about entity extraction consistency
   - ✅ **Expected**: Note about model scope

### Acceptance Criteria:
- [x] Sheet displays with correct title and content
- [x] All 5 popular models shown with pricing
- [x] Default model (GPT-4o Mini) has checkmark
- [x] UI is scrollable to see all content
- [x] Cancel and Save buttons visible

### Notes:
- Don't tap Save yet - we'll test selection in next test case

---

## Test Case 3: Model Selection & Persistence

### Objective:
Verify that users can select a different model and the choice is persisted.

### Prerequisites:
- Model Configuration sheet is open (from Test Case 2)

### Steps:

#### Part A: Select New Model

1. **Select Claude 3.5 Sonnet**
   - Tap anywhere on the "Claude 3.5 Sonnet" row
   - ✅ **Expected**: Checkmark (✓) moves from GPT-4o Mini to Claude 3.5 Sonnet
   - ✅ **Expected**: Animation is smooth and immediate

2. **Verify Selection Change**
   - ✅ Only ONE checkmark should be visible
   - ✅ Checkmark should be next to "Claude 3.5 Sonnet"
   - ❌ **Fail If**: Multiple checkmarks or no checkmark visible

3. **Save Selection**
   - Tap "Save" button in top-right corner
   - ✅ **Expected**: Sheet dismisses and returns to chat view

#### Part B: Verify Model Badge

4. **Check Model Badge in Chat**
   - Look at the area below "Chat" title in navigation bar
   - ✅ **Expected**: Badge displays "🖥️ Claude 3.5 Sonnet"
   - ❌ **Fail If**: Badge still shows "GPT-4o Mini" or is missing

5. **Send Test Message**
   - Type: "What model are you using?"
   - Send message
   - ✅ **Expected**: AI responds (verify no errors)
   - 📝 **Note**: You won't be able to verify which model was actually used without API logs

#### Part C: Verify Persistence Across Sessions

6. **Navigate Away and Back**
   - Tap "Calendar" tab
   - Wait 2 seconds
   - Tap "Chat" tab
   - ✅ **Expected**: Model badge still shows "Claude 3.5 Sonnet"

7. **Reopen Model Configuration**
   - Tap CPU button again
   - ✅ **Expected**: Checkmark is still on "Claude 3.5 Sonnet"
   - ❌ **Fail If**: Checkmark reverted to default

8. **Cancel Without Changes**
   - Tap "Cancel" in top-left corner
   - ✅ **Expected**: Sheet dismisses, badge unchanged

### Acceptance Criteria:
- [x] User can tap to select different model
- [x] Checkmark moves to selected model
- [x] Save button persists the selection
- [x] Model badge updates in chat UI
- [x] Selection persists across navigation
- [x] Selection persists when reopening config sheet

### Notes:
- The model badge is the primary indicator of which model is selected
- Actual API calls use the selected model (not verifiable in UI alone)

---

## Test Case 4: Database Persistence Validation

### Objective:
Verify that the model selection is actually saved to the database.

### Prerequisites:
- Model changed to Claude 3.5 Sonnet (from Test Case 3)
- Terminal access to simulator

### Steps:

1. **Get Database Path**
   ```bash
   xcrun simctl get_app_container 1E2BA38B-3BA0-48FB-AE8C-6009C2A3A4A7 com.phucnt.kioku data
   ```
   Replace UUID with your simulator's UUID (get from Xcode → Window → Devices and Simulators)

2. **Query Database**
   ```bash
   DB_PATH="<PATH_FROM_STEP_1>/Library/Application Support/default.store"
   sqlite3 "$DB_PATH" "SELECT Z_PK, ZTITLE, ZMODELIDENTIFIER FROM ZCONVERSATION;"
   ```

3. **Verify Results**
   - ✅ **Expected Output**:
     ```
     1|Chat for 13 Oct 2025|anthropic/claude-3.5-sonnet
     ```
   - ✅ ZMODELIDENTIFIER should be: `anthropic/claude-3.5-sonnet`
   - ❌ **Fail If**: ZMODELIDENTIFIER is empty or still shows `openai/gpt-4o-mini`

### Acceptance Criteria:
- [x] Database contains conversation record
- [x] modelIdentifier field has correct value
- [x] Value matches OpenRouter model format (provider/model-name)

### Notes:
- This is optional validation - UI tests are usually sufficient
- Useful for debugging if model selection doesn't work

---

## Test Case 5: Multiple Model Switches

### Objective:
Verify that users can switch between models multiple times and each change is persisted.

### Steps:

1. **Switch to GPT-4o**
   - Open model configuration (CPU button)
   - Select "GPT-4o"
   - Tap "Save"
   - ✅ **Expected**: Badge shows "🖥️ GPT-4o"

2. **Send Message**
   - Type: "Testing GPT-4o"
   - Send message
   - ✅ **Expected**: AI responds normally

3. **Switch to Claude 3 Haiku**
   - Open model configuration
   - Select "Claude 3 Haiku"
   - Tap "Save"
   - ✅ **Expected**: Badge shows "🖥️ Claude 3 Haiku"

4. **Switch Back to Default**
   - Open model configuration
   - Select "GPT-4o Mini"
   - Tap "Save"
   - ✅ **Expected**: Badge shows "🖥️ GPT-4o Mini"

5. **Verify Final State**
   - Close and reopen app (kill app, relaunch)
   - Navigate to Chat tab
   - ✅ **Expected**: Badge shows last selected model (GPT-4o Mini)

### Acceptance Criteria:
- [x] User can switch models multiple times
- [x] Each switch updates the badge immediately
- [x] Final selection persists after app restart

### Notes:
- Each model switch should be smooth with no errors
- Badge should update instantly after Save

---

## Test Case 6: Cancel Behavior

### Objective:
Verify that Cancel button discards changes.

### Steps:

1. **Open Model Configuration**
   - Current selection: GPT-4o Mini (from Test Case 5)
   - Tap CPU button

2. **Select Different Model**
   - Tap on "Claude 3.5 Sonnet"
   - ✅ Checkmark moves to Claude 3.5 Sonnet

3. **Cancel Changes**
   - Tap "Cancel" button in top-left
   - ✅ **Expected**: Sheet dismisses

4. **Verify Badge Unchanged**
   - ✅ **Expected**: Badge still shows "🖥️ GPT-4o Mini"
   - ❌ **Fail If**: Badge changed to Claude 3.5 Sonnet

5. **Reopen and Verify Selection**
   - Tap CPU button again
   - ✅ **Expected**: Checkmark is still on "GPT-4o Mini"
   - ✅ **Expected**: Claude 3.5 Sonnet is NOT checked

### Acceptance Criteria:
- [x] Cancel button discards unsaved changes
- [x] Badge doesn't update when Cancel is tapped
- [x] Selection reverts when sheet reopened

---

## Test Case 7: New Conversation Behavior

### Objective:
Verify that each conversation can have its own model selection.

### Steps:

1. **Note Current Conversation Model**
   - Current chat should show "🖥️ GPT-4o Mini"

2. **Create New Conversation**
   - Navigate to Calendar tab
   - Select a **different date** (e.g., tomorrow)
   - Navigate to Chat tab

3. **Verify CPU Button Disabled**
   - ✅ **Expected**: CPU button is DISABLED (new conversation)

4. **Send First Message**
   - Type: "New conversation test"
   - Send message
   - Wait for AI response

5. **Configure Different Model**
   - Wait 2-3 seconds for CPU button to enable
   - Tap CPU button
   - Select "Claude 3.5 Sonnet"
   - Tap "Save"
   - ✅ **Expected**: Badge shows "Claude 3.5 Sonnet"

6. **Switch Back to Previous Conversation**
   - Navigate to Calendar tab
   - Select the original date
   - Navigate to Chat tab
   - ✅ **Expected**: Badge shows "GPT-4o Mini" (original selection)

7. **Switch to New Conversation Again**
   - Navigate to Calendar tab
   - Select the second date
   - Navigate to Chat tab
   - ✅ **Expected**: Badge shows "Claude 3.5 Sonnet"

### Acceptance Criteria:
- [x] Each conversation can have different model
- [x] Model selection persists per conversation
- [x] Switching between conversations shows correct model badge
- [x] New conversations start with CPU button disabled

### Notes:
- This is the key feature: per-conversation model selection
- Each date can have its own chat with its own model

---

## Test Case 8: Edge Cases & Error Handling

### Objective:
Verify edge cases and error scenarios.

### Test 8A: Rapid Model Switching

1. **Open Model Configuration**
2. **Rapidly Tap Different Models**
   - Tap Claude 3.5 Sonnet
   - Immediately tap GPT-4o
   - Immediately tap Llama 3.1 70B
3. **Verify Final Selection**
   - ✅ Only one checkmark should be visible
   - ✅ Last tapped model should be selected

### Test 8B: Save Without Selection Change

1. **Open Model Configuration**
2. **Don't change selection**
3. **Tap Save**
   - ✅ **Expected**: No error, sheet dismisses normally

### Test 8C: Multiple Opens Without Saving

1. **Open Model Configuration**
2. **Tap Cancel**
3. **Open Again**
4. **Select different model**
5. **Tap Cancel**
6. **Verify badge unchanged**
   - ✅ Badge should still show original model

### Acceptance Criteria:
- [x] Rapid tapping doesn't break selection UI
- [x] Saving without changes works normally
- [x] Multiple cancel operations don't cause issues

---

## Test Summary Checklist

Use this checklist to track your testing progress:

### Core Functionality:
- [ ] Test Case 1: CPU Button Behavior ✅
- [ ] Test Case 2: Model Configuration UI ✅
- [ ] Test Case 3: Model Selection & Persistence ✅
- [ ] Test Case 4: Database Persistence (Optional) ✅
- [ ] Test Case 5: Multiple Model Switches ✅
- [ ] Test Case 6: Cancel Behavior ✅
- [ ] Test Case 7: New Conversation Behavior ✅
- [ ] Test Case 8: Edge Cases ✅

### Key Features Validated:
- [ ] CPU button enables after first message
- [ ] Model configuration sheet displays correctly
- [ ] All 5 models shown with correct information
- [ ] Model selection changes checkmark position
- [ ] Save button persists selection
- [ ] Model badge displays selected model
- [ ] Selection persists across navigation
- [ ] Selection persists across app restart
- [ ] Each conversation has independent model selection
- [ ] Cancel discards changes

---

## Known Issues & Limitations

Document any issues found during testing:

### Expected Limitations:
1. **CPU Button Delay**: 2-3 second delay before button enables (polling mechanism)
2. **No API Validation**: No real-time check if model is available on OpenRouter
3. **Per-Conversation Only**: Cannot change model mid-conversation
4. **No Model History**: No UI showing which model was used for past messages

### Potential Issues to Watch For:
- [ ] CPU button doesn't enable (indicates conversation persistence issue)
- [ ] Model badge doesn't update (indicates binding issue)
- [ ] Selection doesn't persist (indicates database save issue)
- [ ] Checkmark appears on multiple models (indicates UI state bug)
- [ ] Sheet doesn't dismiss after Save (indicates action handler issue)

---

## Bug Reporting Template

If you find any issues, report them with this format:

```markdown
**Bug Title**: [Brief description]

**Severity**: Critical / High / Medium / Low

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happened]

**Screenshots**:
[Attach if applicable]

**Environment**:
- Xcode Version: [e.g., 15.4]
- iOS Version: [e.g., 18.0]
- Simulator: [e.g., iPhone 16]
- Date Tested: [e.g., 2025-10-13]

**Additional Context**:
[Any other relevant information]
```

---

## Success Criteria

All test cases should pass with these results:

✅ **PASS**: Feature works as expected, no issues found
⚠️ **PARTIAL**: Minor issues found, feature mostly works
❌ **FAIL**: Critical issues, feature doesn't work

### Overall Sprint 17 Part 1 Status:
- [ ] All test cases passed
- [ ] No critical bugs found
- [ ] Documentation accurate
- [ ] Ready for production

---

**Test Completed By**: _________________
**Date**: _________________
**Overall Status**: PASS / PARTIAL / FAIL
**Notes**: _________________
