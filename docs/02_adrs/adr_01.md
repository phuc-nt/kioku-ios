# ADR-001: iOS Architecture Pattern Selection

**Status:** Approved  
**Date:** September 12, 2025  
**Deciders:** Solo Developer/Product Owner  
**Related Sprint:** Sprint-1-Planning.md → Task 1.1

***

## Context

The AI-Powered Personal Journal iOS app requires a robust architecture pattern that supports:

- **SwiftUI declarative UI** with state-driven data flow
- **Core Data integration** for local persistence with encryption
- **Future AI integration** via OpenRouter API (Sprint 4+)
- **Solo development** with emphasis on maintainability and simplicity
- **Rapid iteration** capabilities for agile development approach

### Technical Environment
- **Platform**: iOS 15.0+, SwiftUI framework
- **Data Layer**: Core Data with encryption
- **External APIs**: OpenRouter (future), Google Drive (future)
- **Complexity**: Medium (journaling + AI processing + chat interface)

### Key Architectural Challenges
1. **State Management**: Handle complex UI state across writing, reviewing, and chat interfaces
2. **Data Flow**: Seamless integration between Core Data, AI processing, and UI updates  
3. **Testability**: Enable comprehensive testing for personal data handling
4. **Scalability**: Foundation that supports AI features and multi-model switching
5. **Separation of Concerns**: Clear boundaries between UI, business logic, and data layers

***

## Decision

**Selected Architecture: MVVM (Model-View-ViewModel) with Service Layer**

### Core Components:

#### **Views (SwiftUI)**
- `EntryCreationView`, `EntryDetailView`, `CalendarView`, `ChatView`
- Purely declarative UI with minimal logic
- State binding to ViewModels via `@StateObject` and `@ObservedObject`

#### **ViewModels (ObservableObject)**
- `EntryCreationViewModel`, `EntryListViewModel`, `ChatViewModel` 
- Handle UI state, user interactions, and business logic coordination
- Communicate with Service layer for data operations
- Publish state changes via `@Published` properties

#### **Services (Protocol-based)**
- `DataService`: Core Data operations with encryption
- `AIService`: Future OpenRouter API integration  
- `BackupService`: Future Google Drive integration
- Dependency injection via Environment or explicit initialization

#### **Models**  
- `Entry` (Core Data NSManagedObject)
- `AIResponse`, `KnowledgeGraphNode` (future data models)
- Value types for UI state and API responses

### Architecture Flow:
```
SwiftUI Views ↔ ViewModels ↔ Services ↔ Core Data/APIs
```

***

## Rationale

### **Why MVVM over MVC:**
- **SwiftUI Compatibility**: MVVM aligns naturally with SwiftUI's declarative, state-driven approach[5]
- **Testability**: ViewModels can be unit tested independently of UI components
- **State Management**: `@Published` properties integrate seamlessly with SwiftUI's data binding
- **Scalability**: Clear separation enables complex features like AI chat without massive controllers

### **Why MVVM over Redux/TCA:**
- **Learning Curve**: Solo developer benefits from familiar, well-documented pattern
- **Complexity Match**: MVVM sufficient for app complexity without Redux overhead  
- **Community Support**: Extensive SwiftUI + MVVM resources and best practices available
- **Development Speed**: Faster initial development crucial for personal project timeline

### **Service Layer Benefits:**
- **Future-Proofing**: Clean abstraction for AI integration in Sprint 4+
- **Testing**: Mock services for comprehensive unit testing
- **Reusability**: Services shared across multiple ViewModels
- **Single Responsibility**: Each service handles one domain (data, AI, backup)

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