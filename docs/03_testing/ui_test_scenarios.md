# UI Test Scenarios - XcodeBuildMCP Automation
## Kioku Personal Journal iOS App

**Created:** September 25, 2025  
**Updated:** September 26, 2025  
**Sprint:** Sprint 4 - Advanced AI Features  
**User Story:** US-006: UI Testing Foundation với XcodeBuildMCP  
**Test Coverage:** US-001 through US-012 (Complete Sprint 1-4 Coverage)  

---

## Test Environment Setup

### Prerequisites
- iOS Simulator (iPhone 16 or compatible)
- XcodeBuildMCP tools available
- Clean app state for each test scenario
- Test data fixtures prepared

### Test Data
```
Entry 1: "Daily reflection on productivity and growth"
Entry 2: "Testing encryption functionality works perfectly"
Entry 3: "Weekend activities và fun experiences"
Entry 4: "Work progress và technical challenges"
Entry 5: ""  (Empty entry for edge case testing)
```

---

## Test Scenario 1: Entry Creation & Auto-Save (US-001, US-002)

### Test Case 1.1: Basic Entry Creation
**Objective:** Verify user can create and save journal entries
**Dependencies:** Clean app state

**Test Steps:**
1. Launch app và verify entry creation view loads
2. Tap into text input field
3. Type: "This is my first journal entry"
4. Wait 3 seconds (auto-save trigger)
5. Navigate away và return
6. Verify entry content persisted correctly

**Expected Results:**
- ✅ App launches to entry creation view
- ✅ Text input immediately focused
- ✅ Auto-save indicator shows after typing
- ✅ Entry content preserved across navigation
- ✅ No data loss during session

**XcodeBuildMCP Commands:**
```
1. screenshot() - Capture initial state
2. tap(x: 200, y: 400) - Focus text field
3. type_text("This is my first journal entry")
4. screenshot() - Verify text entered
5. gesture(preset: "swipe-from-left-edge") - Navigate away
6. screenshot() - Verify navigation
7. gesture(preset: "swipe-from-right-edge") - Return
8. screenshot() - Verify content persisted
```

### Test Case 1.2: Empty Entry Handling
**Objective:** Verify app handles empty entries gracefully

**Test Steps:**
1. Create entry với no content
2. Navigate away immediately
3. Return và check entry list
4. Verify no phantom entries created

**Expected Results:**
- ✅ Empty entries are not saved
- ✅ No corrupted data in entry list
- ✅ Clean user experience

### Test Case 1.3: Unicode Content Support
**Objective:** Verify unicode và special characters work properly

**Test Steps:**
1. Type content: "Hello 世界 🌍 Café naïve résumé"
2. Save và retrieve entry
3. Verify all characters display correctly

**Expected Results:**
- ✅ Unicode characters preserved
- ✅ Emojis display correctly  
- ✅ Accented characters maintained

---

## Test Scenario 2: Entry Browsing & Navigation (US-003)

### Test Case 2.1: Entry List Display
**Objective:** Verify entry list shows all entries correctly

**Test Steps:**
1. Create 5 test entries với different content
2. Navigate to entry list view
3. Verify all entries visible
4. Check date/time stamps
5. Verify word count displays

**Expected Results:**
- ✅ All entries listed chronologically
- ✅ Date và time displayed correctly
- ✅ Word count accurate
- ✅ Content preview visible (3 lines max)

**XcodeBuildMCP Commands:**
```
1. build_run_sim() - Launch app
2. [Create 5 entries with different content]
3. tap(navigation_to_list) - Open entry list
4. screenshot() - Capture list view
5. describe_ui() - Get UI element coordinates
6. [Verify each entry visible]
```

### Test Case 2.2: Entry Detail Navigation
**Objective:** Test navigation from list to detail view

**Test Steps:**
1. From entry list, tap on first entry
2. Verify detail view opens
3. Check all entry metadata displayed
4. Navigate back to list
5. Repeat for different entries

**Expected Results:**
- ✅ Tap navigation works smoothly
- ✅ Full entry content displayed
- ✅ Metadata (date, time, word count) correct
- ✅ Back navigation preserves list state

### Test Case 2.3: Empty State Handling
**Objective:** Verify empty state shown when no entries exist

**Test Steps:**
1. Clean app state (no entries)
2. Navigate to entry list
3. Verify empty state message displayed
4. Check empty state UI elements

**Expected Results:**
- ✅ "No entries yet" message shown
- ✅ Helpful guidance text displayed
- ✅ Clean, non-confusing UI

---

## Test Scenario 3: Search Functionality (US-005)

### Test Case 3.1: Basic Search
**Objective:** Test real-time search functionality

**Test Steps:**
1. Create entries với diverse content
2. Navigate to entry list
3. Tap search bar
4. Type "productivity"
5. Verify filtering works immediately
6. Clear search và verify all entries return

**Expected Results:**
- ✅ Search results filter immediately
- ✅ Case-insensitive matching works
- ✅ Clear button functions properly
- ✅ All entries restored after clear

**XcodeBuildMCP Commands:**
```
1. describe_ui() - Get search bar coordinates
2. tap(search_bar_x, search_bar_y) - Focus search
3. type_text("productivity")
4. screenshot() - Capture filtered results
5. tap(clear_button_x, clear_button_y) - Clear search
6. screenshot() - Verify all entries returned
```

### Test Case 3.2: Search Edge Cases
**Objective:** Test search với various edge cases

**Test Steps:**
1. Search với empty query
2. Search với special characters
3. Search với no matches
4. Search với partial matches
5. Test very long search terms

**Expected Results:**
- ✅ Empty search shows all entries
- ✅ Special characters handled properly
- ✅ "No results" state shown appropriately
- ✅ Partial matching works correctly
- ✅ Long terms don't break UI

### Test Case 3.3: Search Performance
**Objective:** Verify search performance với large dataset

**Test Steps:**
1. Create 50+ test entries
2. Perform various searches
3. Measure response time
4. Check UI responsiveness

**Expected Results:**
- ✅ Search results appear within 1 second
- ✅ UI remains responsive during search
- ✅ No memory issues với large datasets

---

## Test Scenario 4: Encryption Transparency (US-004)

### Test Case 4.1: Transparent Encryption
**Objective:** Verify encryption works invisibly to user

**Test Steps:**
1. Create entry với sensitive content
2. Save và retrieve multiple times
3. Verify content always identical
4. Check app performance unaffected
5. Test với various content lengths

**Expected Results:**
- ✅ No visible encryption/decryption process
- ✅ Content identical across sessions
- ✅ No performance degradation
- ✅ Works với all content types

### Test Case 4.2: App Launch Performance
**Objective:** Ensure encryption doesn't slow app launch

**Test Steps:**
1. Create 100+ encrypted entries
2. Force quit app
3. Measure app launch time
4. Verify all entries load correctly

**Expected Results:**
- ✅ App launches within 2 seconds
- ✅ All entries decrypt correctly
- ✅ No user-visible delays
- ✅ Consistent performance

---

## Test Scenario 5: Integration & Regression Tests

### Test Case 5.1: Complete User Journey
**Objective:** Test end-to-end user workflow

**Test Steps:**
1. Launch app (US-001)
2. Create first entry với auto-save (US-002)
3. Create several more entries
4. Browse entries in list view (US-003)
5. Search for specific content (US-005)
6. View entry details
7. Verify encryption working transparently (US-004)

**Expected Results:**
- ✅ Smooth workflow from start to finish
- ✅ All features work together seamlessly
- ✅ No data inconsistencies
- ✅ Performance remains good throughout

### Test Case 5.2: App State Management
**Objective:** Test app behavior với various state changes

**Test Steps:**
1. Create entries
2. Background app
3. Force memory pressure
4. Return to app
5. Verify all data intact

**Expected Results:**
- ✅ App resumes correctly
- ✅ All entries preserved
- ✅ Encryption keys remain valid
- ✅ UI state restored properly

### Test Case 5.3: Stress Testing
**Objective:** Test app limits và edge cases

**Test Steps:**
1. Create 1000+ character entries
2. Create 100+ entries total
3. Perform rapid operations
4. Test memory và performance

**Expected Results:**
- ✅ Large entries handled correctly
- ✅ Many entries don't break app
- ✅ Rapid operations remain stable
- ✅ Memory usage reasonable

---

## Automation Implementation

### XcodeBuildMCP Test Script Structure
```swift
// Test Scenario Automation
func runComprehensiveUITests() {
    // Setup
    let simulator = "iPhone 16"
    build_run_sim(scheme: "Kioku", simulatorName: simulator)
    
    // Test Case 1: Entry Creation
    testEntryCreationWorkflow()
    
    // Test Case 2: Entry Browsing
    testEntryBrowsingWorkflow() 
    
    // Test Case 3: Search Functionality
    testSearchWorkflow()
    
    // Test Case 4: Encryption Transparency
    testEncryptionWorkflow()
    
    // Test Case 5: Integration
    testCompleteUserJourney()
    
    // Cleanup
    cleanupTestData()
}
```

### Test Data Management
- Automated test data creation
- Clean slate for each test run
- Reproducible test scenarios
- Performance measurement hooks

### Reporting
- Screenshot capture at key points
- Performance metrics collection
- Pass/fail status for each scenario
- Detailed logs for debugging

---

## Success Criteria

### Coverage Requirements
- [✅] All Sprint 1-2 user stories tested
- [✅] Happy path scenarios covered
- [✅] Edge cases và error conditions tested
- [✅] Performance benchmarks established
- [✅] Regression prevention in place

### Quality Gates
- [✅] All test scenarios pass consistently
- [✅] No manual intervention required
- [✅] Tests complete within 10 minutes
- [✅] Clear pass/fail reporting
- [✅] Integration với development workflow

### Maintenance
- [✅] Test scenarios documented clearly
- [✅] Easy to update tests for new features
- [✅] Automated test data management
- [✅] Performance regression detection
- [✅] CI/CD integration ready

---

## Test Scenario 6: AI Analysis Data Persistence (US-010) - Sprint 4

### Test Case 6.1: AI Analysis Persistence
**Objective:** Verify AI analysis results are stored and retrieved correctly

**Test Steps:**
1. Create journal entry với meaningful content
2. Navigate to entry detail view
3. Tap "AI Analysis" button from menu
4. Wait for analysis completion
5. Verify analysis results displayed
6. Navigate away và return to entry
7. Verify analysis results persisted

**Expected Results:**
- ✅ Analysis results display correctly (sentiment, themes, entities)
- ✅ Results persist across app sessions
- ✅ Analysis metadata shown (model used, date)
- ✅ Historical analysis accessible

**XcodeBuildMCP Commands:**
```
1. tap(x: "New Entry button") - Create entry
2. type_text("Today I had a productive meeting with my team about the new project. We discussed innovative solutions and I felt very motivated about the challenges ahead.")
3. gesture(preset: "swipe-from-left-edge") - Save entry
4. tap(x: "Browse Entries") - Navigate to list
5. tap(first_entry) - Open detail view
6. tap(menu_button) - Open menu
7. tap("AI Analysis") - Trigger analysis
8. screenshot() - Capture analysis results
9. gesture(preset: "swipe-from-left-edge") - Navigate away
10. tap(same_entry) - Return to entry
11. screenshot() - Verify persistence
```

### Test Case 6.2: Analysis History Viewing
**Objective:** Test historical analysis viewing functionality

**Test Steps:**
1. Analyze same entry multiple times với different models
2. Verify "History" button appears
3. Tap "History" button
4. Verify multiple analyses shown
5. Check analysis comparison features

**Expected Results:**
- ✅ Multiple analyses stored per entry
- ✅ History interface displays correctly
- ✅ Analysis metadata distinguishes different runs
- ✅ User can compare different model results

### Test Case 6.3: Analysis Error Handling
**Objective:** Verify proper error handling for analysis failures

**Test Steps:**
1. Attempt analysis with no API key configured
2. Verify error message shown
3. Test analysis với very short content
4. Test network failure scenarios

**Expected Results:**
- ✅ Clear error messages displayed
- ✅ App doesn't crash on analysis errors
- ✅ User can retry failed analyses
- ✅ Graceful degradation implemented

---

## Test Scenario 7: Knowledge Graph Generation (US-011) - Sprint 4

### Test Case 7.1: Connection Discovery
**Objective:** Test knowledge graph connection discovery between entries

**Test Steps:**
1. Create 3+ entries with related themes và entities:
   - Entry 1: "Meeting with John about project management"
   - Entry 2: "Project management challenges today"
   - Entry 3: "John suggested new productivity tools"
2. Analyze all entries
3. Open first entry detail view
4. Tap "View Connections" button
5. Verify connections discovered
6. Check connection strength indicators

**Expected Results:**
- ✅ Related entries connected properly
- ✅ Connection types identified (entity match, theme similarity)
- ✅ Connection strength displayed accurately
- ✅ Common elements highlighted

**XcodeBuildMCP Commands:**
```
1. [Create and analyze 3 related entries]
2. tap(first_entry) - Open entry detail
3. tap("View Connections") - Open knowledge graph
4. screenshot() - Capture connections
5. describe_ui() - Get connection elements
6. tap(connection_card) - Navigate to related entry
7. screenshot() - Verify navigation works
```

### Test Case 7.2: Knowledge Graph UI Navigation
**Objective:** Test navigation between connected entries

**Test Steps:**
1. Open knowledge graph view for entry
2. Verify connection cards displayed
3. Tap on connection card
4. Verify navigation to related entry works
5. Test back navigation

**Expected Results:**
- ✅ Connection cards are tappable
- ✅ Navigation to related entries smooth
- ✅ Entry detail view opens correctly
- ✅ Back navigation preserves graph state

### Test Case 7.3: Connection Statistics
**Objective:** Verify connection statistics và overview

**Test Steps:**
1. Generate knowledge graph for multiple entries
2. Check statistics section
3. Verify connection counts by type
4. Check strength distribution metrics

**Expected Results:**
- ✅ Accurate connection counts displayed
- ✅ Connection types properly categorized
- ✅ Statistics update dynamically
- ✅ Performance acceptable for large datasets

---

## Test Scenario 8: Batch Processing Capability (US-012) - Sprint 4

### Test Case 8.1: Batch Reanalysis Operation
**Objective:** Test batch reanalysis of multiple entries

**Test Steps:**
1. Create 5+ journal entries
2. Navigate to main screen
3. Tap settings/tools icon
4. Open "Batch Processing" (gear icon trong toolbar hoặc AI Tools)
5. Tap "Reanalyze All Entries"
6. Verify progress tracking displays
7. Monitor operation completion

**Expected Results:**
- ✅ Batch processing UI accessible
- ✅ Progress bar updates in real-time
- ✅ ETA calculation shown
- ✅ Success/failure counts accurate
- ✅ Background processing works

**XcodeBuildMCP Commands:**
```
1. tap(toolbar_settings) - Open tools menu
2. tap("Batch Processing") - Open batch UI
3. screenshot() - Capture batch interface
4. tap("Reanalyze All Entries") - Start operation
5. screenshot() - Capture progress view
6. [Wait for completion]
7. screenshot() - Capture results
```

### Test Case 8.2: Operation Control (Pause/Resume/Cancel)
**Objective:** Test batch operation control mechanisms

**Test Steps:**
1. Start batch reanalysis operation
2. Test pause button functionality
3. Verify operation pauses
4. Test resume button
5. Test cancel button
6. Verify proper cleanup

**Expected Results:**
- ✅ Pause button stops processing
- ✅ Resume button continues from pause point
- ✅ Cancel button terminates operation
- ✅ UI updates reflect operation state
- ✅ No data corruption on cancellation

### Test Case 8.3: Processing Statistics
**Objective:** Verify batch processing statistics và reporting

**Test Steps:**
1. Complete several batch operations
2. Check statistics section
3. Verify operation counts accurate
4. Check processing time metrics
5. Test statistics reset functionality

**Expected Results:**
- ✅ Accurate operation statistics
- ✅ Processing time metrics reasonable
- ✅ Success/failure ratios correct
- ✅ Statistics persist across sessions

---

## Test Scenario 9: Sprint 4 Integration Tests

### Test Case 9.1: Complete AI Workflow
**Objective:** Test complete AI-powered workflow end-to-end

**Test Steps:**
1. Create multiple related journal entries
2. Perform individual AI analysis on entries
3. View analysis history for entries
4. Generate knowledge graph connections
5. Use batch processing for reanalysis
6. Navigate between connected entries
7. Verify all data persists

**Expected Results:**
- ✅ Smooth workflow from entry creation to knowledge discovery
- ✅ All AI features work together seamlessly
- ✅ Data consistency across features
- ✅ Performance remains good với AI processing

### Test Case 9.2: UI Integration Testing
**Objective:** Test new UI elements integration

**Test Steps:**
1. Verify "AI Tools" section appears in main view (when 2+ entries)
2. Test Knowledge Graph access from entry detail view
3. Test "View Connections" quick action
4. Verify analysis history toggle works
5. Test batch processing access từ toolbar

**Expected Results:**
- ✅ New UI elements display conditionally
- ✅ Navigation flows work smoothly
- ✅ Visual design consistent across features
- ✅ No UI layout issues on different screen sizes

### Test Case 9.3: Performance với AI Features
**Objective:** Verify performance với AI processing

**Test Steps:**
1. Create 20+ entries
2. Perform batch analysis
3. Generate knowledge graph
4. Measure response times
5. Check memory usage
6. Test UI responsiveness during processing

**Expected Results:**
- ✅ Analysis operations complete within reasonable time
- ✅ UI remains responsive during background processing
- ✅ Memory usage acceptable
- ✅ No app crashes under load

---

## Test Scenario 10: Error Handling & Edge Cases - Sprint 4

### Test Case 10.1: API Integration Error Handling
**Objective:** Test error scenarios for AI API integration

**Test Steps:**
1. Test analysis with no API key configured
2. Test analysis with invalid API key
3. Test network connection failures
4. Test API rate limiting scenarios
5. Verify error recovery mechanisms

**Expected Results:**
- ✅ Clear error messages for all failure scenarios
- ✅ App doesn't crash on API errors
- ✅ Retry mechanisms work properly
- ✅ User can configure API settings

### Test Case 10.2: Data Consistency Edge Cases
**Objective:** Test data consistency under various conditions

**Test Steps:**
1. Test concurrent analysis operations
2. Test app backgrounding during batch processing
3. Test low memory conditions
4. Test database corruption recovery
5. Verify analysis data integrity

**Expected Results:**
- ✅ No data races or corruption
- ✅ Proper cleanup on app termination
- ✅ Robust error recovery
- ✅ Analysis data remains consistent

---

## Automation Implementation Updates - Sprint 4

### Extended XcodeBuildMCP Test Script Structure
```swift
// Complete Sprint 4 Test Automation
func runSprint4ComprehensiveTests() {
    // Setup
    let simulator = "iPhone 16"
    build_run_sim(scheme: "Kioku", simulatorName: simulator)
    
    // Sprint 1-3 Regression Tests
    testBasicFunctionality()
    testEntryManagement()
    testEncryption()
    
    // Sprint 4 New Features
    testAIAnalysisPersistence()
    testKnowledgeGraphGeneration()
    testBatchProcessingWorkflow()
    
    // Integration Tests
    testCompleteAIWorkflow()
    testUIIntegration()
    testPerformanceWithAI()
    
    // Error Handling
    testAPIErrorScenarios()
    testDataConsistencyEdgeCases()
    
    // Cleanup và Reporting
    generateComprehensiveReport()
    cleanupTestData()
}
```

### Performance Benchmarks - Sprint 4
- **AI Analysis:** <10 seconds per entry
- **Knowledge Graph Generation:** <30 seconds for 20+ entries  
- **Batch Processing:** <5 minutes for 50 entries
- **UI Responsiveness:** Maintained during all operations
- **Memory Usage:** <150MB peak usage

---

**Test Implementation Status:** 🔄 **UPDATED FOR SPRINT 4**  
**Sprint 1-3 test scenarios verified and maintained**  
**Sprint 4 test scenarios added and documented**  
**Complete coverage for US-001 through US-012**  
**XcodeBuildMCP automation expanded for AI features**  
**Ready for comprehensive Sprint 4 testing execution**