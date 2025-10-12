# Sprint 17 Model Configuration - Test Scenarios

**Feature**: US-S16-002 - Flexible Model Configuration
**Status**: ✅ IMPLEMENTED
**Build**: ✅ SUCCESS (commit: fe957c8)
**Test Date**: 2025-10-12

---

## Test Scenarios

### Scenario 1: Select Popular Model

**Objective**: Verify user can select a popular preset model for conversation

**Preconditions**:
- App installed and launched
- User has valid OpenRouter API key configured

**Steps**:
1. Navigate to Chat tab
2. Open a conversation (or create new)
3. Tap model configuration button (if available in UI)
4. Verify popular models list displayed:
   - GPT-4o Mini (DEFAULT)
   - GPT-4o
   - Claude 3.5 Sonnet
   - Claude 3 Haiku
   - Llama 3.1 70B
5. Select "Claude 3.5 Sonnet"
6. Tap "Save"
7. Send a chat message

**Expected Results**:
- ✅ Popular models displayed with pricing and descriptions
- ✅ Selection saved to conversation
- ✅ Model badge shows "Claude 3.5 Sonnet" in chat UI
- ✅ API call uses "anthropic/claude-3.5-sonnet" model
- ✅ Response received successfully

**Acceptance Criteria**:
- Popular models list matches ModelValidationService.popularModels
- Default model is GPT-4o Mini
- Model selection persists after closing and reopening conversation
- Model badge visible in chat UI

---

### Scenario 2: Custom Model ID Validation

**Objective**: Verify custom model ID format validation works

**Steps**:
1. Open model configuration view
2. Tap "Custom Model" option
3. Enter invalid format: "invalid-model"
4. Tap "Validate Format" button
5. Observe error message
6. Enter valid format: "openai/gpt-4-turbo"
7. Tap "Validate Format" button
8. Tap "Save"

**Expected Results**:
- ✅ Invalid format shows error: "Invalid format. Expected: provider/model-name"
- ✅ Valid format shows no error
- ✅ Save button disabled for invalid format
- ✅ Save button enabled for valid format
- ✅ Custom model ID saved successfully

**Validation Rules**:
- Format: `provider/model-name`
- Provider: non-empty, alphanumeric + dash/underscore/dot
- Model: non-empty, alphanumeric + dash/underscore/dot
- Case insensitive

---

### Scenario 3: Default Model Behavior

**Objective**: Verify default model used when no model specified

**Steps**:
1. Create new conversation (no model configured)
2. Send chat message
3. Check model badge
4. Verify API logs

**Expected Results**:
- ✅ Model badge not displayed (or shows "GPT-4o Mini" as default)
- ✅ API call uses "openai/gpt-4o-mini" (default model)
- ✅ Response received successfully

**Default Model**: `openai/gpt-4o-mini`

---

### Scenario 4: Model Badge Display

**Objective**: Verify model badge displays correctly in chat UI

**Steps**:
1. Configure conversation with "GPT-4o" model
2. Open chat view
3. Observe model badge

**Expected Results**:
- ✅ Badge displays "GPT-4o" (friendly name)
- ✅ Badge has CPU icon
- ✅ Badge styled with secondary color background
- ✅ Badge positioned at top of chat view

**UI Specifications**:
- Icon: `cpu` SF Symbol
- Font: Caption
- Color: Secondary
- Background: Secondary opacity 0.1
- Corner radius: 12pt
- Padding: H=12pt, V=6pt

---

### Scenario 5: Entity Extraction Still Uses Fixed Model

**Objective**: Verify entity extraction/relationship discovery not affected by chat model

**Steps**:
1. Configure conversation with "Claude 3.5 Sonnet"
2. Create new journal entry with entities (people, places)
3. Run entity extraction
4. Check extraction logs/API calls

**Expected Results**:
- ✅ Chat uses Claude 3.5 Sonnet
- ✅ Entity extraction uses GPT-4o Mini (fixed model)
- ✅ Relationship discovery uses GPT-4o Mini (fixed model)
- ✅ No impact on Knowledge Graph consistency

**Scope Verification**:
- Chat conversations: ✅ Flexible model selection
- Entity extraction: ❌ Fixed model (gpt-4o-mini)
- Relationship discovery: ❌ Fixed model (gpt-4o-mini)

---

## Manual Testing Checklist

### UI/UX Tests

- [ ] ModelConfigurationView displays correctly
- [ ] Popular models list complete with pricing
- [ ] Custom model input validation works
- [ ] Save/Cancel buttons function correctly
- [ ] Model badge displays in chat UI
- [ ] Model badge shows correct model name

### Functional Tests

- [ ] Model selection persists in Conversation model
- [ ] API calls use correct model identifier
- [ ] Default model fallback works
- [ ] Invalid model formats rejected
- [ ] Valid custom models accepted

### Edge Cases

- [ ] Empty model identifier (uses default)
- [ ] Very long model identifier (UI handles gracefully)
- [ ] Special characters in model name (validation rejects)
- [ ] Model not available in OpenRouter (API error handled)

### Data Integrity

- [ ] Conversation.modelIdentifier field nullable
- [ ] Database migration successful (if applicable)
- [ ] No impact on existing conversations

---

## Known Limitations

1. **No API Availability Check**:
   - Format validation only (provider/model-name pattern)
   - Does not verify model exists in OpenRouter catalog
   - User may select unavailable model (API will error)
   - **Future enhancement**: Add OpenRouter /models API call

2. **No Model-Specific Error Handling**:
   - Generic error message for all API failures
   - Cannot distinguish: model not found vs rate limit vs network error
   - **Future enhancement**: Parse OpenRouter error responses

3. **No Model Pricing Validation**:
   - Static pricing info in ModelValidationService
   - May be outdated if OpenRouter changes pricing
   - **Future enhancement**: Fetch real-time pricing from API

4. **No Per-Message Model Override**:
   - Model set at conversation level
   - Cannot change model mid-conversation
   - **Future enhancement**: Allow per-message model selection

---

## Performance Metrics

**Target**: No performance impact on chat latency

**Measurements Needed**:
- Model badge render time: < 5ms
- Model validation time: < 10ms (format check only)
- API call overhead: None (model parameter already supported)

---

## Security Considerations

**Model Identifier Storage**:
- Stored as plain text in Conversation model
- No sensitive data (just model identifier string)
- Validated before API call to prevent injection

**API Key Protection**:
- Model configuration does not expose API key
- API key managed separately in OpenRouterService
- No changes to API key security model

---

## Regression Tests

Verify existing functionality not affected:

- [ ] Chat without model configuration works (uses default)
- [ ] Entity extraction still works
- [ ] Relationship discovery still works
- [ ] Insights generation still works
- [ ] Related notes discovery still works

---

## Test Data

### Valid Model IDs

```
openai/gpt-4o-mini (default)
openai/gpt-4o
anthropic/claude-3.5-sonnet
anthropic/claude-3-haiku
meta-llama/llama-3.1-70b-instruct
google/gemini-pro-1.5
mistralai/mixtral-8x7b-instruct
```

### Invalid Model IDs

```
invalid-model (missing provider)
openai/ (missing model name)
/gpt-4 (missing provider)
openai/gpt 4 (space not allowed)
openai\gpt-4 (backslash not allowed)
```

---

## Automated Test Script (Future)

```swift
// XCTest example for model validation
func testModelValidation() {
    // Valid formats
    XCTAssertTrue(ModelValidationService.validateFormat("openai/gpt-4o-mini"))
    XCTAssertTrue(ModelValidationService.validateFormat("anthropic/claude-3.5-sonnet"))

    // Invalid formats
    XCTAssertFalse(ModelValidationService.validateFormat("invalid"))
    XCTAssertFalse(ModelValidationService.validateFormat("openai/"))
    XCTAssertFalse(ModelValidationService.validateFormat("/gpt-4"))
    XCTAssertFalse(ModelValidationService.validateFormat("openai gpt-4"))
}

func testDefaultModel() {
    XCTAssertEqual(ModelValidationService.defaultModel, "openai/gpt-4o-mini")
}

func testPopularModels() {
    XCTAssertEqual(ModelValidationService.popularModels.count, 5)
    XCTAssertTrue(ModelValidationService.isPopularModel("openai/gpt-4o-mini"))
}
```

---

## Status Summary

**Implementation**: ✅ COMPLETE
**Build**: ✅ SUCCESS
**Manual Testing**: ⏳ PENDING (requires UI interaction)
**Automated Testing**: ⏳ TODO (unit tests deferred)
**Documentation**: ✅ COMPLETE

**Next Steps**:
1. Manual UI testing with real device/simulator
2. Test with actual OpenRouter API calls
3. Verify model selection persists correctly
4. Test edge cases and error handling

---

**Document Control**

- **Version**: 1.0
- **Feature**: US-S16-002 (Sprint 17)
- **Status**: Implementation Complete, Testing Pending
- **Last Updated**: 2025-10-12
