# ADR-007: SwiftData Encryption Strategy

**Date:** September 25, 2025  
**Status:** Decided  
**Context:** Sprint 2 - US-004 Secure Local Storage Implementation  
**Decision Maker:** Development Team

## Context

The Kioku personal journal app requires secure storage of sensitive personal data (journal entries, thoughts, reflections) to maintain user privacy and trust. SwiftData doesn't provide built-in encryption, so we need to implement a secure storage strategy.

## Requirements

1. **Data Privacy**: All journal content must be encrypted at rest
2. **Performance**: Encryption/decryption must not significantly impact app performance
3. **Security**: Use industry-standard encryption algorithms (AES-256)
4. **Key Management**: Secure key storage using iOS Keychain
5. **Migration**: Support for existing unencrypted data
6. **Development**: Easy to implement and maintain

## Decision

**Selected Approach: Field-Level Encryption with CryptoKit**

We will implement field-level encryption on the `Entry.content` field using:

- **Encryption Algorithm**: AES-256-GCM (Galois/Counter Mode)
- **Key Management**: iOS Keychain Services for secure key storage
- **Implementation**: CryptoKit framework for modern Swift cryptography
- **Data Format**: Store encrypted content as Data in SwiftData, decrypt on access

## Technical Implementation

### 1. Encryption Service Architecture

```swift
import CryptoKit
import Foundation

@Observable
final class EncryptionService {
    private let keyIdentifier = "com.phucnt.kioku.encryption.key"
    
    // Generate or retrieve encryption key from Keychain
    private func getOrCreateKey() throws -> SymmetricKey
    
    // Encrypt string content to Data
    func encrypt(_ content: String) throws -> Data
    
    // Decrypt Data back to string content  
    func decrypt(_ data: Data) throws -> String
}
```

### 2. Entry Model Updates

```swift
@Model
public final class Entry {
    public var id: UUID
    private var encryptedContent: Data // Store encrypted content
    public var createdAt: Date
    public var updatedAt: Date
    
    // Computed property for transparent encryption/decryption
    public var content: String {
        get { /* decrypt encryptedContent */ }
        set { /* encrypt and store in encryptedContent */ }
    }
}
```

### 3. Key Management Strategy

- **Key Generation**: 256-bit symmetric key using `SymmetricKey.init(size: .bits256)`
- **Key Storage**: iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **Key Rotation**: Support for future key rotation (not implemented in MVP)
- **Backup**: Keys are device-specific, not backed up to iCloud

### 4. Migration Strategy

- **Phase 1**: Add `encryptedContent` field alongside existing `content`
- **Phase 2**: Migrate existing entries to encrypted format on first app launch
- **Phase 3**: Remove unencrypted `content` field in future version

## Alternative Approaches Considered

### Database-Level Encryption
**Pros**: Encrypts entire SQLite database
**Cons**: 
- SwiftData doesn't directly support SQLite encryption
- Would require Core Data or SQLCipher integration
- More complex implementation
- **Decision**: Rejected due to complexity and SwiftData compatibility

### File-Level Encryption
**Pros**: Encrypts entire data store file
**Cons**:
- iOS already provides file-level encryption via Data Protection
- Doesn't add significant security over field-level encryption
- More complex backup/restore scenarios
- **Decision**: Rejected as iOS Data Protection is sufficient for file-level security

### External Encrypted Database
**Pros**: Full database encryption control
**Cons**:
- Abandoning SwiftData benefits
- Much more implementation work
- Complex CloudKit integration
- **Decision**: Rejected as overengineering for MVP

## Security Considerations

### Threat Model
- **Device Compromise**: Encryption protects against forensic data extraction
- **Backup Analysis**: Data remains encrypted in device backups
- **Memory Dumps**: Plaintext exists briefly in memory during encryption/decryption
- **Code Inspection**: Keys are secured in Keychain, not hardcoded

### Security Properties
- **Confidentiality**: AES-256-GCM provides strong encryption
- **Integrity**: GCM mode provides authentication and integrity checking
- **Key Security**: iOS Keychain provides hardware-backed key storage on supported devices
- **Forward Secrecy**: Not implemented (would require key rotation)

### Known Limitations
- **Memory Security**: Plaintext content exists temporarily in Swift String objects
- **Debug Builds**: Encryption may be bypassed in debug builds for development
- **Key Recovery**: No key recovery mechanism - lost keys mean lost data

## Implementation Plan

### Phase 1: Core Infrastructure (Sprint 2)
1. Create `EncryptionService` with CryptoKit
2. Implement Keychain key management
3. Add encrypted storage to Entry model
4. Create data migration logic

### Phase 2: Integration & Testing (Sprint 2)
1. Update DataService to use encryption
2. Migrate existing unencrypted entries
3. Performance testing and optimization
4. Security validation (no plaintext storage)

### Phase 3: Future Enhancements (Post-MVP)
1. Key rotation capability
2. Backup/restore with encryption
3. Multiple encryption profiles
4. Hardware security module integration

## Performance Impact

**Expected Impact**: Minimal
- **Encryption Time**: AES-256-GCM ~1-2ms per entry on modern iOS devices
- **Memory Overhead**: ~100 bytes per encrypted entry
- **Storage Overhead**: ~32 bytes IV + 16 bytes authentication tag per entry
- **App Launch**: One-time migration on first launch with encryption

**Mitigation Strategies**:
- Lazy decryption (decrypt only when content is accessed)
- Background encryption for batch operations
- Performance monitoring and optimization

## Compliance & Standards

- **Encryption Algorithm**: NIST-approved AES-256-GCM
- **Key Length**: 256-bit keys exceed most compliance requirements
- **Key Management**: iOS Keychain meets enterprise security standards
- **Implementation**: Apple's CryptoKit framework is FIPS-validated

## Success Criteria

1. **Functionality**: All entries encrypted/decrypted transparently
2. **Performance**: No noticeable delay in normal app usage
3. **Security**: No plaintext content found in app sandbox or backups
4. **Compatibility**: Existing entries migrated without data loss
5. **Maintainability**: Clean, well-documented encryption code

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|---------|-------------|-------------|
| Key Loss | High | Low | Document key management, consider recovery options |
| Performance Degradation | Medium | Low | Performance testing, lazy decryption |
| Migration Failure | High | Medium | Thorough testing, backup validation |
| CryptoKit Bugs | Medium | Very Low | Use well-tested patterns, extensive validation |

## References

- [Apple CryptoKit Documentation](https://developer.apple.com/documentation/cryptokit)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [SwiftData Security Best Practices](https://developer.apple.com/documentation/swiftdata)
- [NIST AES-GCM Specification](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf)

---

**Related Documents:**
- Sprint-2-Planning.md → US-004 implementation tasks
- BRD.md → Section 4.2 Security & Privacy requirements
- ADR-001-iOS-Architecture-Pattern.md → Overall architecture context