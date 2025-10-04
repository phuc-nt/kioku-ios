# Sprint 13 Acceptance Tests: Knowledge Graph Integration

**Test Date**: TBD (Target: October 17, 2025)
**Sprint**: Sprint 13 - Knowledge Graph Integration
**Tester**: Claude Code AI Assistant
**Device**: iPhone 16 Simulator (iOS 18.5)

## Test Overview

### User Stories Under Test
- **US-S13-001**: Entity Extraction from Notes (3 points)
- **US-S13-002**: Relationship Mapping (4 points)
- **US-S13-003**: Graph Visualization Screen (3 points)
- **US-S13-004**: Conversation to Knowledge Graph (2 points)

### Test Summary

| Category | Tests Planned | Tests Passed | Tests Failed | Notes |
|----------|---------------|--------------|--------------|-------|
| Entity Extraction | 8 | 0 | 0 | Not yet tested |
| Relationship Mapping | 7 | 0 | 0 | Not yet tested |
| Graph Visualization | 7 | 0 | 0 | Not yet tested |
| Conversation to KG | 3 | 0 | 0 | Not yet tested |
| **TOTAL** | **25** | **0** | **0** | **Sprint in planning** |

---

## US-S13-001: Entity Extraction from Notes

### Test Case 1: Extract People Entities
**Test ID**: TC-S13-001
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify people entities are extracted from journal entries

**Pre-conditions**:
- App installed and launched
- At least one journal entry with people mentions

**Test Steps**:
1. **Create Entry with People**
   - Navigate to Calendar tab
   - Tap on a date
   - Create entry: "Had lunch with Sarah and John. My brother called later."
   - Save entry
   - **Expected**: Entry saved successfully

2. **Trigger Entity Extraction**
   - Wait for auto-extraction (background process)
   - OR manually trigger from Settings → "Analyze All Notes"
   - **Expected**: Extraction begins
   - **Expected**: Progress indicator visible

3. **Verify People Entities**
   - Check extracted entities (in graph or entity list)
   - **Expected**: Entity "Sarah" extracted (confidence ≥ 0.5)
   - **Expected**: Entity "John" extracted (confidence ≥ 0.5)
   - **Expected**: Entity "brother" extracted OR relationship inferred
   - **Expected**: Each entity has type = "people"

4. **Check Entity Details**
   - Tap on "Sarah" entity
   - **Expected**: Shows source entry reference
   - **Expected**: Shows confidence score
   - **Expected**: Shows relationship if detected (friend/family)

**Success Criteria**:
- ✅ At least 2 people entities extracted
- ✅ Confidence scores ≥ 0.5
- ✅ Entity type correctly set to "people"
- ✅ Source entry linkable

---

### Test Case 2: Extract Places Entities
**Test ID**: TC-S13-002
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify place entities are extracted from journal entries

**Pre-conditions**:
- Entity extraction service configured

**Test Steps**:
1. **Create Entry with Places**
   - Create entry: "Visited Paris last week. Had coffee at Starbucks on Main Street."
   - Save entry

2. **Verify Place Extraction**
   - Check extracted entities
   - **Expected**: Entity "Paris" (type: place, confidence ≥ 0.8)
   - **Expected**: Entity "Starbucks" (type: place, confidence ≥ 0.6)
   - **Expected**: Entity "Main Street" (type: place, confidence ≥ 0.5)

3. **Test Place Metadata**
   - Tap on "Paris" entity
   - **Expected**: Metadata includes type (city)
   - **Expected**: Possible geographic info if available

**Success Criteria**:
- ✅ 2-3 place entities extracted
- ✅ Place types detected (city, venue, street)
- ✅ Confidence appropriate for specificity

---

### Test Case 3: Extract Events Entities
**Test ID**: TC-S13-003
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify event entities are extracted

**Pre-conditions**:
- Entry with events created

**Test Steps**:
1. **Create Entry with Events**
   - Entry: "Attended the product launch on Monday. Team meeting scheduled for Friday."
   - Save entry

2. **Verify Event Extraction**
   - **Expected**: Entity "product launch" (type: event, confidence ≥ 0.7)
   - **Expected**: Entity "team meeting" (type: event, confidence ≥ 0.7)
   - **Expected**: Temporal info captured (Monday, Friday)

3. **Check Event Details**
   - **Expected**: Event name clear and meaningful
   - **Expected**: Date information preserved

**Success Criteria**:
- ✅ Events extracted with dates
- ✅ Event names meaningful
- ✅ Temporal references captured

---

### Test Case 4: Extract Emotions Entities
**Test ID**: TC-S13-004
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify emotion entities are extracted

**Pre-conditions**:
- Entry with emotional content

**Test Steps**:
1. **Create Entry with Emotions**
   - Entry: "Feeling incredibly happy today! The news made me anxious but excited."
   - Save entry

2. **Verify Emotion Extraction**
   - **Expected**: Entity "happy" (type: emotion, intensity: high, confidence ≥ 0.8)
   - **Expected**: Entity "anxious" (type: emotion, confidence ≥ 0.7)
   - **Expected**: Entity "excited" (type: emotion, confidence ≥ 0.7)

3. **Check Emotion Metadata**
   - **Expected**: Intensity levels (high, medium, low)
   - **Expected**: Positive/negative classification

**Success Criteria**:
- ✅ Emotions extracted accurately
- ✅ Intensity captured
- ✅ Multiple emotions in same entry

---

### Test Case 5: Extract Topics Entities
**Test ID**: TC-S13-005
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify topic entities are extracted

**Pre-conditions**:
- Entry with clear topics

**Test Steps**:
1. **Create Entry with Topics**
   - Entry: "Learning about machine learning and artificial intelligence. Read a great book on productivity."
   - Save entry

2. **Verify Topic Extraction**
   - **Expected**: Entity "machine learning" (type: topic, confidence ≥ 0.9)
   - **Expected**: Entity "artificial intelligence" (type: topic, confidence ≥ 0.9)
   - **Expected**: Entity "productivity" (type: topic, confidence ≥ 0.8)

3. **Check Topic Clustering**
   - **Expected**: Related topics grouped (ML + AI)

**Success Criteria**:
- ✅ Topics extracted accurately
- ✅ Technical terms recognized
- ✅ Related topics discoverable

---

### Test Case 6: Entity Deduplication
**Test ID**: TC-S13-006
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify similar entities are deduplicated

**Pre-conditions**:
- Multiple entries with similar entity mentions

**Test Steps**:
1. **Create Multiple Entries**
   - Entry 1: "Talked to Mom today."
   - Entry 2: "Mother called me last night."
   - Entry 3: "My mom is visiting."
   - Save all entries

2. **Trigger Batch Extraction**
   - Settings → "Analyze All Notes"
   - **Expected**: Extraction completes

3. **Verify Deduplication**
   - Check entity list
   - **Expected**: Only ONE entity for "Mom/Mother/mom"
   - **Expected**: Entity has aliases: ["Mom", "Mother", "mom"]
   - **Expected**: Entity linked to all 3 entries

4. **Test Case Sensitivity**
   - **Expected**: "Paris" and "paris" merged
   - **Expected**: "john" and "John" merged

**Success Criteria**:
- ✅ Duplicates merged correctly
- ✅ All aliases captured
- ✅ All source entries linked
- ✅ Case-insensitive matching

---

### Test Case 7: Batch Processing
**Test ID**: TC-S13-007
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify batch extraction processes multiple entries

**Pre-conditions**:
- 10+ existing journal entries
- Entries NOT yet analyzed

**Test Steps**:
1. **Navigate to Settings**
   - Open Settings tab
   - Find "Knowledge Graph" section
   - **Expected**: "Analyze All Notes" button visible

2. **Trigger Batch Processing**
   - Tap "Analyze All Notes"
   - **Expected**: Confirmation dialog "Analyze X entries?"
   - Confirm

3. **Monitor Progress**
   - **Expected**: Progress indicator shows X/Y entries
   - **Expected**: Estimated time displayed
   - **Expected**: Can cancel mid-process

4. **Verify Completion**
   - Wait for completion
   - **Expected**: Success message "Extracted Y entities from X entries"
   - **Expected**: Entity count updated

5. **Check Performance**
   - Time taken for 10 entries
   - **Expected**: <1 minute for 10 entries
   - **Expected**: No app freeze or lag

**Success Criteria**:
- ✅ Batch processes all entries
- ✅ Progress tracking accurate
- ✅ Cancelation works
- ✅ Performance acceptable

---

### Test Case 8: Confidence Threshold
**Test ID**: TC-S13-008
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify low-confidence entities are filtered

**Pre-conditions**:
- Confidence threshold set to 0.5 (default)

**Test Steps**:
1. **Create Ambiguous Entry**
   - Entry: "Went somewhere. Met someone. Felt something."
   - Save entry

2. **Verify Filtering**
   - Check extracted entities
   - **Expected**: Very few or zero entities extracted
   - **Expected**: Low-confidence entities (<0.5) NOT stored

3. **Adjust Threshold**
   - Settings → Knowledge Graph → Confidence: 0.3
   - Re-analyze entry

4. **Verify More Entities**
   - **Expected**: More entities now visible
   - **Expected**: Lower confidence scores shown

**Success Criteria**:
- ✅ Threshold filtering works
- ✅ User can adjust threshold
- ✅ Ambiguous text handled gracefully

---

## US-S13-002: Relationship Mapping

### Test Case 9: Temporal Relationships
**Test ID**: TC-S13-009
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify temporal relationships are discovered

**Pre-conditions**:
- Entities extracted from entries with dates

**Test Steps**:
1. **Create Entries with Temporal Info**
   - Entry 1: "Met Sarah on Monday at Starbucks."
   - Entry 2: "On Tuesday, went to Paris with Sarah."
   - Save and extract entities

2. **Trigger Relationship Discovery**
   - Settings → "Build Knowledge Graph"
   - **Expected**: Relationship analysis begins

3. **Verify Temporal Relationships**
   - Check relationships for "Sarah"
   - **Expected**: (Starbucks, Paris, TEMPORAL, confidence ≥ 0.7)
   - **Expected**: Evidence: "Monday" before "Tuesday"

4. **Check Relationship Details**
   - Tap relationship edge
   - **Expected**: Shows temporal order
   - **Expected**: Shows evidence excerpt

**Success Criteria**:
- ✅ Temporal relationships detected
- ✅ Date ordering correct
- ✅ Evidence captured

---

### Test Case 10: Causal Relationships
**Test ID**: TC-S13-010
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify causal relationships are discovered

**Pre-conditions**:
- Entries with causal language

**Test Steps**:
1. **Create Entry with Causality**
   - Entry: "The promotion made me feel confident. This confidence led to better presentations."
   - Save and extract

2. **Verify Causal Relationships**
   - **Expected**: (promotion, confident, CAUSAL, confidence ≥ 0.8)
   - **Expected**: (confident, presentations, CAUSAL, confidence ≥ 0.7)
   - **Expected**: Evidence includes "made me" and "led to"

3. **Test Causal Keywords**
   - Test with: "because", "therefore", "resulted in"
   - **Expected**: All trigger causal detection

**Success Criteria**:
- ✅ Causal relationships found
- ✅ Causal keywords recognized
- ✅ Chain of causality preserved

---

### Test Case 11: Emotional Relationships
**Test ID**: TC-S13-011
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify emotional relationships link emotions to entities

**Pre-conditions**:
- Entries with emotion-entity associations

**Test Steps**:
1. **Create Entry with Emotions**
   - Entry: "Spending time with Mom always makes me happy. Work stress makes me anxious."
   - Save and extract

2. **Verify Emotional Relationships**
   - **Expected**: (Mom, happy, EMOTIONAL, confidence ≥ 0.85)
   - **Expected**: (work, anxious, EMOTIONAL, confidence ≥ 0.8)

3. **Check Emotion-Person Links**
   - Navigate to "Mom" entity
   - **Expected**: Shows "happy" connection
   - **Expected**: Evidence: "makes me happy"

**Success Criteria**:
- ✅ Emotions linked to people/events/places
- ✅ Evidence meaningful
- ✅ Bidirectional relationships

---

### Test Case 12: Topical Relationships
**Test ID**: TC-S13-012
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify topical relationships cluster related entities

**Pre-conditions**:
- Entries discussing related topics

**Test Steps**:
1. **Create Entries with Topics**
   - Entry 1: "Learning machine learning fundamentals."
   - Entry 2: "Applied AI techniques to data analysis."
   - Save and extract

2. **Verify Topical Relationships**
   - **Expected**: (machine_learning, AI, TOPICAL, confidence ≥ 0.9)
   - **Expected**: (AI, data_analysis, TOPICAL, confidence ≥ 0.8)

3. **Check Topic Clusters**
   - View graph
   - **Expected**: ML, AI, data_analysis clustered together

**Success Criteria**:
- ✅ Related topics linked
- ✅ Semantic similarity detected
- ✅ Topic clusters visible

---

### Test Case 13: Cross-Note Relationship Discovery
**Test ID**: TC-S13-013
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify relationships discovered across multiple entries

**Pre-conditions**:
- 5+ entries with overlapping entities

**Test Steps**:
1. **Create Related Entries**
   - Entry 1: "Sarah lives in Paris."
   - Entry 2: "Visited Paris last summer."
   - Entry 3: "Sarah recommended a great restaurant."
   - Save all

2. **Build Knowledge Graph**
   - Settings → "Build Knowledge Graph"
   - **Expected**: Cross-note analysis

3. **Verify Cross-Note Relationships**
   - **Expected**: (Sarah, Paris, multiple relationships)
   - **Expected**: Relationships from Entry 1 AND Entry 2
   - **Expected**: All evidence entries listed

**Success Criteria**:
- ✅ Relationships span multiple entries
- ✅ All evidence collected
- ✅ No duplicate relationships

---

### Test Case 14: Relationship Evidence Quality
**Test ID**: TC-S13-014
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify relationship evidence is relevant and helpful

**Pre-conditions**:
- Relationships discovered with evidence

**Test Steps**:
1. **View Relationship Details**
   - Open graph view
   - Tap any relationship edge
   - **Expected**: Evidence popover opens

2. **Check Evidence Content**
   - **Expected**: Text excerpt contains both entities
   - **Expected**: Excerpt includes context (1-2 sentences)
   - **Expected**: Source entry clickable

3. **Verify Evidence Relevance**
   - **Expected**: Evidence explains WHY relationship exists
   - **Expected**: Not just random sentence with entities

**Success Criteria**:
- ✅ Evidence excerpts relevant
- ✅ Context sufficient
- ✅ Source traceable

---

### Test Case 15: Relationship Performance
**Test ID**: TC-S13-015
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify relationship discovery performs well at scale

**Pre-conditions**:
- 100+ entities extracted
- Large journal corpus

**Test Steps**:
1. **Trigger Large-Scale Analysis**
   - Settings → "Build Knowledge Graph" (100 entries)
   - Start timer

2. **Monitor Performance**
   - **Expected**: Analysis completes in <30 seconds
   - **Expected**: No app freeze
   - **Expected**: Progress updates regularly

3. **Verify Result Quality**
   - Check relationship count
   - **Expected**: Reasonable number (not too many or too few)
   - **Expected**: High-confidence relationships prioritized

**Success Criteria**:
- ✅ 100 entries analyzed in <30s
- ✅ App responsive during analysis
- ✅ Quality maintained at scale

---

## US-S13-003: Graph Visualization Screen

### Test Case 16: Graph Access from Chat
**Test ID**: TC-S13-016
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify graph view accessible from Chat tab

**Pre-conditions**:
- Knowledge graph has been built
- Chat tab open

**Test Steps**:
1. **Locate View Graph Button**
   - Open Chat tab
   - Look in toolbar/sidebar
   - **Expected**: "View Graph" button visible
   - **Expected**: Button icon clear (graph/network icon)

2. **Tap View Graph**
   - Tap button
   - **Expected**: GraphView opens
   - **Expected**: Smooth transition animation
   - **Expected**: Graph centered on current context entities

3. **Verify Context Filtering**
   - **Expected**: Only entities from current conversation visible
   - OR: All entities visible, context entities highlighted

**Success Criteria**:
- ✅ Button easy to find
- ✅ Graph opens correctly
- ✅ Context-aware filtering

---

### Test Case 17: Graph Access from Entry Detail
**Test ID**: TC-S13-017
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify graph view accessible from entry detail

**Pre-conditions**:
- Entry with extracted entities

**Test Steps**:
1. **Open Entry Detail**
   - Calendar → Select date with entry
   - Open entry
   - **Expected**: Entry content visible

2. **Locate Show in Graph Button**
   - Look for graph button in toolbar/actions
   - **Expected**: "Show in Graph" button visible

3. **Tap Show in Graph**
   - Tap button
   - **Expected**: GraphView opens
   - **Expected**: Graph centered on this entry's entities
   - **Expected**: Entry entities highlighted

**Success Criteria**:
- ✅ Button accessible
- ✅ Graph centers on correct entities
- ✅ Visual highlight clear

---

### Test Case 18: Interactive Node Expansion
**Test ID**: TC-S13-018
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify nodes expand to show connections

**Pre-conditions**:
- Graph view open with multiple entities

**Test Steps**:
1. **Identify Entity Node**
   - View graph
   - Locate an entity node (circle with label)
   - **Expected**: Node clearly visible

2. **Tap to Expand**
   - Tap entity node
   - **Expected**: Connected entities appear
   - **Expected**: Relationship edges drawn
   - **Expected**: Smooth animation

3. **Tap Again to Collapse**
   - Tap same node again
   - **Expected**: Connected entities hide
   - **Expected**: Collapse animation

4. **Expand Multiple Nodes**
   - Tap several different nodes
   - **Expected**: All connections visible
   - **Expected**: No overlap issues

**Success Criteria**:
- ✅ Tap to expand/collapse works
- ✅ Animations smooth
- ✅ Multiple expansions handled

---

### Test Case 19: Relationship Edge Visualization
**Test ID**: TC-S13-019
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify relationship edges display correctly

**Pre-conditions**:
- Graph with multiple relationship types

**Test Steps**:
1. **View Graph Edges**
   - Open graph with relationships
   - **Expected**: Edges connect entity nodes

2. **Verify Color Coding**
   - **Expected**: Temporal edges = Blue
   - **Expected**: Causal edges = Orange
   - **Expected**: Emotional edges = Pink
   - **Expected**: Topical edges = Green

3. **Tap Edge for Evidence**
   - Tap on a relationship edge
   - **Expected**: Evidence popover appears
   - **Expected**: Shows excerpt and source

4. **Check Legend**
   - Look for legend/key
   - **Expected**: Color code explanation visible

**Success Criteria**:
- ✅ Edges color-coded correctly
- ✅ Edge tap shows evidence
- ✅ Legend clear

---

### Test Case 20: Graph Zoom and Pan
**Test ID**: TC-S13-020
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify zoom and pan gestures work

**Pre-conditions**:
- Graph view with many entities

**Test Steps**:
1. **Test Pinch Zoom**
   - Pinch out to zoom in
   - **Expected**: Graph zooms in smoothly
   - **Expected**: Node labels scale appropriately
   - Pinch in to zoom out
   - **Expected**: Graph zooms out

2. **Test Pan Gesture**
   - Drag graph with one finger
   - **Expected**: Graph pans in drag direction
   - **Expected**: Smooth panning

3. **Test Combined Gestures**
   - Zoom in, then pan
   - Pan, then zoom
   - **Expected**: Both gestures work together

4. **Test Limits**
   - Zoom in to maximum
   - **Expected**: Stops at reasonable max zoom
   - Zoom out to minimum
   - **Expected**: Stops at reasonable min zoom

**Success Criteria**:
- ✅ Pinch zoom responsive
- ✅ Pan smooth
- ✅ Zoom limits prevent issues

---

### Test Case 21: Entity Search in Graph
**Test ID**: TC-S13-021
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify entity search filters graph

**Pre-conditions**:
- Graph with 20+ entities

**Test Steps**:
1. **Locate Search Bar**
   - Open graph view
   - **Expected**: Search bar at top/bottom

2. **Search for Entity**
   - Type "Sarah" in search
   - **Expected**: Graph filters to show "Sarah" and connections
   - **Expected**: Other entities fade/hide

3. **Clear Search**
   - Clear search text
   - **Expected**: Full graph returns

4. **Search Non-Existent Entity**
   - Type "XYZ123"
   - **Expected**: "No results" message
   - **Expected**: Graph empty or unchanged

**Success Criteria**:
- ✅ Search filters correctly
- ✅ Clear search works
- ✅ No results handled gracefully

---

### Test Case 22: Graph Performance at Scale
**Test ID**: TC-S13-022
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify graph renders smoothly with many nodes

**Pre-conditions**:
- 500+ entities in knowledge graph

**Test Steps**:
1. **Open Large Graph**
   - Navigate to graph view
   - **Expected**: Initial render <2 seconds

2. **Test Interaction Performance**
   - Pan graph
   - Zoom in/out
   - Tap nodes
   - **Expected**: 60 FPS maintained
   - **Expected**: No stuttering or lag

3. **Measure Frame Rate**
   - Use Xcode Instruments if available
   - **Expected**: Consistent 60 FPS

4. **Test Memory Usage**
   - Check memory with large graph
   - **Expected**: <100 MB for graph rendering

**Success Criteria**:
- ✅ 500 nodes render smoothly
- ✅ 60 FPS during interaction
- ✅ Memory usage acceptable

---

## US-S13-004: Conversation to Knowledge Graph

### Test Case 23: Convert to KG Button Visibility
**Test ID**: TC-S13-023
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify "Convert to KG" button is accessible

**Pre-conditions**:
- Chat conversation with 5+ messages

**Test Steps**:
1. **Open Conversation**
   - Navigate to Chat tab
   - Open an existing conversation

2. **Locate Convert Button**
   - Look in toolbar/menu
   - **Expected**: "Convert to KG" button visible
   - **Expected**: Icon clear (graph or brain icon)

3. **Check Button State**
   - **Expected**: Enabled for unconverted conversations
   - **Expected**: Disabled for already-converted conversations

**Success Criteria**:
- ✅ Button easy to find
- ✅ State reflects conversion status

---

### Test Case 24: Conversation Entity Extraction
**Test ID**: TC-S13-024
**Priority**: High
**Status**: ⏳ NOT STARTED

**Objective**: Verify entities extracted from conversation messages

**Pre-conditions**:
- Conversation with entity mentions in messages

**Test Steps**:
1. **Create Test Conversation**
   - User: "Tell me about Paris"
   - AI: "Paris is the capital of France, known for the Eiffel Tower..."
   - User: "I visited there with Sarah last year"
   - Multiple messages exchanged

2. **Trigger Conversion**
   - Tap "Convert to KG"
   - **Expected**: Conversion starts
   - **Expected**: Progress indicator shown

3. **Verify Entity Extraction**
   - Wait for completion
   - **Expected**: Success message "Added X entities, Y relationships"
   - Check knowledge graph
   - **Expected**: "Paris" entity exists
   - **Expected**: "Sarah" entity exists
   - **Expected**: "Eiffel Tower" entity exists

4. **Verify Entity Sources**
   - Tap "Paris" entity
   - **Expected**: Shows conversation as source
   - **Expected**: Shows specific messages

**Success Criteria**:
- ✅ Entities extracted from user messages
- ✅ Entities extracted from AI messages
- ✅ Source conversation linked

---

### Test Case 25: Prevent Duplicate Conversion
**Test ID**: TC-S13-025
**Priority**: Medium
**Status**: ⏳ NOT STARTED

**Objective**: Verify conversation cannot be converted twice

**Pre-conditions**:
- Conversation already converted once

**Test Steps**:
1. **Open Converted Conversation**
   - Navigate to conversation
   - **Expected**: Conversation previously converted

2. **Check Button State**
   - Look at "Convert to KG" button
   - **Expected**: Button disabled/grayed out
   - **Expected**: Tooltip: "Already converted"

3. **Verify No Re-Conversion**
   - Attempt to tap disabled button
   - **Expected**: No action occurs
   - **Expected**: No duplicate entities created

4. **Check Metadata**
   - View conversation details
   - **Expected**: Shows "Converted on [date]"
   - **Expected**: Shows entity count from conversion

**Success Criteria**:
- ✅ Button disabled after conversion
- ✅ No duplicate conversions possible
- ✅ Metadata tracks conversion status

---

## Test Environment

### Device Configuration
- **Device**: iPhone 16 Simulator
- **iOS Version**: 18.5
- **App Version**: Sprint 13 Development Build
- **Network**: Simulator network environment
- **API**: OpenRouter service with Gemini 2.0 Flash

### Required Test Data
- Multiple journal entries (10+) with diverse content
- Entries with people, places, events, emotions, topics
- Entries with temporal relationships
- Entries with causal language
- Chat conversations with entity mentions
- Large corpus for performance testing (100+ entries)

---

## Performance Requirements

### Response Time Targets
- **Entity extraction** (single entry): <2 seconds
- **Batch extraction** (10 entries): <1 minute
- **Relationship discovery** (500 entities): <30 seconds
- **Graph rendering** (initial): <2 seconds
- **Graph interaction** (pan/zoom): 60 FPS
- **Entity search**: <100ms

### Memory & Resource Usage
- **Memory**: <150 MB for large graph (1000 nodes)
- **CPU**: <50% during background extraction
- **Battery**: Minimal impact during normal usage
- **Storage**: Efficient entity/relationship storage

---

## Accessibility Requirements

### VoiceOver Support
- [ ] All graph nodes labeled clearly
- [ ] Relationship edges have descriptive labels
- [ ] Search bar accessible
- [ ] Extract/convert buttons announced
- [ ] Progress indicators communicated

### Visual Accessibility
- [ ] Sufficient contrast ratios (WCAG AA)
- [ ] Color-blind friendly edge colors
- [ ] Text resizing supported
- [ ] Touch targets ≥44pt

---

## Success Criteria

### Functional Requirements
- [ ] All 25 test cases pass
- [ ] All user stories meet acceptance criteria
- [ ] No critical bugs found
- [ ] Edge cases handled gracefully

### Technical Requirements
- [ ] Code follows Swift/SwiftUI best practices
- [ ] No regressions in Sprint 12 features
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
| TC-S13-001 | ⏳ NOT STARTED | Extract people entities |
| TC-S13-002 | ⏳ NOT STARTED | Extract places entities |
| TC-S13-003 | ⏳ NOT STARTED | Extract events entities |
| TC-S13-004 | ⏳ NOT STARTED | Extract emotions entities |
| TC-S13-005 | ⏳ NOT STARTED | Extract topics entities |
| TC-S13-006 | ⏳ NOT STARTED | Entity deduplication |
| TC-S13-007 | ⏳ NOT STARTED | Batch processing |
| TC-S13-008 | ⏳ NOT STARTED | Confidence threshold |
| TC-S13-009 | ⏳ NOT STARTED | Temporal relationships |
| TC-S13-010 | ⏳ NOT STARTED | Causal relationships |
| TC-S13-011 | ⏳ NOT STARTED | Emotional relationships |
| TC-S13-012 | ⏳ NOT STARTED | Topical relationships |
| TC-S13-013 | ⏳ NOT STARTED | Cross-note discovery |
| TC-S13-014 | ⏳ NOT STARTED | Evidence quality |
| TC-S13-015 | ⏳ NOT STARTED | Relationship performance |
| TC-S13-016 | ⏳ NOT STARTED | Graph from Chat |
| TC-S13-017 | ⏳ NOT STARTED | Graph from Entry |
| TC-S13-018 | ⏳ NOT STARTED | Node expansion |
| TC-S13-019 | ⏳ NOT STARTED | Edge visualization |
| TC-S13-020 | ⏳ NOT STARTED | Zoom and pan |
| TC-S13-021 | ⏳ NOT STARTED | Entity search |
| TC-S13-022 | ⏳ NOT STARTED | Graph performance |
| TC-S13-023 | ⏳ NOT STARTED | Convert button |
| TC-S13-024 | ⏳ NOT STARTED | Conversation extraction |
| TC-S13-025 | ⏳ NOT STARTED | Prevent duplicates |

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

- Test execution will begin once US-S13-001 implementation is complete
- UI automation testing will use XcodeBuildMCP tools
- Performance testing will include memory profiling
- Accessibility testing will include VoiceOver validation
- Real API key required for entity extraction tests
- Large corpus needed for performance testing (100+ entries)

---

**Test Plan Created**: October 3, 2025
**Sprint Target**: October 17, 2025
**Related Sprint Plan**: [`docs/01_sprints/sprint_13_planning.md`](../01_sprints/sprint_13_planning.md)
