# ADR-008: OpenRouter API Integration Strategy

**Date:** September 25, 2025  
**Status:** Decided  
**Context:** Sprint 3 - US-008 OpenRouter API Integration  
**Decision Maker:** Development Team  
**Related ADRs:** ADR-001 (iOS Architecture), ADR-007 (Encryption Strategy)

## Context

The Kioku personal journal app requires AI integration to analyze journal entries and extract meaningful insights. We need to choose an API strategy that provides:

1. **Multi-Model Access**: Ability to use different AI models (GPT-4, Claude, Llama, etc.)
2. **Cost Management**: Control over API usage costs và token consumption
3. **Reliability**: Robust error handling và retry mechanisms
4. **Security**: Secure API key storage và request handling
5. **Flexibility**: Easy model switching for different analysis tasks

## Requirements

### Functional Requirements
- Access to multiple state-of-the-art AI models through single API
- Secure API key management via iOS Keychain
- Comprehensive error handling for network failures và API limits
- Usage tracking for cost monitoring
- Retry logic với exponential backoff for rate limiting

### Non-Functional Requirements
- Request timeout: <30 seconds for typical journal analysis
- API key storage: Hardware-backed security when available
- Network resilience: 3 retry attempts với smart backoff
- Cost efficiency: Default to cost-effective models like GPT-4o Mini

## Decision

**Selected Solution: OpenRouter API với Custom Service Architecture**

### Core Implementation Components:

#### **OpenRouterService Architecture**
```swift
@Observable
public final class OpenRouterService {
    // Secure API key management via iOS Keychain
    private let keyIdentifier = "com.phucnt.kioku.openrouter.apikey"
    
    // Configurable model selection
    public var currentModel = "openai/gpt-4o-mini" // Default cost-effective
    
    // Usage tracking
    public private(set) var totalTokensUsed = 0
    public private(set) var totalRequestsCount = 0
}
```

#### **Request/Response Models**
- **CompletionRequest**: Structured request với model selection, messages, parameters
- **ChatMessage**: Role-based message system (system/user/assistant)
- **CompletionResponse**: Parsed response với choices, usage statistics

#### **Error Handling Strategy**
- **Rate Limiting**: Exponential backoff với max 3 retries
- **Network Failures**: Automatic retry với increasing delays
- **API Errors**: Specific error types (unauthorized, model unavailable, request too large)
- **Graceful Degradation**: Clear error messages for user feedback

## Technical Implementation

### API Client Configuration
```swift
// Base URL and headers
private let baseURL = "https://openrouter.ai/api/v1"
urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
urlRequest.setValue("Kioku-iOS/1.0", forHTTPHeaderField: "User-Agent")
urlRequest.setValue("https://github.com/phuc-nt/kioku-ios", forHTTPHeaderField: "HTTP-Referer")
```

### Model Selection Strategy
- **Default Model**: `openai/gpt-4o-mini` (cost-effective for journal analysis)
- **Available Options**: GPT-4o, Claude 3 variants, Llama 3.1, Gemini Pro
- **Switching Logic**: User preference với fallback to default

### Security Implementation
```swift
// Secure key storage in iOS Keychain
kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
```

### Usage Tracking
- **Token Consumption**: Track total tokens across all requests
- **Request Count**: Monitor API call frequency
- **Cost Estimation**: Approximate costs based on model pricing
- **Reset Capability**: Clear statistics for new billing periods

## Alternative Approaches Considered

### Direct OpenAI API Integration
**Pros**: Direct access to GPT models, well-documented
**Cons**: Limited to OpenAI models only, no multi-model flexibility
**Decision**: Rejected - Need flexibility for multiple AI providers

### Anthropic Claude API Direct
**Pros**: Excellent at analysis tasks, strong reasoning capabilities
**Cons**: Single provider lock-in, separate integration needed for other models
**Decision**: Rejected - Want unified interface for multiple models

### Local AI Models (CoreML/ONNX)
**Pros**: No API costs, complete privacy, offline capability
**Cons**: Limited model capabilities, large app size, device performance constraints
**Decision**: Rejected - Need state-of-the-art models for quality insights

### Multiple Direct API Integrations
**Pros**: Maximum flexibility, direct provider relationships
**Cons**: Complex management, multiple API keys, inconsistent interfaces
**Decision**: Rejected - Too complex for MVP, prefer unified interface

## Benefits of OpenRouter Approach

### **Multi-Model Flexibility**
- Single API interface for 20+ AI models
- Easy A/B testing between models
- Future-proof as new models become available
- Consistent request/response format across providers

### **Cost Management**
- Transparent pricing across all models
- Usage tracking và budget controls
- Ability to optimize costs by choosing appropriate models
- No need for multiple API subscriptions

### **Developer Experience**
- Single authentication mechanism
- Unified error handling
- Consistent rate limiting across providers
- Good documentation và community support

### **Technical Benefits**
- Load balancing across model providers
- Built-in failover capabilities
- Standardized API format
- Regular model updates without code changes

## Implementation Plan

### Phase 1: Core Integration (Sprint 3)
1. **OpenRouterService Implementation**: Complete service architecture
2. **API Key Management**: Secure storage và retrieval via Keychain
3. **Basic Request Handling**: Single completion requests với error handling
4. **Usage Tracking**: Token và request count monitoring

### Phase 2: Enhanced Features (Sprint 4)
1. **Model Comparison**: Side-by-side analysis results
2. **Cost Optimization**: Smart model selection based on task complexity
3. **Batch Processing**: Efficient handling of multiple entries
4. **Advanced Error Recovery**: Sophisticated retry strategies

### Phase 3: Production Readiness (Sprint 5)
1. **Performance Optimization**: Request caching và response optimization
2. **Advanced Usage Analytics**: Detailed cost tracking và insights
3. **User Preferences**: Model selection preferences và customization
4. **Monitoring và Alerting**: Usage thresholds và cost warnings

## Security Considerations

### API Key Protection
- **Storage**: iOS Keychain với device-only accessibility
- **Transport**: HTTPS-only communication
- **Access**: No logging or exposure of API keys
- **Rotation**: Support for key updates without app restart

### Request Security
- **Headers**: Proper User-Agent và Referer identification
- **Timeout**: Prevent indefinite hanging requests
- **Data Sanitization**: Clean input data before API calls
- **Error Logging**: No sensitive data in error messages

### Privacy
- **Data Transmission**: Journal content sent only when explicitly requested
- **Model Training**: OpenRouter respects training data opt-outs
- **Local Processing**: Minimize data transmission when possible
- **User Control**: Clear consent for AI processing

## Performance Expectations

### Response Times
- **Simple Analysis**: 2-5 seconds for basic entity extraction
- **Complex Analysis**: 5-10 seconds for detailed insights
- **Batch Processing**: 30-60 seconds for multiple entries
- **Timeout Handling**: 30-second maximum wait với fallback options

### Cost Estimates
- **GPT-4o Mini**: ~$0.001-0.005 per journal entry analysis
- **Claude 3 Haiku**: ~$0.002-0.008 per analysis
- **Monthly Budget**: ~$5-15 for active daily usage
- **Cost Controls**: Usage limits và budget alerts

## Success Criteria

### Functional Success
- [ ] **API Integration**: Successful communication với OpenRouter API
- [ ] **Multi-Model Support**: At least 3 different models accessible
- [ ] **Error Handling**: Graceful handling of all error scenarios
- [ ] **Security**: API keys stored securely, no data leaks
- [ ] **Performance**: 95% of requests complete within 10 seconds

### Quality Metrics
- [ ] **Reliability**: >99% API success rate under normal conditions
- [ ] **Cost Efficiency**: Average analysis cost <$0.01 per entry
- [ ] **User Experience**: Clear loading states và error messages
- [ ] **Usage Tracking**: Accurate token và cost monitoring
- [ ] **Model Flexibility**: Easy switching between models

## Risks và Mitigation

### High Priority Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| OpenRouter API outages | High | Low | Implement local caching và graceful degradation |
| Unexpected cost spikes | High | Medium | Usage limits, budget alerts, cost monitoring |
| Model quality variations | Medium | Medium | A/B testing, user feedback, model benchmarking |
| API rate limiting | Medium | Medium | Exponential backoff, request queuing |

### Technical Risks
- **Network Reliability**: Handle poor connectivity gracefully
- **Model Availability**: Fallback to alternative models when primary unavailable
- **Response Quality**: Validate và sanitize AI-generated content
- **Token Estimation**: Accurate cost prediction for budget planning

## Future Considerations

### Potential Enhancements
- **Local Model Fallback**: CoreML models for offline basic analysis
- **Custom Fine-Tuning**: Train specialized models for journal analysis
- **Advanced Routing**: Intelligent model selection based on content type
- **Multi-Provider Strategy**: Direct integrations for specific use cases

### Scalability Planning
- **Caching Strategy**: Cache common analysis results
- **Batch Optimization**: Group related requests for efficiency
- **Usage Analytics**: Detailed insights for optimization opportunities
- **Cost Optimization**: Dynamic model selection based on complexity

## References

- [OpenRouter API Documentation](https://openrouter.ai/docs)
- [OpenRouter Model Pricing](https://openrouter.ai/models)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [Swift Concurrency Best Practices](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

---

**Related Documents:**
- ADR-001-iOS-Architecture-Pattern.md → Service architecture context
- ADR-007-SwiftData-Encryption-Strategy.md → Security patterns
- Sprint-3-Planning.md → Implementation timeline và tasks