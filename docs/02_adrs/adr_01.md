# ADR-001: iOS Architecture Pattern Selection

**Status:** Revised  
**Date:** September 23, 2025 (Updated from September 12, 2025)  
**Deciders:** Solo Developer/Product Owner  
**Related Sprint:** Sprint-1-Planning.md → Task 1.1

***

## Context

The AI-Powered Personal Journal iOS app requires a robust architecture pattern that supports:

- **SwiftUI declarative UI** with state-driven data flow
- **SwiftData integration** for local persistence with encryption
- **Future AI integration** via OpenRouter API (Sprint 4+)
- **Solo development** with emphasis on maintainability and simplicity
- **Rapid iteration** capabilities for agile development approach

### Technical Environment
- **Platform**: iOS 15.0+, SwiftUI framework
- **Data Layer**: SwiftData with encryption
- **External APIs**: OpenRouter (future), Google Drive (future)
- **Complexity**: Medium (journaling + AI processing + chat interface)

### Key Architectural Challenges
1. **State Management**: Handle complex UI state across writing, reviewing, and chat interfaces
2. **Data Flow**: Seamless integration between SwiftData, AI processing, and UI updates  
3. **Testability**: Enable comprehensive testing for personal data handling
4. **Scalability**: Foundation that supports AI features and multi-model switching
5. **Separation of Concerns**: Clear boundaries between UI, business logic, and data layers

***

## Decision

**Selected Architecture: Modern SwiftUI MV Pattern with @Observable Services**

### Core Components:

#### **Views (SwiftUI)**
- `EntryCreationView`, `EntryDetailView`, `CalendarView`, `ChatView`
- Pure state expressions using SwiftUI's native data flow
- State management via `@State`, `@Environment`, and `@Binding`

#### **Models (@Model with SwiftData)**
- `Entry` (@Model class for SwiftData persistence)
- `AIResponse`, `KnowledgeGraphNode` (future data models)
- Value types for UI state and API responses

#### **Services (@Observable)**
- `DataService`: SwiftData operations with encryption
- `AIService`: Future OpenRouter API integration  
- `BackupService`: Future Google Drive integration
- Dependency injection via `@Environment`

### Architecture Flow:
```
SwiftUI Views (@State) ↔ @Observable Services ↔ SwiftData Models
```

***

## Rationale

### **Why Modern MV Pattern over MVVM:**
- **SwiftUI Native**: Leverages SwiftUI's built-in state management instead of fighting it
- **Less Boilerplate**: No ViewModels needed - views are lightweight and disposable
- **@Observable Performance**: Tracks only accessed properties, more efficient than @Published
- **Future-Proof**: Aligns with Apple's latest SwiftUI best practices (2025)

### **Why SwiftData over Core Data:**
- **Type Safety**: Compile-time safety vs Core Data's runtime errors
- **SwiftUI Integration**: Native integration with @Query and @Environment
- **Less Code**: Significantly less boilerplate than Core Data
- **Modern API**: Clean, Swift-native API designed for SwiftUI

### **@Observable Services Benefits:**
- **Environment Integration**: Clean dependency injection via @Environment
- **Testing**: Mock services easily for comprehensive unit testing
- **Performance**: Only notifies views of actually accessed properties
- **Future-Ready**: Clean abstraction for AI integration in Sprint 4+

***

## Implementation Guidelines

### **ViewModel Responsibilities:**
- UI state management and user interaction handling
- Coordination between multiple services
- Business logic specific to UI flows
- Error handling and user feedback

### **Service Responsibilities:**  
- Data persistence and retrieval operations
- External API communication
- Cross-cutting concerns (encryption, networking)
- Domain-specific business rules

### **Dependency Injection Pattern:**
```swift
// Environment-based injection for services
struct ContentView: View {
    var body: some View {
        EntryCreationView()
            .environmentObject(DataService.shared)
            .environmentObject(AIService.shared)
    }
}

// ViewModel service dependencies
class EntryCreationViewModel: ObservableObject {
    @Published var content: String = ""
    
    private let dataService: DataService
    
    init(dataService: DataService = DataService.shared) {
        self.dataService = dataService
    }
}
```

***

## Consequences

### **Positive:**
- **Clear Separation**: UI, business logic, and data layers well-separated
- **Testable**: Each layer can be tested independently
- **SwiftUI Native**: Leverages SwiftUI's strengths rather than fighting them
- **Maintainable**: Familiar pattern with extensive documentation and community support
- **Future-Ready**: Service layer abstraction supports AI integration without architectural changes

### **Negative:**
- **Boilerplate**: More files and setup compared to simple MVC
- **Memory Management**: Need careful attention to avoid retain cycles with `@Published` properties
- **Service Coordination**: Complex flows may require careful orchestration between services
- **Over-Abstraction Risk**: Must avoid unnecessary complexity for simple operations

### **Mitigation Strategies:**
- **Code Templates**: Create Xcode templates for ViewModel/Service boilerplate
- **Weak References**: Use `[weak self]` in closures and proper lifecycle management
- **Service Protocols**: Keep services focused with clear, single-responsibility interfaces
- **Pragmatic Approach**: Start simple, add abstraction only when complexity justifies it

***

## Alternatives Considered

### **MVC (Massive View Controller)**
- ✅ **Pros**: Simple, familiar, less boilerplate
- ❌ **Cons**: Poor SwiftUI integration, testing difficulties, scalability issues

### **Redux/TCA (The Composable Architecture)**
- ✅ **Pros**: Powerful state management, excellent for complex apps
- ❌ **Cons**: Steep learning curve, overkill for current complexity, slower initial development

### **VIPER**
- ✅ **Pros**: Excellent separation of concerns, highly testable
- ❌ **Cons**: Heavy boilerplate, over-engineered for solo project, learning overhead

### **Clean Architecture**  
- ✅ **Pros**: Excellent for large teams, very maintainable long-term
- ❌ **Cons**: Significant upfront investment, complex for current scope

***

## Validation Criteria

### **Architecture Success Metrics:**
- [ ] **Development Velocity**: New features can be added in single sprint cycles
- [ ] **Testing Coverage**: >80% unit test coverage achievable for business logic
- [ ] **AI Integration**: OpenRouter API integration requires minimal architectural changes
- [ ] **Code Maintainability**: New developer (future self) can understand codebase within 2 hours

### **Review Triggers:**
- **Sprint 4**: Re-evaluate when adding AI integration complexity
- **Sprint 8**: Assess if chat interface complexity requires architectural evolution  
- **Sprint 12**: Review when adding multi-model switching features

***

## References

- [Clean Architecture for SwiftUI - Alexey Naumov](https://nalexn.github.io/clean-architecture-swiftui/)
- [SwiftUI + Core Data MVVM Best Practices](https://www.curiousalgorithm.com/post/core-data-in-swiftui-apps)
- **Related Decisions**: ADR-002 (Data Model Schema), ADR-003 (Core Data Concurrency)
- **Implementation**: Sprint-1-Planning.md → Technical Tasks 1.1, 1.4

***

**Decision Made By:** Solo Developer  
**Implementation Start:** Sprint 1, Week 1  
**Next Review:** Sprint 4 (AI Integration Planning)